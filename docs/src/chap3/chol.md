# Data Fitting and Cholesky Decomposition

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

The goal is to minimize $\|Ax - b\|_2^2$, we obtain the normal equations

```math
A^T Ax = A^T b
```

To solve the normal equations, we can use the pseudoinverse

```math
\begin{align*}
&A^{+} = (A^T A)^{-1}A^T\\
&x = A^+ b
\end{align*}
```
where $A^+$ is the pseudoinverse of $A$.

The julia version

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


## Cholesky decomposition

Cholesky decomposition is a method of decomposing a positive-definite matrix into a product of a lower triangular matrix and its transpose. It is named after the mathematician André-Louis Cholesky, who developed the method in the early 1900s. The Cholesky decomposition is useful in many areas of mathematics and science, including linear algebra, numerical analysis, and statistics. It is often used in solving systems of linear equations, computing the inverse of a matrix, and generating random numbers with a given covariance matrix. The Cholesky decomposition is computationally efficient and numerically stable, making it a popular choice in many applications.

Given a positive definite symmetric matrix $A\in \mathbb{R}^{n\times n}$, the Cholesky decomposition is formally defined as
```math
A = LL^T,
```
where $L$ is an upper triangular matrix.

The implementation of Cholesky decomposition is similar to LU decomposition.

```@repl sensitivity
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

