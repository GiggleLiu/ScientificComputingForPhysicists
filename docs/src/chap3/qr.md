# QR Factorization: Bottom-up

The QR factorization of a matrix $A \in \mathbb{R}^{m\times n}$ is a factorization of the form
```math
A = QR
```
where $Q \in \mathbb{R}^{m\times m}$ is an orthogonal matrix and $R \in \mathbb{R}^{m\times n}$ is an upper triangular matrix.

## Householder Reflection
Let $v \in \mathbb{R}^m$ be nonzero, An $m$-by-$m$ matrix $P$ of the form
```math
P = 1-\beta vv^T, ~~~\beta = \frac{2}{v^Tv}
```
is a Householder reflection, which is both symmetric and orthogonal.
Suppose we want to project a vector $x$ to $e_1$, i.e. $Px = \beta e_1$. Then we can choose
```math
\begin{align*}
&v = x \pm \|x\|_2 e_1\\
&H = I - \beta vv^T
\end{align*}
```

Let us define a Householder matrix in Julia.

```@example qr
struct HouseholderMatrix{T} <: AbstractArray{T, 2}
    v::Vector{T}
    β::T
end
function HouseholderMatrix(v::Vector{T}) where T
    HouseholderMatrix(v, 2/norm(v, 2)^2)
end

# array interfaces
Base.size(A::HouseholderMatrix) = (length(A.v), length(A.v))
Base.size(A::HouseholderMatrix, i::Int) = i == 1 || i == 2 ? length(A.v) : 1
function Base.getindex(A::HouseholderMatrix, i::Int, j::Int)
    (i == j ? 1 : 0) - A.β * A.v[i] * conj(A.v[j])
end

# Householder matrix is unitary
Base.inv(A::HouseholderMatrix) = A
# Householder matrix is Hermitian
Base.adjoint(A::HouseholderMatrix) = A

# Left and right multiplication
function left_mul!(B, A::HouseholderMatrix)
    B .-= (A.β .* A.v) * (A.v' * B)
    return B
end
function right_mul!(A, B::HouseholderMatrix)
    A .= A .- (A * (B.β .* B.v)) * B.v'
    return A
end
```
In this example, we define a `HouseholderMatrix` type, which is a subtype of `AbstractArray`. The `v` field is the vector $v$ and the `β` field is the scalar $\beta$.
To define the array interfaces, we need to define the `size` and `getindex` functions. Please check the [Julia manual](https://docs.julialang.org/en/v1/manual/interfaces/) for more details.

```@repl qr
using LinearAlgebra, Test
@testset "householder property" begin
    v = randn(3)
    H = HouseholderMatrix(v)
    # symmetric
    @test H' ≈ H
    # reflexive
    @test H^2 ≈ I
    # orthogonal
    @test H' * H ≈ I
end
```

Let us define a function to compute the Householder matrix that projects a vector to $e_1$.
```@example qr
function householder_e1(v::AbstractVector{T}) where T
    v = copy(v)
    v[1] -= norm(v, 2)
    return HouseholderMatrix(v, 2/norm(v, 2)^2)
end
```
```@repl qr
A = Float64[1 2 2; 4 4 2; 4 6 4]
hm = householder_e1(view(A,:,1))
hm * A
```

## QR factoriaztion by Householder reflection.

Let $H_k$ be a Householder reflection that zeros out the $k$-th column below the diagonal. Then we have
```math
H_n \ldots H_2H_1 A = R
```
where $R$ is an upper triangular matrix. Then we can define the $Q$ matrix as
```math
Q = H_1^{T} H_2 ^{T}\ldots H_n^{T},
```
which is a unitary matrix.

```@example qr
function householder_qr!(Q::AbstractMatrix{T}, a::AbstractMatrix{T}) where T
    m, n = size(a)
    @assert size(Q, 2) == m
    if m == 1
        return Q, a
    else
        # apply householder matrix
        H = householder_e1(view(a, :, 1))
        left_mul!(a, H)
        # update Q matrix
        right_mul!(Q, H')
        # recurse
        householder_qr!(view(Q, 1:m, 2:m), view(a, 2:m, 2:n))
    end
    return Q, a
end
```

```@repl qr
@testset "householder QR" begin
    A = randn(3, 3)
    Q = Matrix{Float64}(I, 3, 3)
    R = copy(A)
    householder_qr!(Q, R)
    @info R
    @test Q * R ≈ A
    @test Q' * Q ≈ I
end

A = randn(3, 3)
g = givens_matrix(A, 2, 3)
left_mul!(copy(A), g)
```

## Givens Rotations

```math
G = \left(\begin{matrix}
\cos\theta & -\sin\theta\\
\sin\theta & \cos\theta
\end{matrix}\right)
```

```@example qr
rotation_matrix(angle) = [cos(angle) -sin(angle); sin(angle) cos(angle)]
```

```@repl qr
angle = π/4
initial_vector = [1.0, 0.0]
final_vector = rotation_matrix(angle) * initial_vector
# eliminating the y element
atan(0.1, 0.5)
initial_vector = randn(2)
angle = atan(initial_vector[2], initial_vector[1])
final_vector = rotation_matrix(-angle) * initial_vector
```

```math
\left(
\begin{matrix}
1 & 0 & 0 & 0 & 0\\
0 & c & 0 & s & 0\\
0 & 0 & 1 & 0 & 0\\
0 & -s & 0 & c & 0\\
0 & 0 & 0 & 0 & 1
\end{matrix}
\right)
\left(
\begin{matrix}
a_1\\a_2\\a_3\\a_4\\a_5
\end{matrix}
\right)=
\left(
\begin{matrix}
a_1\\\alpha\\a_3\\0\\a_5
\end{matrix}
\right)
```
where $s = \sin(\theta)$ and $c = \cos(\theta)$.

## QR Factorization by Givens Rotations

```@example qr
struct GivensMatrix{T} <: AbstractArray{T, 2}
    c::T
    s::T
    i::Int
    j::Int
    n::Int
end

Base.size(g::GivensMatrix) = (g.n, g.n)
Base.size(g::GivensMatrix, i::Int) = i == 1 || i == 2 ? g.n : 1
function Base.getindex(g::GivensMatrix{T}, i::Int, j::Int) where T
    @boundscheck i <= g.n && j <= g.n
    if i == j
        return i == g.i || i == g.j ? g.c : one(T)
    elseif i == g.i && j == g.j
        return g.s
    elseif i == g.j && j == g.i
        return -g.s
    else
        return i == j ? one(T) : zero(T)
    end
end

function left_mul!(A::AbstractMatrix, givens::GivensMatrix)
    for col in 1:size(A, 2)
        vi, vj = A[givens.i, col], A[givens.j, col]
        A[givens.i, col] = vi * givens.c + vj * givens.s
        A[givens.j, col] = -vi * givens.s + vj * givens.c
    end
    return A
end
function right_mul!(A::AbstractMatrix, givens::GivensMatrix)
    for row in 1:size(A, 1)
        vi, vj = A[row, givens.i], A[row, givens.j]
        A[row, givens.i] = vi * givens.c + vj * givens.s
        A[row, givens.j] = -vi * givens.s + vj * givens.c
    end
    return A
end
```

```@example qr
function givens_matrix(A, i, j)
    x, y = A[i, 1], A[j, 1]
    norm = sqrt(x^2 + y^2)
    c = x/norm
    s = y/norm
    return GivensMatrix(c, s, i, j, size(A, 1))
end
```

```@example qr
function givens_qr!(Q::AbstractMatrix, A::AbstractMatrix)
    m, n = size(A)
    if m == 1
        return Q, A
    else
        for k = m:-1:2
            g = givens_matrix(A, k-1, k)
            left_mul!(A, g)
            right_mul!(Q, g)
        end
        givens_qr!(view(Q, :, 2:m), view(A, 2:m, 2:n))
        return Q, A
    end
end
```

```@repl qr
@testset "givens QR" begin
    n = 3
    A = randn(n, n)
    R = copy(A)
    Q, R = givens_qr!(Matrix{Float64}(I, n, n), R)
    @test Q * R ≈ A
    @test Q * Q' ≈ I
    @info R
end
```

## Gram-Schmidt Orthogonalization
The Gram-Schmidt orthogonalization is a method to compute the QR factorization of a matrix $A$ by constructing an orthogonal matrix $Q$ and an upper triangular matrix $R$.

```math
q_k = \left(a_k - \sum_{i=1}^{k-1} r_{ik}q_i\right)/r_{kk}
```

```julia
function classical_gram_schmidt(A::AbstractMatrix{T}) where T
    m, n = size(A)
    Q = zeros(T, m, n)
    R = zeros(T, n, n)
    R[1, 1] = norm(view(A, :, 1))
    Q[:, 1] .= view(A, :, 1) ./ R[1, 1]
    for k = 2:n
        Q[:, k] .= view(A, :, k)
        # project z to span(A[:, 1:k-1])⊥
        for j = 1:k-1
            R[j, k] = view(Q, :, j)' * view(A, :, k)
            Q[:, k] .-= view(Q, :, j) .* R[j, k]
        end
        # normalize the k-th column
        R[k, k] = norm(view(Q, :, k))
        Q[:, k] ./= R[k, k]
    end
    return Q, R
end

@testset "classical GS" begin
    n = 10
    A = randn(n, n)
    Q, R = classical_gram_schmidt(A)
    @test Q * R ≈ A
    @test Q * Q' ≈ I
    @info R
end
```

## Modified Gram-Schmidt Orthogonalization

```julia
function modified_gram_schmidt!(A::AbstractMatrix{T}) where T
    m, n = size(A)
    Q = zeros(T, m, n)
    R = zeros(T, n, n)
    for k = 1:n
        R[k, k] = norm(view(A, :, k))
        Q[:, k] .= view(A, :, k) ./ R[k, k]
        for j = k+1:n
            R[k, j] = view(Q, :, k)' * view(A, :, j)
            A[:, j] .-= view(Q, :, k) .* R[k, j]
        end
    end
    return Q, R
end

@testset "modified GS" begin
    n = 10
    A = randn(n, n)
    Q, R = modified_gram_schmidt!(copy(A))
    @test Q * R ≈ A
    @test Q * Q' ≈ I
    @info R
end

let
    n = 100
    A = randn(n, n)
    Q1, R1 = classical_gram_schmidt(A)
    Q2, R2 = modified_gram_schmidt!(copy(A))
    @info norm(Q1' * Q1 - I)
    @info norm(Q2' * Q2 - I)
end
```