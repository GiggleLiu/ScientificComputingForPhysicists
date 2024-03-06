```julia
using Plots
using LinearAlgebra
using Test
using Luxor

ts = collect(0.0:0.5:10.0)

ys = [2.9, 2.7, 4.8, 5.3, 7.1, 7.6, 7.7, 7.6, 9.4, 9.0, 9.6, 10.0, 10.2, 9.7, 8.3, 8.4, 9.0, 8.3, 6.6, 6.7, 4.1]

scatter(ts, ys; label="", xlabel="t", ylabel="y", ylim=(0, 10.5))
```

```julia
A2 = [ones(length(ts)) ts ts.^2]
A2inv = pinv(A2)
x2 = pinv(A2) * ys
norm(A2 * x2 - ys)^2

let
	plt = scatter(ts, ys; xlabel="t", ylabel="y", ylim=(0, 10.5), label="data")
	tt = 0:0.1:10
	plot!(plt, tt, map(t->x2[1] + x2[2]*t + x2[3] * t^2, tt); label="fitted")
end
```

```julia
pinv(A2)
```

```julia
cond(A2)

opnorm(A2) * opnorm(pinv(A2))

maximum(svd(A2).S)/minimum(svd(A2).S)
```

```julia
let
	p = 12345678
	q = 1
	p - sqrt(p^2 + q)
end

let # more accurate
	p = 12345678
	q = 1
	q/(p + sqrt(p^2 + q))
end
```

```julia
rectQ = Matrix(qr(A2).Q)

qr(A2).R

rectQ * qr(A2).R ≈ A2
```

```julia
struct HouseholderMatrix{T} <: AbstractArray{T, 2}
	v::Vector{T}
	β::T
end
```

```julia
Base.size(A::HouseholderMatrix) = (length(A.v), length(A.v))

Base.size(A::HouseholderMatrix, i::Int) = i == 1 || i == 2 ? length(A.v) : 1

# some other methods to avoid ambiguity error

Base.inv(A::HouseholderMatrix) = A

Base.adjoint(A::HouseholderMatrix) = A

inv(A2' * A2) * A2'

A2' * A2

A2' * ys

rectQ' * rectQ

@testset "householder property" begin
	v = randn(3)
	β = 2/norm(v, 2)^2
	H = I - β * v * v'
	# symmetric
	@test H' ≈ H
	# reflexive
	@test H^2 ≈ I
	# orthogonal
	@test H' * H ≈ I
end
```

```julia
# the `mul!` interfaces can take two extra factors.
function left_mul!(B, A::HouseholderMatrix)
	B .-= (A.β .* A.v) * (A.v' * B)
	return B
end

# the `mul!` interfaces can take two extra factors.
function right_mul!(A, B::HouseholderMatrix)
	A .= A .- (A * (B.β .* B.v)) * B.v'
	return A
end

Base.getindex(A::HouseholderMatrix, i::Int, j::Int) = A.β * A.v[i] * conj(A.v[j])
```

# Review: Solving linear equations
Given $A\in \mathbb{R}^{n\times n}$ and $b \in \mathbb{R}^n$, find $x \in \mathbb{R}^n$ s.t.
```math
Ax = b
```

1. LU factorization with Gaussian Elimination (with Pivoting)
2. Sensitivity analysis: Condition number
2. Computing matrix inverse with Guass-Jordan Elimination

# Linear Least Square Problem

## Data Fitting

Given $m$ data points $(t_i, y_i)$, we wish to find the $n$-vector $x$ of parameters that gives the "best fit" to the data by the model function $f(t, x)$, with
```math
f: \mathbb{R}^{n+1} \rightarrow \mathbb{R}
```
```math
\min_x\sum_{i=1}^m (y_i - f(t_i, x))^2
```

## Example

```math
f(x) = x_0 + x_1 t + x_2 t^2
```

```math
Ax = \left(\begin{matrix}
1 & t_1 & t_1^2\\
1 & t_2 & t_2^2\\
1 & t_3 & t_3^2\\
1 & t_4 & t_4^2\\
1 & t_5 & t_5^2\\
\vdots & \vdots & \vdots
\end{matrix}\right)
\left(\begin{matrix} x_1 \\ x_2 \\ x_3\end{matrix}\right) \approx
\left(\begin{matrix}y_1\\ y_2\\ y_3 \\ y_4 \\ y_5\\\vdots\end{matrix}\right) = b
```

# Normal Equations

The goal: minimize $\|Ax - b\|_2^2$

```math
A^T Ax = A^T b
```

## Pseudo-Inverse

```math
A^{+} = (A^T A)^{-1}A^T
```
```math
x = A^+ b
```

Pseudoinverse

The julia version

## Example

## The geometric interpretation

The residual is $b-Ax$

```math
A^T(b - Ax) = 0
```

## Solving Normal Equations with Cholesky decomposition

Step 1: Rectangular → Square
```math
A^TAx = A^T b
```

Step 2: Square → Triangular
```math
A^T A = LL^T
```

Step 3: Solve the triangular linear equation
"""

## Issue: The Condition-Squaring Effect

The conditioning of a square linear system $Ax = b$ depends only on the matrix, while the conditioning of a least squares problem $Ax \approx b$ depends on both $A$ and $b$.

```math
A = \left(\begin{matrix}1 & 1\\ \epsilon & 0 \\ 0 & \epsilon \end{matrix}\right)
```

The definition of thin matrix condition number

## The algorithm matters

$x^2 - 2px - q$

Algorithm 1:
```math
p - \sqrt{p^2 + q}
```
Algorithm 2:
```math
\frac{q}{p+\sqrt{p^2+q}}
```

# Orthogonal Transformations

```math
A = QR
```
```math
Rx = Q^{T}b
```

## Gist of QR factoriaztion by Householder reflection.

Let $H_k$ be an orthogonal matrix, i.e. $H_k^T H_k = I$
```math
H_n \ldots H_2H_1 A = R
```
```math
Q = H_1^{T} H_2 ^{T}\ldots H_n^{T}
```

## Review of Elimentary Elimination Matrix
```math
M_k = I_n  - \tau e_k^T
```
```math
\tau = \left(0, \ldots, 0, \tau_{k+1},\ldots,\tau_n\right)^T, ~~~ \tau_i = \frac{v_i}{v_k}.
```
Keys:
* Gaussian elimination is a recursive algorithm.

## Householder reflection
Let $v \in \mathbb{R}^m$ be nonzero, An $m$-by-$m$ matrix $P$ of the form
```math
P = 1-\beta vv^T, ~~~\beta = \frac{2}{v^Tv}
```
is a Householder reflection.

the picture of householder reflection

## Properties of Householder reflection

Householder reflection is symmetric and orthogonal.

## Project a vector to $e_1$

```math
P x = \beta e_1
```
```math
v = x \pm \|x\|_2 e_1
```

```julia
function householder_matrix(v::AbstractVector{T}) where T
	v = copy(v)
	v[1] -= norm(v, 2)
	return HouseholderMatrix(v, 2/norm(v, 2)^2)
end

let
	A = Float64[1 2 2; 4 4 2; 4 6 4]
	hm = householder_matrix(view(A,:,1))
	hm * A
end
```

## Triangular Least Squares Problems

## QR Factoriaztion

## Givens Rotations

```julia
function draw_vectors(initial_vector, final_vector, angle)
	@drawsvg begin
		origin()
		circle(0, 0, 100, :stroke)
		setcolor("gray")
		a, b = initial_vector
		Luxor.arrow(Point(0, 0), Point(a, -b) * 100)
		setcolor("black")
		c, d = final_vector
		Luxor.arrow(Point(0, 0), Point(c, -d) * 100)
		Luxor.text("θ = $angle", 0, 50; valign=:center, halign=:center)
	end 600 400
end
```

```julia
@bind angle Slider(0:0.03:2*3.14; show_value=true)
```

```math
G = \left(\begin{matrix}
\cos\theta & -\sin\theta\\
\sin\theta & \cos\theta
\end{matrix}\right)
```

```julia
rotation_matrix(angle) = [cos(angle) -sin(angle); sin(angle) cos(angle)]

let
	initial_vector = [1.0, 0.0]
	final_vector = rotation_matrix(angle) * initial_vector
	@info final_vector
	draw_vectors(initial_vector, final_vector, angle)
end
```

## Eliminating the $y$ element

```julia
atan(0.1, 0.5)

let
	initial_vector = randn(2)
	angle = atan(initial_vector[2], initial_vector[1])
	final_vector = rotation_matrix(-angle) * initial_vector
	draw_vectors(initial_vector, final_vector, -angle)
end
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

## Givens QR Factorization

```julia
struct GivensMatrix{T} <: AbstractArray{T, 2}
	c::T
	s::T
	i::Int
	j::Int
	n::Int
end

Base.size(g::GivensMatrix) = (g.n, g.n)

Base.size(g::GivensMatrix, i::Int) = i == 1 || i == 2 ? g.n : 1

function elementary_elimination_matrix_1(A::AbstractMatrix{T}) where T
	n = size(A, 1)
	# create Elementary Elimination Matrices
	M = Matrix{Float64}(I, n, n)
	for i=2:n
		M[i, 1] =  -A[i, 1] ./ A[1, 1]
	end
	return M
end

function lufact_naive_recur!(L, A::AbstractMatrix{T}) where T
	n = size(A, 1)
	if n == 1
		return L, A
	else
		# eliminate the first column
		m = elementary_elimination_matrix_1(A)
		L .= L * inv(m)
		A .= m * A
		# recurse
		lufact_naive_recur!(view(L, 2:n, 2:n), view(A, 2:n, 2:n))
	end
	return L, A
end

let
	A = [1 2 2; 4 4 2; 4 6 4]
	L = Matrix{Float64}(I, 3, 3)
	R = copy(A)
	lufact_naive_recur!(L, R)
	L * R ≈ A
end

function givens(A, i, j)
	x, y = A[i, 1], A[j, 1]
	norm = sqrt(x^2 + y^2)
	c = x/norm
	s = y/norm
	return GivensMatrix(c, s, i, j, size(A, 1))
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

function householder_qr!(Q::AbstractMatrix{T}, a::AbstractMatrix{T}) where T
	m, n = size(a)
	@assert size(Q, 2) == m
	if m == 1
		return Q, a
	else
		# apply householder matrix
		H = householder_matrix(view(a, :, 1))
		left_mul!(a, H)
		# update Q matrix
		right_mul!(Q, H')
		# recurse
		householder_qr!(view(Q, 1:m, 2:m), view(a, 2:m, 2:n))
	end
	return Q, a
end

@testset "householder QR" begin
	A = randn(3, 3)
	Q = Matrix{Float64}(I, 3, 3)
	R = copy(A)
	householder_qr!(Q, R)
	@info R
	@test Q * R ≈ A
	@test Q' * Q ≈ I
end

let
	A = randn(3, 3)
	g = givens(A, 2, 3)
	left_mul!(copy(A), g)
end

function givens_qr!(Q::AbstractMatrix, A::AbstractMatrix)
	m, n = size(A)
	if m == 1
		return Q, A
	else
		for k = m:-1:2
			g = givens(A, k-1, k)
			left_mul!(A, g)
			right_mul!(Q, g)
		end
		givens_qr!(view(Q, :, 2:m), view(A, 2:m, 2:n))
		return Q, A
	end
end

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

```math
q_k = \left(a_k - \sum_{i=1}^{k-1} r_{ik}q_i\right)/r_{kk}
```

## Algorithm: Classical Gram-Schmidt Orthogonalization

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

## Algorithm: Modified Gram-Schmidt Orthogonalization

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
		H = householder_matrix(view(a, 2:n, 1))
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