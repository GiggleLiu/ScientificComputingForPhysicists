# Basic Linear Algebra

## Matrix multiplication
Matrix multiplication is a fundamental operation in linear algebra. Given two matrices $A\in \mathbb{C}^{m\times n}$ and $B\in \mathbb{C}^{n\times p}$, the product $C = AB$ is defined as
```math
C_{ij} = \sum_{k=1}^n A_{ik}B_{kj}.
```
The time complexity of matrix multiplication is $O(mnp)$.

## System of Linear Equations
Let $A\in \mathbb{C}^{n\times n}$ be a invertible square matrix and $b \in \mathbb{C}^n$ be a vector. Solving a linear equation means finding a vector $x\in\mathbb{C}^n$ such that
```math
A x = b
```

One can solve a linear equation by following these steps:

1. Decompose the matrix $A \in \mathbb{C}^{n\times n}$ into $L \in \mathbb{C}^{n\times n}$ and $U \in \mathbb{C}^{n\times n}$ matrices using a method such as [Gaussian elimination](@ref) or Crout's method.

2. Rewrite the equation $Ax = b$ as $LUx = b$.

3. Solve for y in $Ly = b$ by [Forward-substitution](@ref). This involves substituting the values of $y$ into the equation one at a time, starting with the first row and working downwards.

4. Solve for $x$ in $Ux = y$ by [Back-substitution](@ref) (link TBA). This involves substituting the values of $x$ into the equation one at a time, starting with the last row and working upwards.

In Julia, we can solve a linear equation using the backslash operator `\` or the `lu` function.

```@repl linalg
A = [1 2; 3 4]
b = [2, 3.0]
```

## Least Squares Problem
The least squares problem is to find a vector $x\in\mathbb{C}^n$ that minimizes the residual
```math
\|Ax - b\|_2
```
where $A\in \mathbb{C}^{m\times n}$ and $b\in \mathbb{C}^m$. The solution to the least squares problem is given by
```math
x = (A^\dagger A)^{-1} A^\dagger b
```
when $A^\dagger A$ is invertible.

In Julia, we can solve the least squares problem using the backslash operator `\` or the `qr` function.

```@repl linalg
A = [1 2; 3 4; 5 6]
b = [2, 3.0, 4.0]
```

## Eigenvalues and Eigenvectors
The eigenvalues and eigenvectors of a matrix $A\in \mathbb{C}^{n\times n}$ are the solutions to the equation
```math
A x = \lambda x
```
where $\lambda$ is a scalar and $x$ is a non-zero vector. The eigenvalues of a matrix can be found by solving the characteristic equation
```math
\det(A - \lambda I) = 0
```
where $I$ is the identity matrix. The eigenvectors can be found by solving the equation $(A - \lambda I)x = 0$.

In Julia, we can find the eigenvalues and eigenvectors of a matrix using the `eigen` function.

```@repl linalg
A = [1 2; 3 4]
eigen(A)
```

## Singular Value Decomposition
The singular value decomposition (SVD) of a matrix $A\in \mathbb{C}^{m\times n}$ is a factorization of the form
```math
A = U \Sigma V^\dagger
```
where $U\in \mathbb{C}^{m\times m}$ and $V\in \mathbb{C}^{n\times n}$ are orthogonal matrices and $\Sigma\in \mathbb{C}^{m\times n}$ is a diagonal matrix with non-negative real numbers on the diagonal. The singular value decomposition is a generalization of the eigenvalue decomposition for non-square matrices.

In Julia, we can find the singular value decomposition of a matrix using the `svd` function.

```@repl linalg
A = [1 2; 3 4; 5 6]
svd(A)
```

## QR Decomposition
The QR decomposition of a matrix $A\in \mathbb{C}^{m\times n}$ is a factorization of the form
```math
A = QR
```
where $Q\in \mathbb{C}^{m\times m}$ is an orthogonal matrix and $R\in \mathbb{C}^{m\times n}$ is an upper triangular matrix. The QR decomposition is used to solve the linear least squares problem and to find the eigenvalues of a matrix.

In Julia, we can find the QR decomposition of a matrix using the `qr` function.

```@repl linalg
A = [1 2; 3 4; 5 6]
qr(A)
```

## Cholesky Decomposition
The Cholesky decomposition of a positive definite matrix $A\in \mathbb{C}^{n\times n}$ is a factorization of the form
```math
A = LL^\dagger
```
where $L\in \mathbb{C}^{n\times n}$ is a lower triangular matrix. The Cholesky decomposition is used to solve the linear system of equations $Ax = b$ when $A$ is symmetric and positive definite.

In Julia, we can find the Cholesky decomposition of a matrix using the `cholesky` function.

```@repl linalg
A = [2 1; 1 3]
cholesky(A)
```