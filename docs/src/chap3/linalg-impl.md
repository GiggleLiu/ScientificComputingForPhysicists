# Matrix Computation (Implementation)

The code demos in this section could be found in GitHub repo: [ScientificComputingDemos/SimpleLinearAlgebra](https://github.com/GiggleLiu/ScientificComputingDemos/tree/main/SimpleLinearAlgebra).

# LU Factorization
## Forward-substitution
Forward substitution is an algorithm used to solve a system of linear equations with a lower triangular matrix
```math
Lx = b
```
where $L \in \mathbb{R}^{n\times n}$ is a lower triangular matrix defined as
```math
L = \left(\begin{matrix}
l_{11} & 0 & \ldots & 0\\
l_{21} & l_{22} & \ldots & 0\\
\vdots & \vdots & \ddots & \vdots\\
l_{n1} & l_{n2} & \ldots & l_{nn}
\end{matrix}\right)
```

The forward substitution can be summarized to the following algorithm
```math
x_1 = b_1/l_{11},~~~ x_i = \left(b_i - \sum_{j=1}^{i-1}l_{ij}x_j\right)/l_{ii},~~ i=2, ..., n
```

!!! note "Example"
    Consider the following system of lower triangular linear equations:
    ```math
    L = \left(\begin{matrix}
    3 & 0 & 0\\
    2 & 5 & 0\\
    1 & 4 & 2
    \end{matrix}\right)
    \left(\begin{matrix}
    x_1\\
    x_2\\
    x_3
    \end{matrix}\right) = 
    \left(\begin{matrix}
    9\\
    12\\
    13
    \end{matrix}\right)
    ```

    To solve for $x_1$, $x_2$, and $x_3$ using forward substitution, we start with the first equation:
    ```math
    3x_1 + 0x_2 + 0x_3 = 9
    ```
    Solving for $x_1$, we get $x_1 = 3$. Substituting $x = 3$ into the second equation (row), we get:
    ```math
    2(3) + 5x_2 + 0x_3 = 12
    ```
    Solving for $x_2$, we get $x_2 = (12 - 6) / 5 = 1.2$. Substituting $x = 3$ and $x_2 = 1.2$ into the third equation (row), we get:

    ```math
    1(3) + 4(1.2) + 2x_3 = 13
    ```
    Solving for $x_3$, we get $x_3 = (13 - 3 - 4(1.2)) / 2 = 1.5$. Therefore, the solution to the system of equations is:
    ```math
    x = \left(\begin{matrix}\
    3\\
    1.2\\
    1.5
    \end{matrix}\right)
    ```

## Back-substitution

Back substitution is an algorithm used to solve a system of linear equations with an upper triangular matrix
```math
Ux = b
```
where $U \in \mathbb{R}^{n\times n}$ is an upper triangular matrix defined as
```math
U = \left(\begin{matrix}
u_{11} & u_{12} & \ldots & u_{1n}\\
0 & u_{22} & \ldots & u_{2n}\\
\vdots & \vdots & \ddots & \vdots\\
0 & 0 & \ldots & u_{nn}
\end{matrix}\right)
```

The back substitution can be summarized to the following algorithm
```math
x_n = b_n/u_{nn},~~~ x_i = \left(b_i - \sum_{j=i+1}^{n}u_{ij}x_j\right)/u_{ii},~~ i=n-1, ..., 1
```
We implement the above algorithm in Julia language.

```@example qr
function back_substitution!(l::AbstractMatrix, b::AbstractVector)
    n = length(b)
    @assert size(l) == (n, n) "size mismatch"
    x = zero(b)
    # loop over columns
    for j = 1:n
        # stop if matrix is singular
        if iszero(l[j, j])
            error("The lower triangular matrix is singular!")
        end
        # compute solution component
        x[j] = b[j] / l[j, j]
        for i = j+1:n
            # update right hand side
            b[i] = b[i] - l[i, j] * x[j]
        end
    end
    return x
end
```

We can write a test for this algorithm.


```@example qr
using Test, LinearAlgebra

@testset "back substitution" begin
    # create a random lower triangular matrix
    l = LinearAlgebra.tril(randn(4, 4))
    # target vector
    b = randn(4)
    # solve the linear equation with our algorithm
    x = back_substitution!(l, copy(b))
    @test l * x ≈ b

    # The Julia's standard library `LinearAlgebra` contains a native implementation.
    x_native = LowerTriangular(l) \ b
    @test l * x_native ≈ b
end
```

## LU Factorization with Gaussian Elimination
LU decomposition is a method for solving linear equations that involves breaking down a matrix into lower and upper triangular matrices. The $LU$ decomposition of a matrix $A$ is represented as $A = LU$, where $L$ is a lower triangular matrix and $U$ is an upper triangular matrix.

### The elementary elimination matrix

An elementary elimination matrix is a matrix that is used in the process of Gaussian elimination to transform a system of linear equations into an equivalent system that is easier to solve. It is a square matrix that is obtained by performing a single elementary row operation on the identity matrix.

```math
(M_k)_{ij} = \begin{cases}
    \delta_{ij} & i= j,\\
    - a_{ik}/a_{kk} & i > j \land j = k, \\
    0 & {\rm otherwise}.
\end{cases}
```
Let $A = (a_{ij})$ be a square matrix of size $n \times n$. The $k$th elementary elimination matrix for it is defined as
```math
M_k = \left(\begin{matrix}

1 & \ldots & 0 & 0 & 0 & \ldots & 0\\
\vdots & \ddots & \vdots & \vdots & \vdots & \ddots & \vdots\\
0 & \ldots & 1 & 0 & 0 & \ldots & 0\\
0 & \ldots & 0 & 1 & 0 & \ldots & 0\\
0 & \ldots & 0 & -m_{k+1} & 1 & \ldots & 0\\
\vdots & \ddots & \vdots & \vdots & \vdots & \ddots & \vdots\\
0 & \ldots & 0 & -m_{n} & 0 & \ldots & 1\\

\end{matrix}\right)
```
where $m_i = a_{ik}/a_{kk}$.


By applying this elementary elimination matrix $M_1$ on $A$, we can obtain a new matrix with the $a_{i1}' = 0$ for all $i>1$.
```math
M_1 A = \left(\begin{matrix}
a_{11} & a_{12} & a_{13} & \ldots & a_{1n}\\
0 & a_{22}' & a_{23}' & \ldots & a_{2n}'\\
0 & a_{32}' & a_{33}' & \ldots & a_{3n}'\\
\vdots & \vdots & \vdots & \ddots & \vdots\\
0 & a_{n2}' & a_{n3}' & \ldots & a_{nn}'\\
\end{matrix}\right)
```

For $k=1,2,\ldots,n$, apply $M_k$ on $A$. We will have an upper triangular matrix.
```math
U = M_{n-1}\ldots M_1 A
```

Since $M_k$ is reversible, we have
```math
\begin{align*}
&A = LU\\
&L = M_1^{-1} M_2^{-1} \ldots M_{n-1}^{-1},
\end{align*}
```

Elementary elimination matrices have the following properties that making the above process efficient:
1. Its inverse can be computed in $O(n)$ time
   ```math
   M_k^{-1} = 2I - M_k
   ```
2. The multiplication of two elementary matrices can be computed in $O(n)$ time
   ```math
   M_k M_{k' > k} = M_k + M_{k'} - I
   ```

## Code: Elementary Elimination Matrix

```@example qr
A3 = [1 2 2; 4 4 2; 4 6 4]

function elementary_elimination_matrix(A::AbstractMatrix{T}, k::Int) where T
    n = size(A, 1)
    @assert size(A, 2) == n
    # create Elementary Elimination Matrices
    M = Matrix{Float64}(I, n, n)
    for i=k+1:n
        M[i, k] =  -A[i, k] ./ A[k, k]
    end
    return M
end
```

The elementary elimination matrix for the above matrix $A3$ eliminating the first column is

```@repl qr
elementary_elimination_matrix(A3, 1)
elementary_elimination_matrix(A3, 1) * A3
```

Verify the property 1

```@repl qr
inv(elementary_elimination_matrix(A3, 1))
```

Verify the property 2

```@repl qr
elementary_elimination_matrix(A3, 2)
inv(elementary_elimination_matrix(A3, 1)) * inv(elementary_elimination_matrix(A3, 2))
```

## Code: LU Factorization by Gaussian Elimination

A naive implementation of elimentary elimination matrix is as follows


```@example qr
function lufact_naive!(A::AbstractMatrix{T}) where T
    n = size(A, 1)
    @assert size(A, 2) == n
    M = Matrix{T}(I, n, n)
    for k=1:n-1
        m = elementary_elimination_matrix(A, k)
        M = M * inv(m)
        A .= m * A
    end
    return M, A
end

lufact_naive!(copy(A3))

@testset "naive LU factorization" begin
    A = [1 2 2; 4 4 2; 4 6 4]
    L, U = lufact_naive!(copy(A))
    @test L * U ≈ A
end
```

The above implementation has time complexity $O(n^4)$ since we did not use the sparsity of elimentary elimination matrix. A better implementation that gives $O(n^3)$ time complexity is as follows.

```@example qr
function lufact!(a::AbstractMatrix)
    n = size(a, 1)
    @assert size(a, 2) == n "size mismatch"
    m = zero(a)
    m[1:n+1:end] .+= 1
    # loop over columns
    for k=1:n-1
        # stop if pivot is zero
        if iszero(a[k, k])
            error("Gaussian elimination fails!")
        end
        # compute multipliers for current column
        for i=k+1:n
            m[i, k] = a[i, k] / a[k, k]
        end
        # apply transformation to remaining sub-matrix
        for j=k+1:n
            for i=k+1:n
                a[i,j] -= m[i,k] * a[k, j]
            end
        end
    end
    return m, triu!(a)
end

lufact(a::AbstractMatrix) = lufact!(copy(a))

@testset "LU factorization" begin
    a = randn(4, 4)
    L, U = lufact(a)
    @test istril(L)
    @test istriu(U)
    @test L * U ≈ a
end
```

We can test the performance of our implementation.

```@repl qr
A4 = randn(4, 4)

lufact(A4)
```

Julia language has a much better implementation in the standard library `LinearAlgebra`.

```@repl qr
julia_lures = lu(A4, NoPivot())  # the version we implemented above has no pivot

julia_lures.U

typeof(julia_lures)

fieldnames(julia_lures |> typeof)
```

## Pivoting technique
!!! note "How to handle small diagonal entries?"

    The above Gaussian elimination process is not stable if any diagonal entry in $A$ has a value that close to zero.
    ```@repl qr
    small_diagonal_matrix = [1e-8 1; 1 1]
    lures = lufact(small_diagonal_matrix)
    ```
    This issue is can be resolved by permuting the rows of $A$ before factorizing it.
    For example:
    ```@repl qr
    lufact(small_diagonal_matrix[end:-1:1, :])
    ```
    This technique is called pivoting.

### Partial pivoting
LU factoriazation (or Gaussian elimination) with row pivoting is defined as
```math
P A = L U
```
where $P$ is a permutation matrix.
Pivoting in Gaussian elimination is the process of selecting a pivot element in a matrix and then using it to eliminate other elements in the same column or row. The pivot element is chosen as the largest absolute value in the column, and its row is swapped with the row containing the current element being eliminated if necessary. This is done to avoid division by zero or numerical instability, and to ensure that the elimination process proceeds smoothly. Pivoting is an important step in Gaussian elimination, as it ensures that the resulting matrix is in reduced row echelon form and that the solution to the system of equations is accurate.

Let $A=(a_{ij})$ be a square matrix of size $n\times n$. The Gaussian elimination process with partial pivoting can be represented as
```math
M_{n-1}P_{n-1}\ldots M_2P_2M_1P_1 A = U
```

Here we emphsis that $P_{k}$ and $M_{j<k}$ commute.

### Complete pivoting
The complete pivoting also allows permuting columns. The LU factorization with complete pivoting is defined as
```math
P A Q = L U.
```
Complete pivoting produces better numerical stability but is also harder to implement. In most practical using cases, partial pivoting is good enough.
## Code: LU Factoriazation by Gaussian Elimination with Partial Pivoting

A Julia implementation of the Gaussian elimination with partial pivoting is

```@example qr
function lufact_pivot!(a::AbstractMatrix)
    n = size(a, 1)
    @assert size(a, 2) == n "size mismatch"
    m = zero(a)
    P = collect(1:n)
    # loop over columns
    @inbounds for k=1:n-1
        # search for pivot in current column
        val, p = findmax(x->abs(a[x, k]), k:n)
        p += k-1
        # find index p such that |a_{pk}| ≥ |a_{ik}| for k ≤ i ≤ n
        if p != k
            # swap rows k and p of matrix A
            for col = 1:n
                a[k, col], a[p, col] = a[p, col], a[k, col]
            end
            # swap rows k and p of matrix M
            for col = 1:k-1
                m[k, col], m[p, col] = m[p, col], m[k, col]
            end
            P[k], P[p] = P[p], P[k]
        end
        if iszero(a[k, k])
            # skip current column if it's already zero
            continue
        end
        # compute multipliers for current column
        m[k, k] = 1
        for i=k+1:n
            m[i, k] = a[i, k] / a[k, k]
        end
        # apply transformation to remaining sub-matrix
        for j=k+1:n
            akj = a[k, j]
            for i=k+1:n
                a[i,j] -= m[i,k] * akj
            end
        end
    end
    m[n, n] = 1
    return m, triu!(a), P
end

@testset "lufact with pivot" begin
    n = 5
    A = randn(n, n)
    L, U, P = lufact_pivot!(copy(A))
    pmat = zeros(Int, n, n)
    setindex!.(Ref(pmat), 1, 1:n, P)
    @test L ≈ lu(A).L
    @test U ≈ lu(A).U
    @test pmat * A ≈ L * U
end
```

The performance of our implementation is as follows.

```julia-repl
julia> using BenchmarkTools

julia> n = 200
200

julia> A = randn(n, n);

julia> @benchmark lufact_pivot!($A)
BenchmarkTools.Trial: 7451 samples with 1 evaluation.
 Range (min … max):  621.834 μs …  11.111 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     643.541 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   668.927 μs ± 255.808 μs  ┊ GC (mean ± σ):  0.84% ± 2.57%

     ▂█▂                                                        
  ▄▄▂███▆▄▄▅▅▅▅▄▄▃▃▃▃▃▃▃▃▃▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▁▂▂▁▂▂▁▂▂ ▃
  622 μs           Histogram: frequency by time          835 μs <

 Memory estimate: 314.31 KiB, allocs estimate: 3.

julia> n = 200
200

julia> A = randn(n, n);

julia> @benchmark lu($A)
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  247.709 μs …  11.649 ms  ┊ GC (min … max): 0.00% … 96.82%
 Time  (median):     269.583 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   318.077 μs ± 247.482 μs  ┊ GC (mean ± σ):  1.69% ±  2.69%

  ▆██▄▂▃▅▅▄▃▂▂▁ ▁                     ▁▁▁                       ▂
  ████████████████▇▇▇▆▆▇▆▆▆▆▆▄▆▅▄▄▆▄▇█████▇▆▆▆▆▆▅▆▅▄▄▆▅▄▅▄▅▄▅▅▄ █
  248 μs        Histogram: log(frequency) by time        835 μs <

 Memory estimate: 314.31 KiB, allocs estimate: 3.
```

# QR Factorization

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

# Eigenvalue/Singular value decomposition problem

The eigenvalue problem is to find the eigenvalues $\lambda$ and eigenvectors $x$ of a matrix $A$ such that

```math
Ax = \lambda x
```

## Power method

The power method is an iterative method to find the largest eigenvalue of a matrix. Let $A$ be a symmetric matrix, and $x_0$ be a random vector. The power method is defined as

```math
x_{k+1} = \frac{A x_k}{\|A x_k\|}
```

The power method converges to the eigenvector corresponding to the largest eigenvalue of $A$. Let us denote the largest two eigenvalues of $A$ as $\lambda_1$ and $\lambda_2$, the convergence rate of the power method is

```math
\left|\frac{\lambda_1}{\lambda_2}\right|^k
```

The following is an implementation of the power method.

```@example qr
function power_method(A::AbstractMatrix, k::Int)
    @assert size(A, 1) == size(A, 2)
    x = normalize!(randn(size(A, 2)))
    for _ = 1:k
        x = A * x
        normalize!(x)
    end
    return x
end
```

```@repl qr
matsize = 10
A10 = randn(matsize, matsize); A10 += A10'  # random symmetric matrix
vmax = eigen(A10).vectors[:,end]  # exact eigenvector
x = power_method(A10, 20)  # 20 iterations of power method
1-abs2(x' * vmax)  # the error
```

## Rayleigh Quotient Iteration

The Rayleigh Quotient Iteration (RQI) is an iterative method to find the eigenvalue of a matrix. The RQI is defined as

```math
x_{k+1} = \frac{(A - \sigma_k I)^{-1} x_k}{\|(A - \sigma_k I)^{-1} x_k\|}
```

where $\sigma_k = x_k^T A x_k$. The RQI converges to the eigenvector corresponding to the eigenvalue closest to $\sigma_k$. The following is an implementation of the RQI.
```@example qr
function rayleigh_quotient_iteration(A::AbstractMatrix, k::Int)
    @assert issymmetric(A) "A must be a symmetric matrix"
    x = normalize!(randn(size(A, 2)))
    for _ = 1:k
        sigma = x' * A * x
        y = (A - sigma * I) \ x
        x = normalize!(y)
    end
    return x
end
```

```@repl qr
x = rayleigh_quotient_iteration(A10, 5)  # 5 iterations of RQI
U = eigen(A10).vectors
(x' * U)'  # one should see a one-hot vector
```

## Symmetric QR decomposition

The symmetric QR decomposition is an iterative method to decompose a symmetric matrix into a tridiagonal matrix. Let $A$ be a symmetric matrix, the symmetric QR decomposition is defined as

```math
A = Q T Q^T
```

where $Q$ is an orthogonal matrix and $T$ is a tridiagonal matrix. The following is an implementation of the symmetric QR decomposition.

```@example qr
# Q is an identity matrix
function householder_trid!(Q, a)
    m, n = size(a)
    @assert m==n && size(Q, 2) == n
    if m == 2
        return Q, a
    else
        # apply householder matrix
        H = householder_e1(view(a, 2:n, 1))
        left_mul!(view(a, 2:n, :), H)
        right_mul!(view(a, :, 2:n), H')
        # update Q matrix
        right_mul!(view(Q, :, 2:n), H')
        # recurse
        householder_trid!(view(Q, :, 2:n), view(a, 2:m, 2:n))
    end
    return Q, a
end
```

```@repl qr
@testset "householder tridiagonal" begin
    n = 5
    a = randn(n, n)
    a = a + a'
    Q = Matrix{Float64}(I, n, n)
    Q, T = householder_trid!(Q, copy(a))
    @test Q * T * Q' ≈ a
end
```

The symmetric QR decomposition also includes a process to converge the tridiagonal matrix to a diagonal matrix. We refer the reader to Section 8.3 of the book "Matrix Computations" by Golub and Van Loan[^Golub2016] for more details.

## The SVD algorithm

The Singular Value Decomposition (SVD) is an algorithm to decompose a matrix into three matrices. Let $A$ be a matrix, the SVD is defined as
```math
A = U S V^\dagger
```
where $U$ and $V$ are orthogonal matrices, and $S$ is a diagonal matrix. The algorithm to compute the SVD is
1. Let $C = A^T A$,
2. Use the symmetric QR algorithm to compute $V_1^T C V_1 = {\rm diag}(\sigma_i^2)$,
3. Apply QR decomposition to $AV_1$ obtaining $U^\dagger(AV_1) = R$. Then $V = V_1 R^\dagger {\rm diag}(\sigma_i^{-1})$, and $S = {\rm diag}(\sigma_i)$.

The following is an implementation of the SVD algorithm.
```@example qr
function simple_svd(A::AbstractMatrix)
    m, n = size(A)
    @assert m >= n "m must be greater than or equal to n"
    C = A' * A
    S2, V1 = eigen(C)
    σ = sqrt.(S2)
    AV1 = A * V1
    qrres = qr(AV1)
    U = qrres.Q
    V = V1 * qrres.R' * Diagonal(inv.(σ))
    return U, Diagonal(σ), V
end
```

```@repl qr
@testset "simple SVD" begin
    m, n = 5, 3
    A = randn(m, n)
    U, S, V = simple_svd(A)
    @test U * S * V' ≈ A
    @test isapprox(U' * U, I; atol=1e-8)
    @test isapprox(V' * V, I; atol=1e-8)
end
```


# Cholesky Decomposition (Implementation)

Cholesky decomposition is a method of decomposing a positive-definite matrix into a product of a lower triangular matrix and its transpose. It is often used in solving systems of linear equations, computing the inverse of a matrix, and generating random numbers with a given covariance matrix. The Cholesky decomposition is computationally efficient and numerically stable, making it a popular choice in many applications.

Given a positive definite symmetric matrix $A\in \mathbb{R}^{n\times n}$, the Cholesky decomposition is formally defined as
```math
A = LL^T,
```
where $L$ is an upper triangular matrix.

The implementation of Cholesky decomposition is similar to LU decomposition.

```@example qr
function chol!(a::AbstractMatrix)
    n = size(a, 1)
    @assert size(a, 2) == n
    for k=1:n
        a[k, k] = sqrt(a[k, k])
        for i=k+1:n
            a[i, k] = a[i, k] / a[k, k]
        end
        for j=k+1:n
            for i=k+1:n
                a[i,j] = a[i,j] - a[i, k] * a[j, k]
            end
        end
    end
    return a
end
```

```@repl qr
@testset "cholesky" begin
    n = 10
    Q, R = qr(randn(10, 10))
    a = Q * Diagonal(rand(10)) * Q'
    L = chol!(copy(a))
    @test tril(L) * tril(L)' ≈ a
    # cholesky(a) in Julia
end
```

## References
[^Golub2016]: Golub, G.H., 2016. Matrix Computation 25, 228–234. https://doi.org/10.4037/ajcc2016979