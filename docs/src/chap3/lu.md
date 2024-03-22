# Solving linear equations by LU factorization: Bottom-up
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

```@example linalg
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


```@example linalg
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

```@example linalg
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

```@repl linalg
elementary_elimination_matrix(A3, 1)
elementary_elimination_matrix(A3, 1) * A3
```

Verify the property 1

```@repl linalg
inv(elementary_elimination_matrix(A3, 1))
```

Verify the property 2

```@repl linalg
elementary_elimination_matrix(A3, 2)
inv(elementary_elimination_matrix(A3, 1)) * inv(elementary_elimination_matrix(A3, 2))
```

## Code: LU Factorization by Gaussian Elimination

A naive implementation of elimentary elimination matrix is as follows


```@example linalg
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

```@example linalg
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

```@repl linalg
A4 = randn(4, 4)

lufact(A4)
```

Julia language has a much better implementation in the standard library `LinearAlgebra`.

```@repl linalg
julia_lures = lu(A4, NoPivot())  # the version we implemented above has no pivot

julia_lures.U

typeof(julia_lures)

fieldnames(julia_lures |> typeof)
```

## Pivoting technique
!!! note "How to handle small diagonal entries?"

    The above Gaussian elimination process is not stable if any diagonal entry in $A$ has a value that close to zero.
    ```@repl linalg
    small_diagonal_matrix = [1e-8 1; 1 1]
    lures = lufact(small_diagonal_matrix)
    ```
    This issue is can be resolved by permuting the rows of $A$ before factorizing it.
    For example:
    ```@repl linalg
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

```@example linalg
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