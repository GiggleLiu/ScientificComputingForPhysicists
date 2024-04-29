# Sensitivity Analysis

Sensitivity analysis in linear algebra is the study of how changes in the input data or parameters of a linear system affect the output or solution of the system. It is crucial to the reliability and accuracy of numerical algorithms.

## Relative Error and Absolute Error

The relevant error in floating number system is the relative error.

* Absolute error: $\|x - \hat x\|$
* Relative error: $\frac{\|x - \hat x\|}{\|x\|}$

where $\|\cdot\|$ is a measure of size.

Floating point numbers have almost "constant" relative error, which is called the machine epsilon.

```@repl sensitivity
eps(Float64)
```

```@repl sensitivity
eps(1.0)
eps(1e10) / 1e10
eps(1e-10) / 1e-10
```

## (Relative) Condition Number

Condition number is a measure of the sensitivity of a mathematical problem to changes or errors in the input data. It is a way to quantify how much the output of a function or algorithm can vary due to small changes in the input. A high condition number indicates that the problem is ill-conditioned, meaning that small errors in the input can lead to large errors in the output. A low condition number indicates that the problem is well-conditioned, meaning that small errors in the input have little effect on the output.

In short, the (relative) condition number of an operation $f$ with input $x$ measures the relative error application power of $f$ with input $x$, which is formally defined as

```math
\lim _{\varepsilon \rightarrow 0^{+}}\,\sup _{\|\delta x\|\,\leq \,\varepsilon }{\frac {\|\delta f(x)\|/\|f(x)\|}{\|\delta x\|/\|x\|}}.
```

!!! note "Quiz: What is the condition number of the following function?"
    1. $y = \exp(x)$
    2. $a + b$
    3. $a - b$

    With the obtained result, can you explain why subtracting two big floating point numbers should be avoided?

!!! note "Quiz: The algorithm matters?"
    Consider the quadratic equation $x^2 - 2px - q$, the roots can be computed by the following two algorithms.
    1. $p - \sqrt{p^2 + q}$
    2. $\frac{-q}{p+\sqrt{p^2+q}}$

    Please explain the difference between the two algorithms.

    ```@repl sensitivi
    p, q = 12345678, 1
    p - sqrt(p^2 + q)  # numerically unstable
    -q/(p + sqrt(p^2 + q))  # numerically stable
    ```

## Condition Number of a Linear Operator

The condition number of a linear system $Ax = b$ is defined as
```math
{\rm cond}(A) = \|A\| \|A^{-1}\|
```
where the matrix $p$-norm is formally defined as
```math
\|A\|_p = \max_{x\neq 0} \frac{\|Ax\|_p}{\|x\|_p}
```
and the vector $p$-norm that defined as
```math
\|v\|_p = \left(\sum_i{|v_i|^p}\right)^{1/p}
```

Using the definition of condition number, we have
```math
\begin{align*}
{\rm cond(A, x)}&=\lim _{\varepsilon \rightarrow 0^{+}}\,\sup _{\|\delta x\|\,\leq \,\varepsilon }{\frac {\|\delta (Ax)\|/\|A x\|}{\|\delta x\|/\|x\|}}\\
&=\lim _{\varepsilon \rightarrow 0^{+}}\,\sup _{\|\delta x\|\,\leq \,\varepsilon }{\frac {\|A\delta x\|\|x\|}{\|\delta x\|\|Ax\|}}
\end{align*}
```
Let $y = Ax$, we have
```math
\begin{align*}
{\rm cond(A, x)}&=\lim _{\varepsilon \rightarrow 0^{+}}\,\sup _{\|\delta x\|\,\leq \,\varepsilon }{\frac {\|A\delta x\|\|A^{-1}y\|}{\|\delta x\|\|y\|}}\\
&=\|A\|\frac{\|A^{-1}y\|}{\|y\|}
\end{align*}
```
Suppose we want to get an upper bound for any input $x$, then using the definition of matrix norm, we have
```math
{\rm cond}(A) = \|A\|\sup_y \frac{\|A^{-1}y\|}{\|y\|} = \|A\| \|A^{-1}\|
```
Considering the fact that $\|A\|$ is the maximum singular value of $A$ and $\|A^{-1}\|$ is the reciprocal of the minimum singular value of $A$, we have
```math
{\rm cond}(A) = \frac{\sigma_{\max}(A)}{\sigma_{\min}(A)}.
```
where $\sigma_{\max}(A)$ and $\sigma_{\min}(A)$ are the maximum and minimum singular values of $A$.

An ill conditioned matrix may produce unreliable result, or the output is very sensitive to the input. The following is an example of a matrix close to singular.

```math
A = \left(\begin{matrix}
0.913 & 0.659\\
0.457 & 0.330
\end{matrix}
\right)
```

```@repl sensitivity
using LinearAlgebra
icond_matrix = [0.913 0.659; 0.457 0.330]
cond(icond_matrix)
spectrum = svd(icond_matrix).S
maximum(spectrum)/minimum(spectrum)  # the same as the condition number
```

!!! note "Numeric experiment on condition number"
    We randomly generate matrices of size $10\times 10$ and show the condition number approximately upper bounds the numeric error amplification factor of a linear equation solver.
    ```@example sensitivity
    n = 10000
    p = 2
    errors = zeros(n)
    conds = map(1:n) do k
        A = rand(10, 10)
        b = rand(10)
        dx = A \ b
        sx = Float32.(A) \ Float32.(b)
        errors[k] = (norm(sx - dx, p)/norm(dx, p)) / (norm(b-Float32.(b), p)/norm(b, p))
        cond(A, p)
    end

    # visualization
    using CairoMakie
    fig = Figure()
    ax = Axis(fig[1, 1], xlabel="condition number", ylabel="error amplification factor", limits=(1, 10000, 1, 10000), xscale=log10, yscale=log10)
    plot!(ax, conds, conds; label="condition number")
    scatter!(ax, conds, errors; label="samples")
    fig
    ```

## Issue: The Condition-Squaring Effect

The conditioning of a square linear system $Ax = b$ depends only on the matrix, while the conditioning of a least squares problem $Ax \approx b$ depends on both $A$ and $b$.

```math
A = \left(\begin{matrix}1 & 1\\ \epsilon & 0 \\ 0 & \epsilon \end{matrix}\right)
```

