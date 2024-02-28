# Sensitivity Analysis

Sensitivity analysis in linear algebra is the study of how changes in the input data or parameters of a linear system affect the output or solution of the system. It involves analyzing the sensitivity of the solution to changes in the coefficients of the system, the right-hand side vector, or the constraints of the problem. Sensitivity analysis can be used to determine the effect of small changes in the input data on the optimal solution, to identify critical parameters that affect the solution, and to assess the robustness of the solution to uncertainties or variations in the input data.


## Issue: An Ill Conditioned Matrix

An ill conditioned matrix may produce unreliable result, or the output is very sensitive to the input. The following is an example of a matrix close to singular.

```math
A = \left(\begin{matrix}
0.913 & 0.659\\
0.457 & 0.330
\end{matrix}
\right)
```

```@repl linalg
ill_conditioned_matrix = [0.913 0.659; 0.457 0.330]

lures2 = lufact(ill_conditioned_matrix)

lures2

cond(ill_conditioned_matrix)
```

## The relative error

The relevant error in floating number system is the relative error.

* Absolute error: $\|x - \hat x\|$
* Relative error: $\frac{\|x - \hat x\|}{\|x\|}$


where $\|\cdot\|$ is a measure of size.


## Numeric experiment: Floating point numbers have "constant" relative error

```@repl linalg
eps(Float64)
```

```julia-repl
n = 1000
reltol = zeros(2n+1)
for i=-n:n
    f = 2.0^i
    reltol[i+n+1] = log10(eps(f)) - log10(f)
end
plot(-n:n, reltol; label="relative error")
```

```@repl linalg
eps(1.0)/1.0

eps(2.0)/2.0

eps(sqrt(2))/sqrt(2)
```

## (Relative) Condition Number


Condition number is a measure of the sensitivity of a mathematical problem to changes or errors in the input data. It is a way to quantify how much the output of a function or algorithm can vary due to small changes in the input. A high condition number indicates that the problem is ill-conditioned, meaning that small errors in the input can lead to large errors in the output. A low condition number indicates that the problem is well-conditioned, meaning that small errors in the input have little effect on the output.

In short, the (relative) condition number of an operation $f$ with input $x$ measures the relative error amplication power of $f$ with input $x$, which is formally defined as

```math
\lim _{\varepsilon \rightarrow 0^{+}}\,\sup _{\|\delta x\|\,\leq \,\varepsilon }{\frac {\|\delta f(x)\|/\|f(x)\|}{\|\delta x\|/\|x\|}}.
```

Quiz 1: What is the condition number of

```math
y = \exp(x)
```

Quiz 2: What is the condition number of

```math
a + b
```

With the obtained result, show why we should avoid subtracting two big floating point numbers?


## Measuring the size vectors and matrices"

The vector $p$-norm is formally defined as"

```math
\|v\|_p = \left(\sum_i{|v_i|^p}\right)^{1/p}
```


Similarly, the matrix $p$-norm is formally defined as
```math
\|A\|_p = \max_{x\neq 0} \frac{\|Ax\|_p}{\|x\|_p}
```


## Examples: Vector and Matrix Norms"

```@repl linalg
norm([3, 4], 2)

norm([3, 4], 1)

norm([3, 4], Inf)
```

# l0 norm is not a true norm
```@repl linalg
norm([3, 4], 0)

norm([3, 0], 0)

mat = randn(2, 2)

opnorm(mat, 1)

opnorm(mat, Inf)

opnorm(mat, 2)

opnorm(mat, 0)

cond(mat)
```

## Condition Number of a Linear Operator"

The condition number of a linear system $Ax = b$ is defined as


```math
{\rm cond}(A) = \|A\| \|A^{-1}\|
```


Using the defintion of condition number, we have
```math
\begin{align}
{\rm cond(A, x)}&=\lim _{\varepsilon \rightarrow 0^{+}}\,\sup _{\|\delta x\|\,\leq \,\varepsilon }{\frac {\|\delta (Ax)\|/\|A x\|}{\|\delta x\|/\|x\|}}\\
&=\lim _{\varepsilon \rightarrow 0^{+}}\,\sup _{\|\delta x\|\,\leq \,\varepsilon }{\frac {\|A\delta x\|\|x\|}{\|\delta x\|\|Ax\|}}
\end{align}
```
Let $y = Ax$, we have
```math
\begin{align}
{\rm cond(A, x)}&=\lim _{\varepsilon \rightarrow 0^{+}}\,\sup _{\|\delta x\|\,\leq \,\varepsilon }{\frac {\|A\delta x\|\|A^{-1}y\|}{\|\delta x\|\|y\|}}\\
&=\|A\|\frac{\|A^{-1}y\|}{\|y\|}
\end{align}
```
Suppose we want to get an upper bound for any input $x$, then using the definiton of matrix norm, we have
```math
{\rm cond}(A) = \|A\|\sup_y \frac{\|A^{-1}y\|}{\|y\|} = \|A\| \|A^{-1}\|
```


## Numeric experiment: Numeric experiment on condition number

We randomly generate matrices of size $10\times 10$ and show the condition number approximately upper bounds the numeric error amplification factor of a linear equation solver.


```@repl linalg
n = 1000
p = 2
errors = zeros(n)
conds = zeros(n)
for k = 1:n
    A = rand(10, 10)
    b = rand(10)
    dx = A \ b
    sx = Float32.(A) \ Float32.(b)
    errors[k] = (norm(sx - dx, p)/norm(dx, p)) / (norm(b-Float32.(b), p)/norm(b, p))
    conds[k] = cond(A, p)
end
plt = plot(conds, conds; label="condition number", xlim=(1, 10000), ylim=(1, 10000), xscale=:log10, yscale=:log10)
scatter!(plt, conds, errors; label="samples")
```

## Positive definite symmetric matrix"

* (Real) Symmetric: $A = A^T$,
* Positive definite: $x^T A x > 0$ for all $x \neq 0$.


## Cholesky decomposition

Cholesky decomposition is a method of decomposing a positive-definite matrix into a product of a lower triangular matrix and its transpose. It is named after the mathematician André-Louis Cholesky, who developed the method in the early 1900s. The Cholesky decomposition is useful in many areas of mathematics and science, including linear algebra, numerical analysis, and statistics. It is often used in solving systems of linear equations, computing the inverse of a matrix, and generating random numbers with a given covariance matrix. The Cholesky decomposition is computationally efficient and numerically stable, making it a popular choice in many applications.

Given a positive definite symmetric matrix $A\in \mathbb{R}^{n\times n}$, the Cholesky decomposition is formally defined as
```math
A = LL^T,
```
where $L$ is an upper triangular matrix.

The implementation of Cholesky decomposition is similar to LU decomposition.

```@repl linalg
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

@testset "cholesky" begin
	n = 10
	Q, R = qr(randn(10, 10))
	a = Q * Diagonal(rand(10)) * Q'
	L = chol!(copy(a))
	@test tril(L) * tril(L)' ≈ a
	# cholesky(a) in Julia
end
```

# Assignments
1. Get the relative condition number of division operation $a/b$.

2. Classify each of the following matrices as well-conditioned or ill-conditioned:
```math
(a). ~~\left(\begin{matrix}10^{10} & 0\\ 0 & 10^{-10}\end{matrix}\right)
```
```math
(b). ~~\left(\begin{matrix}10^{10} & 0\\ 0 & 10^{10}\end{matrix}\right)
```
```math
(c). ~~\left(\begin{matrix}10^{-10} & 0\\ 0 & 10^{-10}\end{matrix}\right)
```
```math
(d). ~~\left(\begin{matrix}1 & 2\\ 2 & 4\end{matrix}\right)
```
3. Implement the Gauss-Jordan elimination algorithm to compute matrix inverse. In the following example, we first create an augmented matrix $(A | I)$. Then we apply the Gauss-Jordan elimination matrices on the left. The final result is stored in the augmented matrix as $(I, A^{-1})$.
![](https://user-images.githubusercontent.com/6257240/222182865-c2a1aa28-946a-4acb-8df8-f5d7da93c3ee.png)

Task: Please implement a function `gauss_jordan` that computes the inverse for a matrix at any size. Please also include the following test in your submission.
```julia
@testset "Gauss Jordan" begin
	n = 10
	A = randn(n, n)
	@test gauss_jordan(A) * A ≈ Matrix{Float64}(I, n, n)
end
```

Simular to computing Guassian elimination with elementary elimination matrices, computing the inverse can be done by repreatedly applying the Guass-Jordan elimination matrix and convert the target matrix to identity.
```math
SN_{n}N_{n-1}\ldots N_1 A = I
```
Then
```math
A^{-1} = SN_{n}N_{n-1}\ldots N_1
```



Here, the Gauss-Jordan elimination matrix $N_k$ eliminates the $k$th column except the diagonal element $a_{kk}$.
```math
N_k = \left(\begin{matrix}

1 & \ldots & 0 & -m_1 & 0 & \ldots & 0\\
\vdots & \ddots & \vdots & \vdots & \vdots & \ddots & \vdots\\
0 & \ldots & 1 & -m_{k-1} & 0 & \ldots & 0\\
0 & \ldots & 0 & 1 & 0 & \ldots & 0\\
0 & \ldots & 0 & -m_{k+1} & 1 & \ldots & 0\\
\vdots & \ddots & \vdots & \vdots & \vdots & \ddots & \vdots\\
0 & \ldots & 0 & -m_{n} & 0 & \ldots & 1\\

\end{matrix}\right)
```
where $m_i = a_i/a_k$.



 $S$ is a diagonal matrix.