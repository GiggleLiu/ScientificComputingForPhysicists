# Eigenvalue/Singular value decomposition problem

```math
Ax = \lambda x
```

## Power method

```julia
matsize = 10

A10 = randn(matsize, matsize); A10 += A10'

eigen(A10).values

vmax = eigen(A10).vectors[:,end]

let
    x = normalize!(randn(matsize))
    for i=1:20
        x = A10 * x
        normalize!(x)
    end
    1-abs2(x' * vmax)
end
```

## Rayleigh Quotient Iteration

```julia
let
    x = normalize!(randn(matsize))
    U = eigen(A10).vectors
    for k=1:5
        sigma = x' * A10 * x
        y = (A10 - sigma * I) \ x
        x = normalize!(y)
    end
    (x' * U)'
end
```

## Symmetric QR decomposition

```julia
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

@testset "householder tridiagonal" begin
    n = 5
    a = randn(n, n)
    a = a + a'
    Q = Matrix{Float64}(I, n, n)
    Q, T = householder_trid!(Q, copy(a))
    @test Q * T * Q' ≈ a
end
```

## The SVD algorithm
```math
A = U S V^T
```
1. Form $C = A^T A$,
2. Use the symmetric QR algorithm to compute $V_1^T C V_1 = {\rm diag}(\sigma_i^2)$,
3. Apply QR with column pivoting to $AV_1$ obtaining $U^T(AV_1)\Pi = R$.

# Assignments
### 1. Review
Suppose that you are computing the QR factorization of the matrix
```math
A = \left(\begin{matrix}
1 & 1 & 1\\
1 & 2 & 4\\
1 & 3 & 9\\
1 & 4 & 16
\end{matrix}\right)
```
by Householder transformations.

* Problems:
    1. How many Householder transformations are required?
    2. What does the first column of A become as a result of applying the first Householder transformation?
    3. What does the first column of A become as a result of applying the second Householder transformation?
    4. How many Givens rotations would be required to computing the QR factoriazation of A?
### 2. Coding
Computing the QR decomposition of a symmetric triangular matrix with Givens rotation. Try to minimize the computing time and estimate the number of FLOPS.

For example, if the input matrix size is $T \in \mathbb{R}^{5\times 5}$
```math
T = \left(\begin{matrix}
t_{11} & t_{12} & 0 & 0 & 0\\
t_{21} & t_{22} & t_{23} & 0 & 0\\
0 & t_{32} & t_{33} & t_{34} & 0\\
0 & 0 & t_{43} & t_{44} & t_{45}\\
0 & 0 & 0 & t_{54} & t_{55}
\end{matrix}\right)
```
where $t_{ij} = t_{ji}$.

In your algorithm, you should first apply Givens rotation on row 1 and 2.
```math
G(t_{11}, t_{21}) T = \left(\begin{matrix}
t_{11}' & t_{12}' & t_{13}' & 0 & 0\\
0 & t_{22}' & t_{23}' & 0 & 0\\
0 & t_{32} & t_{33} & t_{34} & 0\\
0 & 0 & t_{43} & t_{44} & t_{45}\\
0 & 0 & 0 & t_{54} & t_{55}
\end{matrix}\right)
```
Then apply $G(t_{22}', t_{32})$ et al.