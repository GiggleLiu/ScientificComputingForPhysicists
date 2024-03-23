# Sparse Matrices

using LinearAlgebra, SparseArrays

using KrylovKit

using Graphs  # for generating sparse matrices

TableOfContents()

html<button onclick="present()">present</button>

some_random_matrix = reshape(1:25, 5, 5)

struct COOMatrix{T} <: AbstractArray{T, 2}   # Julia does not have a COO data type
	rowval::Vector{Int}   # row indices
	colval::Vector{Int}   # column indices
	nzval::Vector{T}  	  # values
	m::Int 				  # number of rows
	n::Int   			  # number of columns
end

Base.size(coo::COOMatrix{T}) where T = (coo.m, coo.n)

function Base.getindex(coo::COOMatrix{T}, i::Integer, j::Integer) where T
	v = zero(T)
	for (i2, j2, v2) in zip(coo.rowval, coo.colval, coo.nzval)
		if i == i2 && j == j2
			v += v2  # accumulate the value, since repeated indices are allowed.
		end
	end
	return v
end

# Overview
1. Sparse matrix representation.
    * COOrdinate (COO) format
    * Compressed Sparse Column/Row (CSC/CSR) format
2. Solving the dominant eigenvalue problem.
    * Symmetric Lanczos process
    * Anoldi process

# Sparse Matrices"

Recall that the elementary elimination matrix in Gaussian elimination has the following form."


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
where $m_i = a_i/a_k$.


The following cell is copied from notebook: `4.linearequation.jl`"


This representation requires storing $n^2$ elements, which is very memory inefficient since it has only $2n-k$ nonzero elements.


Let $A\in\mathbb{R}^{m\times n}$ be a sparse matrix, and ${\rm nnz}(A) \ll mn$ be the number of nonzero elements in $A$. Is there a universal matrix type that stores such sparse matrices efficiently?."

The answer is yes."


## COOrdinate (COO) format



The coordinate format means storing nonzero matrix elements into triples
```math
\begin{align}
&(i_1, j_1, v_1)\\
&(i_2, j_2, v_2)\\
&\vdots\\
&(i_k, j_k, v_k)
\end{align}
```

Quiz: How many bytes are required to store the matrix `demo_matrix` in the COO format?


We need to implement the [`AbstractArray` interfaces](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array)."

Base.size(coo::COOMatrix{T}, i::Int) where T = getindex((coo.m, coo.n), i)

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

demo_matrix = elementary_elimination_matrix(some_random_matrix, 3)


## Indexing a COO matrix


Element indexing requires $O({\rm nnz}(A))$ time."

coo_matrix = COOMatrix([1, 2, 3, 4, 5, 4, 5], [1, 2, 3, 4, 5, 3, 3], [1, 1, 1, 1, 1, demo_matrix[4,3], demo_matrix[5, 3]], 5, 5)

# uncomment to show the result
sizeof(coo_matrix)


## Multiplying two COO matrices


In the following example, we compute `coo_matrix * coo_matrix`."

function Base.:(*)(A::COOMatrix{T1}, B::COOMatrix{T2}) where {T1, T2}
	@assert size(A, 2) == size(B, 1)
	rowval = Int[]
	colval = Int[]
	nzval = promote_type(T1, T2)[]
	for (i, j, v) in zip(A.rowval, A.colval, A.nzval)
		for (i2, j2, v2) in zip(B.rowval, B.colval, B.nzval)
			if j == i2
				push!(rowval, i)
				push!(colval, j2)
				push!(nzval, v * v2)
			end
		end
	end
	return COOMatrix(rowval, colval, nzval, size(A, 1), size(B, 2))
end

coo_matrix * coo_matrix

demo_matrix ^ 2


Yep!



* Quiz 1: What is the time complexity of COO matrix `setindex!` (`A[i, j] += v`)?
* Quiz 2: What is the time complexity of COO matrix multiplication?



## Compressed Sparse Column (CSC) format



A CSC format sparse matrix can be constructed with the `SparseArrays.sparse` function


csc_matrix = sparse(coo_matrix.rowval, coo_matrix.colval, coo_matrix.nzval)

It contains 5 fields"

fieldnames(csc_matrix |> typeof)


The `m`, `n`, `rowval` and `nzval` have the same meaning as those in the COO format.
`colptr` is a integer vector of size $n+1$, the element of which points to the elements in `rowval` and `nzval`. Given a matrix $A \in \mathbb{R}^{m\times n}$ in the CSC format, the $j$-th column of $A$ is defined as
`A[rowval[colptr[j]:colptr[j+1]-1], j] := nzval[colptr[j]:colptr[j+1]-1]`


csc_matrix[:, 3]

The row indices of nonzero elements in the 3rd column."

rows3 = csc_matrix.rowval[csc_matrix.colptr[3]:csc_matrix.colptr[4]-1]

# or equivalently in Julia, we can use `nzrange`
csc_matrix.rowval[nzrange(csc_matrix, 3)]

The values of nonzero elements in the 3rd column."

csc_matrix.nzval[csc_matrix.colptr[3]:csc_matrix.colptr[4]-1]


## Indexing a CSC matrix



The number of operations required to index an element in the $j$-th column of a CSC matrix is linear to the nonzero elements in the $j$-th column.


# I do not want to overwrite `Base.getindex`
function my_getindex(A::SparseMatrixCSC{T}, i::Int, j::Int) where T
	for k in nzrange(A, j)
		if A.rowval[k] == i
			return A.nzval[k]
		end
	end
	return zero(T)
end

my_getindex(csc_matrix, 4, 3)


## Multiplying two CSC matrices



Multiplying two CSC matrices is much faster than multiplying two COO matrices.


function my_matmul(A::SparseMatrixCSC{T1}, B::SparseMatrixCSC{T2}) where {T1, T2}
	T = promote_type(T1, T2)
	@assert size(A, 2) == size(B, 1)
	rowval, colval, nzval = Int[], Int[], T[]
	for j2 in 1:size(B, 2)  # enumerate the columns of B
		for k2 in nzrange(B, j2)  # enumerate the rows of B
			v2 = B.nzval[k2]
			for k1 in nzrange(A, B.rowval[k2])  # enumerate the rows of A
				push!(rowval, A.rowval[k1])
				push!(colval, j2)
				push!(nzval, A.nzval[k1] * v2)
			end
		end
	end
	return sparse(rowval, colval, nzval, size(A, 1), size(B, 2))
end

my_matmul(csc_matrix, csc_matrix)

csc_matrix^2


Quiz: What is the time complexity of CSC matrix `setindex!` (`A[i, j] = v`)?


# Large sparse eigenvalue problem"


## Dominant eigenvalue problem


One can use the power method to compute dominant eigenvalues (one having the largest absolute value) of a matrix."

function power_method(A::AbstractMatrix{T}, n::Int) where T
	n = size(A, 2)
	x = normalize!(randn(n))
	for i=1:n
		x = A * x
		normalize!(x)
	end
	return x' * A * x', x
end


Since computing matrix-vector multiplication of CSC sparse matrix is fast, the power method is a convenient method to obtain the largest eigen value of a sparse matrix.


The rate of convergence is dedicated by $|\lambda_2/\lambda_1|^k$."


By inverting the sign, $A\rightarrow -A$, we can use the same method to obtain the smallest eigenvalue.


## The symmetric Lanczos process"


Let $A \in \mathbb{R}^{n \times n}$ be a large symmetric sparse matrix, the Lanczos process can be used to obtain its largest/smallest eigenvalue, with faster convergence speed comparing with the power method.



## The Krylov subspace



A Krylov subspace of size $k$ with initial vector $q_1$ is defined by
```math
\mathcal{K}(A, q_1, k) = {\rm span}\{q_1, Aq_1, A^2q_1, \ldots, A^{k-1}q_1\}
```



The Julia package `KrylovKit.jl` contains many Krylov space based algorithms.

`KrylovKit.jl` accepts general functions or callable objects as linear maps, and general Julia
objects with vector like behavior (as defined in the docs) as vectors.

The high level interface of KrylovKit is provided by the following functions:
*   `linsolve`: solve linear systems
*   `eigsolve`: find a few eigenvalues and corresponding eigenvectors
*   `geneigsolve`: find a few generalized eigenvalues and corresponding vectors
*   `svdsolve`: find a few singular values and corresponding left and right singular vectors
*   `exponentiate`: apply the exponential of a linear map to a vector
*   `expintegrator`: [exponential integrator](https://en.wikipedia.org/wiki/Exponential_integrator)
    for a linear non-homogeneous ODE, computes a linear combination of the `ϕⱼ` functions which generalize `ϕ₀(z) = exp(z)`.




## Projecting a sparse matrix into a subspace
Given $Q\in \mathbb{R}^{n\times k}$ and $Q^T Q = I$, the following statement is always true.
```math
\lambda_1(Q^T_k A Q_k) \leq \lambda_1(A),
```
where $\lambda_1(A)$ is the largest eigenvalue of $A \in \mathbb{R}^{n\times n}$.



## Lanczos Tridiagonalization

In the Lanczos tridiagonalizaiton process, we want to find a orthogonal matrix $Q^T$ such that
```math
Q^T A Q = T
```
where $T$ is a tridiagonal matrix
```math
T = \left(\begin{matrix}
\alpha_1 & \beta_1 & 0 & \ldots & 0\\
\beta_1 & \alpha_2 & \beta_2 & \ldots & 0\\
0 & \beta_2 & \alpha_3 & \ldots & 0\\
\vdots & \vdots & \vdots & \ddots & \vdots\\
0 & 0 & 0 & \beta_{k-1} & \alpha_k
\end{matrix}\right),
```
 $Q = [q_1 | q_2 | \ldots | q_n],$ and ${\rm span}(\{q_1, q_2, \ldots, q_k\}) = \mathcal{K}(A, q_1, k)$.


We have $Aq_k = \beta_{k-1}q_{k-1} + \alpha_k q_k + \beta_k q_{k+1}$, or equivalently in the recursive style
```math
q_{k+1} = (Aq_k - \beta_{k-1}q_{k-1} - \alpha_k q_k)/\beta_k.
```


By multiplying $q_k^T$ on the left, we have
```math
\alpha_k  = q_k^T A q_k.
```
Since $q_{k+1}$ is normalized, we have
```math
\beta_k = \|Aq_k - \beta_{k-1}q_{k-1} - \alpha_k q_k\|_2
```



If at any moment, $\beta_k = 0$, the interation stops due to convergence of a subspace. We have the following reducible form
```math
T(\beta_2 = 0) = \left(\begin{array}{cc|ccc}
\alpha_1 & \beta_1 & 0 & \ldots & 0\\
\beta_1 & \alpha_2 & 0 & \ldots & 0\\
\hline
0 & 0 & \alpha_3 & \ldots & 0\\
\vdots & \vdots & \vdots & \ddots & \vdots\\
0 & 0 & 0 & \beta_{k-1} & \alpha_k
\end{array}\right),
```


## A naive implementation"

function lanczos(A, q1::AbstractVector{T}; abstol, maxiter) where T
	# normalize the input vector
	q1 = normalize(q1)
	# the first iteration
	q = [q1]
	Aq1 = A * q1
	α = [q1' * Aq1]
	rk = Aq1 .- α[1] .* q1
	β = [norm(rk)]
	for k = 2:min(length(q1), maxiter)
		# the k-th orthonormal vector in Q
		push!(q, rk ./ β[k-1])
		Aqk = A * q[k]
		# compute the diagonal element as αₖ = qₖᵀ A qₖ
		push!(α, q[k]' * Aqk)
		rk = Aqk .- α[k] .* q[k] .- β[k-1] * q[k-1]
		# compute the off-diagonal element as βₖ = |rₖ|
		nrk = norm(rk)
		# break if βₖ is smaller than abstol or the maximum number of iteration is reached
		if abs(nrk) < abstol || k == length(q1)
			break
		end
		push!(β, nrk)
	end
	# returns T and Q
	return SymTridiagonal(α, β), hcat(q...)
end


## Example: using dominant eigensolver to study the spectral graph theory



Laplacian matrix
Given a simple graph $G$ with $n$ vertices $v_{1},\ldots ,v_{n}$, its Laplacian matrix $L_{n\times n}$ is defined element-wise as

```math
L_{i,j}:={\begin{cases}\deg(v_{i})&{\mbox{if}}\ i=j\\-1&{\mbox{if}}\ i\neq j\ {\mbox{and}}\ v_{i}{\mbox{ is adjacent to }}v_{j}\\0&{\mbox{otherwise}},\end{cases}}
```
or equivalently by the matrix $L=D-A$, where $D$ is the degree matrix and A is the adjacency matrix of the graph. Since $G$ is a simple graph, $A$ only contains 1s or 0s and its diagonal elements are all 0s.


Theorem: The number of connected components in the graph is the dimension of the nullspace of the Laplacian and the algebraic multiplicity of the 0 eigenvalue.


graphsize = 10

One can use the `Graphs.laplacian_matrix(graph)` to generate a laplacian matrix (CSC formated) of a graph."

lmat = laplacian_matrix(random_regular_graph(graphsize, 3))

tri, Q = lanczos(lmat, randn(graphsize); abstol=1e-8, maxiter=100)

eigen(tri).values

Q' * Q

@bind graph_size Slider(10:2:200; show_value=true, default=10)

let
	graph = random_regular_graph(graph_size, 3)
	A = laplacian_matrix(graph)
	q1 = randn(graph_size)
	tr, Q = lanczos(-A, q1; abstol=1e-8, maxiter=100)
	# using function `KrylovKit.eigsolve`
	@info "KrylovKit.eigsolve: " eigsolve(A, q1, 2, :SR)
	@info Q' * Q
	# diagonalize the triangular matrix obtained with our naive implementation
	@info "Naive approach: " eigen(-tr).values
end;

NOTE: with larger `graph_size`, you should see some "ghost" eigenvalues 


## Reorthogonalization



Let $r_0, \ldots, r_{k-1} \in \mathbb{R}_n$ be given and suppose that Householder matrices $H_0, \ldots, H_{k-1}$ have been computed such that $(H_0\ldots H_{k- 1})^T [r_0\mid\ldots\mid r_{k-1}]$ is upper triangular. Let $[q_1 \mid \ldots \mid q_k ]$ denote the first $k$ columns of the Householderproduct $(H_0 \ldots H_{k-1})$.
Then $q_k^T q_l = \delta_{kl}$ (machine precision).


**The following 4 cells are copied from notebook: 5.linear-least-square.jl**"

struct HouseholderMatrix{T} <: AbstractArray{T, 2}
	v::Vector{T}
	β::T
end

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

function householder_matrix(v::AbstractVector{T}) where T
	v = copy(v)
	v[1] -= norm(v, 2)
	return HouseholderMatrix(v, 2/norm(v, 2)^2)
end

The Lanczos algorithm with complete orthogonalization."

function lanczos_reorthogonalize(A, q1::AbstractVector{T}; abstol, maxiter) where T
	n = length(q1)
	# normalize the input vector
	q1 = normalize(q1)
	# the first iteration
	q = [q1]
	Aq1 = A * q1
	α = [q1' * Aq1]
	rk = Aq1 .- α[1] .* q1
	β = [norm(rk)]
	householders = [householder_matrix(q1)]
	for k = 2:min(n, maxiter)
		# reorthogonalize rk: 1. compute the k-th householder matrix
		for j = 1:k-1
			left_mul!(view(rk, j:n), householders[j])
		end
		push!(householders, householder_matrix(view(rk, k:n)))
		# reorthogonalize rk: 2. compute the k-th orthonormal vector in Q
		qk = zeros(T, n); qk[k] = 1  # qₖ = H₁H₂…Hₖeₖ
		for j = k:-1:1
			left_mul!(view(qk, j:n), householders[j])
		end
		push!(q, qk)
		Aqk = A * q[k]
		# compute the diagonal element as αₖ = qₖᵀ A qₖ
		push!(α, q[k]' * Aqk)
		rk = Aqk .- α[k] .* q[k] .- β[k-1] * q[k-1]
		# compute the off-diagonal element as βₖ = |rₖ|
		nrk = norm(rk)
		# break if βₖ is smaller than abstol or the maximum number of iteration is reached
		if abs(nrk) < abstol || k == n
			break
		end
		push!(β, nrk)
	end
	return SymTridiagonal(α, β), hcat(q...)
end

let
	n = 1000
	graph = random_regular_graph(n, 3)
	A = laplacian_matrix(graph)
	q1 = randn(n)
	tr, Q = lanczos_reorthogonalize(A, q1; abstol=1e-5, maxiter=100)
	@info eigsolve(A, q1, 2, :SR)
	eigen(tr)
end


## Notes on Lanczos
1. In practise, we do not store all $q$ vectors to save space.
2. Blocking technique is required if we want to compute multiple eigenvectors or a degenerate eigenvector.
2. Restarting technique can be used to improve the solution.



## The Arnoldi Process


If $A$ is not symmetric, then the orthogonal tridiagonalization $Q^T A Q = T$ does not exist in general. The Arnoldi approach involves the column by column generation of an orthogonal $Q$ such that $Q^TAQ = H$ is a Hessenberg matrix.
```math
H = \left(\begin{matrix}
h_{11} & h_{12} & h_{13} & \ldots & h_{1k}\\
h_{21} & h_{22} & h_{23} & \ldots & h_{2k}\\
0 & h_{32} & h_{33} & \ldots & h_{3k}\\
\vdots & \vdots & \vdots & \ddots & \vdots\\
0 & 0 & 0 & \ldots & h_{kk}
\end{matrix}\right)
```

That is, $h_{ij} = 0$ for $i>j+1$.


function arnoldi_iteration(A::AbstractMatrix{T}, x0::AbstractVector{T}; maxiter) where T
	h = Vector{T}[]
	q = [normalize(x0)]
	n = length(x0)
	@assert size(A) == (n, n)
	for k = 1:min(maxiter, n)
		u = A * q[k]    # generate next vector
		hk = zeros(T, k+1)
		for j = 1:k # subtract from new vector its components in all preceding vectors
			hk[j] = q[j]' * u
			u = u - hk[j] * q[j]
		end
		hkk = norm(u)
		hk[k+1] = hkk
		push!(h, hk)
		if abs(hkk) < 1e-8 || k >=n # stop if matrix is reducible
			break
		else
			push!(q, u ./ hkk)
		end
	end

	# construct `h`
	kmax = length(h)
	H = zeros(T, kmax, kmax)
	for k = 1:length(h)
		if k == kmax
			H[1:k, k] .= h[k][1:k]
		else
			H[1:k+1, k] .= h[k]
		end
	end
	return H, hcat(q...)
end

let
	n = 10
	A = randn(n, n)
	q1 = randn(n)
	h, q = arnoldi_iteration(A, q1; maxiter=100)

	# using function `KrylovKit.eigsolve`
	@info "KrylovKit.eigsolve: " eigsolve(A, q1, 2, :LR)
	# diagonalize the triangular matrix obtained with our naive implementation
	@info "Naive approach: " eigen(h).values
end;

# Assignment"


#### 1. Review
I forgot to copy the definitions of `rowindices`, `colindices` and `data` in the following code. Can you help me figure out what are their possible values?
```julia
julia> sp = sparse(rowindices, colindices, data);

julia> sp.colptr
6-element Vector{Int64}:
 1
 2
 3
 5
 6
 6

julia> sp.rowval
5-element Vector{Int64}:
 3
 1
 1
 4
 5

julia> sp.nzval
5-element Vector{Float64}:
 0.799
 0.942
 0.848
 0.164
 0.637

julia> sp.m
5

julia> sp.n
5
```



#### 2. Coding (Choose one of the following two problems):
1. (easy) Implement CSC format sparse matrix-vector multiplication as function `my_spv`. Please include the following test code into your project.
```julia
using SparseArrays, Test

@testset "sparse matrix - vector multiplication" begin
	for k = 1:100
		m, n = rand(1:100, 2)
		density = rand()
		sp = sprand(m, n, density)
		v = randn(n)
        @test Matrix(sp) * v ≈ my_spv(sp, v)
	end
end
```

2. (hard) The restarting in Lanczos is a technique technique to reduce memory. Suppose we wish to calculate the largest eigenvalue of $A$. If $q_1 \in \mathbb{R}^{n}$ is a given normalized vector, then it can be refined as follows:

Step 1. Generate $q_2,\ldots,q_s \in \mathbb{R}^{n}$ via the block Lanczos algorithm.

Step 2. Form $T_s = [ q_1 \mid \ldots \mid q_s]^TA [ q_1 \mid \ldots \mid q_s]$, an s-by-s matrix.

Step 3. Compute an orthogonal matrix $U = [ u_1 \mid \ldots\mid u_s]$ such that $U^T T_s U = {\rm diag}(\theta_1, \ldots, \theta_s)$ with $\theta_1\geq \ldots \geq\theta_s$·

Step 4. Set $q_1^{({\rm new})} = [q_1 \mid \ldots \mid q_s]u_1$.

Please implement a Lanczos tridiagonalization process with restarting as a Julia function. You submission should include that function as well as a test. 

