# Automatic Differentiation

```@example ad
using FiniteDifferences
using BenchmarkTools
using ForwardDiff
using Enzyme
```

## A brief history of autodiff

* 1964 (**forward mode AD**) ~ Robert Edwin Wengert, A simple automatic derivative evaluation program.
* 1970 (**backward mode AD**) ~ Seppo Linnainmaa, Taylor expansion of the accumulated rounding error.
* 1986 (**AD for machine learning**) ~ Rumelhart, D. E., Hinton, G. E., and Williams, R. J., Learning representations by back-propagating errors.
* 1992 (**optimal checkpointing**) ~ Andreas Griewank, Achieving logarithmic growth of temporal and spatial complexity in reverse automatic differentiation.
* 2000s ~ The boom of tensor based AD frameworks for machine learning.
* 2018 ~ Re-inventing AD as differential programming ([wiki](https://en.wikipedia.org/wiki/Differentiable_programming).)
![](https://qph.fs.quoracdn.net/main-qimg-fb2f8470f2120eb49c8142b08d9c4132)
* 2020 (**AD on LLVM**) ~ Moses, William and Churavy, Valentin, Instead of Rewriting Foreign Code for Machine Learning, Automatically Synthesize Fast Gradients.

## Differentiating the Bessel function

```math
J_\nu(z) = \sum\limits_{n=0}^{\infty} \frac{(z/2)^\nu}{\Gamma(k+1)\Gamma(k+\nu+1)} (-z^2/4)^{n}
```

## Poorman's Bessel function

```@example ad
function poor_besselj(ν, z::T; atol=eps(T)) where T
    k = 0
    s = (z/2)^ν / factorial(ν)
    out = s
    while abs(s) > atol
        k += 1
        s *= (-1) / k / (k+ν) * (z/2)^2
        out += s
    end
    out
end
```

In each step, the state transfer can be described as $(k_i, s_i, out_i) \rightarrow (k_{i+1}, s_{k+1}, out_{i+1})$.

```@example ad
using CairoMakie

x = 0.0:0.01:10
plt = plot([], []; label="", xlabel="x", ylabel="y")
for i=0:5
    yi = poor_besselj.(i, x)
    plot!(plt, x, yi; label="J(ν=$i)", lw=2)
end
plt
```

```@repl ad
yi = poor_besselj.(i, x)

g_f = [autodiff(Forward, poor_besselj, i, Enzyme.Duplicated(xi, 1.0))[1] for xi in x] # forward mode
g_m = ((i == 0 ? -poor_besselj.(i+1, x) : poor_besselj.(i-1, x)) - poor_besselj.(i+1, x)) ./ 2 # manual
g_b = [autodiff(Reverse, poor_besselj, i, Enzyme.Active(xi))[1] for xi in x]
g_c = central_fdm(5, i)(x->poor_besselj(i, x), x) # central finite difference
```

```@example ad
x = 0.0:0.01:10
plt = plot([], []; label="", xlabel="x", ylabel="y")
plot!(plt, x, yi; label="J(ν=$i)", lw=2, color=i)
plot!(plt, x, gi; label="g(ν=$i)", lw=2, color=i, ls=:dash)
plt
```

## Finite difference

First order forward Difference
```math
\frac{\partial f}{\partial x} \approx \frac{f(x+\Delta) - f(x)}{\Delta}
```


First order backward Difference
```math
\frac{\partial f}{\partial x} \approx \frac{f(x) - f(x-\Delta)}{\Delta}
```


First order central Difference
```math
\frac{\partial f}{\partial x} \approx \frac{f(x+\Delta) - f(x-\Delta)}{2\Delta}
```

Table of finite difference coefficient: [wiki page](https://en.wikipedia.org/wiki/Finite_difference_coefficient).

## Example: central finite difference to the 4th order
1. Check the table

|  -2  | -1  | 0 | 1 | 2 |
| --- | --- | --- | --- | --- |
| 1/12 | −2/3 | 0 | 2/3 | −1/12 |

2. Apply the fomula
```math
\frac{\partial f}{\partial x} \approx \frac{f(x-2\Delta) - 8f(x-\Delta) + 8f(x+\Delta) - f(x+2\Delta)}{12\Delta}
```



```math
\left(\begin{matrix}
f(x-2\Delta)\\f(x-\Delta)\\f(x)\\f(x+\Delta)\\f(x+2\Delta)
\end{matrix}\right) \approx \left(\begin{matrix}
1 & (-2)^1 & (-2)^{2} & (-2)^3 &  & (-2)^4\\
1 & (-1)^1 & (-1)^{2} & (-1)^3 &  & (-1)^4\\
1 & 0 & 0 & 0 &  & 0\\
1 & (1)^1 & (1)^{2} & (1)^3 &  & (1)^4\\
1 & (2)^1 & (2)^{2} & (2)^3 &  & (2)^4
\end{matrix}\right)\left(\begin{matrix}
f(x)\\f'(x)\Delta\\f''(x)\Delta^2/2\\f'''(x)\Delta^3/6\\f''''(x)\Delta^4/24
\end{matrix}\right)
```

Let the finite difference coefficients be $\vec \alpha^T = (\alpha_{-2}, \alpha_{-1}, \alpha_{0}, \alpha_{1}, \alpha_{2})$, we want $\alpha^T \vec f= f'(x)\Delta +O(\Delta^5)$, where $\vec f=A \vec g$ is the vector on the left side. $\vec \alpha$ can be solved by $A^T \backslash (0, 1, 0, 0, 0)^T$


```@repl ad
b = [0.0, 1, 0, 0, 0]
A = [i^j for i=-2:2, j=0:4]
A' \ b

[i^j for i=-2:2, j=0:4]

central_fdm(5, 1)(x->poor_besselj(2, x), 0.5)

@benchmark central_fdm(5, 1)(y->poor_besselj(2, y), x) setup=(x=0.5)
```

## Forward mode automatic differentiation

Forward mode AD attaches a infitesimal number $\epsilon$ to a variable, when applying a function $f$, it does the following transformation
```math
\begin{align}
    f(x+g \epsilon) = f(x) + f'(x) g\epsilon + \mathcal{O}(\epsilon^2)
\end{align}
```

The higher order infinitesimal is ignored. 

**In the program**, we can define a *dual number* with two fields, just like a complex number
```
f((x, g)) = (f(x), f'(x)*g)
```

res = sin(ForwardDiff.Dual(π/4, 2.0))

res === ForwardDiff.Dual(sin(π/4), cos(π/4)*2.0)


We can apply this transformation consecutively, it reflects the chain rule.
```math
\begin{align}
\frac{\partial \vec y_{i+1}}{\partial x} &= \boxed{\frac{\partial \vec y_{i+1}}{\partial \vec y_i}}\frac{\partial \vec y_i}{\partial x}\\
&\text{local Jacobian}
\end{align}
```


**Example:** Computing two gradients $\frac{\partial z\sin x}{\partial x}$ and $\frac{\partial \sin^2x}{\partial x}$ at one sweep

```@repl ad
autodiff(Forward, poor_besselj, 2, Duplicated(0.5, 1.0))[1]

@benchmark autodiff(Forward, poor_besselj, 2, Duplicated(x, 1.0))[1] setup=(x=0.5)
```

The computing time grows **linearly** as the number of variables that we want to differentiate. But does not grow significantly with the number of outputs.

# Reverse mode automatic differentiation

On the other side, the back-propagation can differentiate **many inputs** with respect to a **single output** efficiently

```math
\begin{align}
    \frac{\partial \mathcal{L}}{\partial \vec y_i} = \frac{\partial \mathcal{L}}{\partial \vec y_{i+1}}&\boxed{\frac{\partial \vec y_{i+1}}{\partial \vec y_i}}\\
&\text{local jacobian?}
\end{align}
```

```@repl ad
autodiff(Reverse, poor_besselj, 2, Enzyme.Active(0.5))[1]

@benchmark autodiff(Reverse, poor_besselj, 2, Enzyme.Active(x))[1] setup=(x=0.5)
```

### How to visit local Jacobians in the reversed order? 


Caching intermediate results in a stack!



# Rule based autodiff



The backward rule of the Bessel function is
```math
\begin{align}
&J'_{\nu}(z) =  \frac{J_{\nu-1}(z) - J_{\nu+1}(z) }2\\
&J'_{0}(z) =  - J_{1}(z)
\end{align}
```


```@repl ad
0.5 * (poor_besselj(1, 0.5) - poor_besselj(3, 0.5))

@benchmark 0.5 * (poor_besselj(1, x) - poor_besselj(3, x)) setup=(x=0.5)
```

# Deriving the backward rule of matrix multiplication

Please check [blog](https://giggleliu.github.io/posts/2019-04-02-einsumbp/)

## Rule based or not?

```@raw html
<table>
<tr>
<th width=200></th>
<th width=300>rule based</th>
<th width=300>differential programming</th>
</tr>
<tr style="vertical-align:top">
<td>meaning</td>
<td>defining backward rules manully for functions on tensors</td>
<td>defining backward rules on a limited set of basic scalar operations, and generate gradient code using source code transformation</td>
</tr>
<tr style="vertical-align:top">
<td>pros and cons</td>
<td>
<ol>
<li style="color:green">Good tensor performance</li>
<li style="color:green">Mature machine learning ecosystem</li>
<li style="color:red">Need to define backward rules manually</li>
</ol>
</td>
<td>
<ol>
<li style="color:green">Reasonalbe scalar performance</li>
<li style="color:red">hard to utilize BLAS</li>
</ol>
</td>
<td>
</td>
</tr>
<tr style="vertical-align:top">
<td>packages</td>
<td>Jax<br>PyTorch</td>
<td><a href="http://tapenade.inria.fr:8080/tapenade/">Tapenade</a><br>
<a href="http://www.met.reading.ac.uk/clouds/adept/">Adept</a><br>
<a href="https://github.com/EnzymeAD/Enzyme">Enzyme</a>
</td>
</tr>
</table>
```

## Obtaining Hessian

Hessian is the Jacobian of the gradient. We can use **forward over backward**.

## Optimal checkpointing
The optimal checkpointing[^Griewank2008] is a technique to reduce the memory usage of the reverse mode AD. It is a trade-off between the memory and the computational cost. The optimal checkpointing is a step towards solving the memory wall problem

Given the binomial function $\eta(\tau, \delta) = \frac{(\tau + \delta)!}{\tau!\delta!}$, show that the following statement is true.
```math
\eta(\tau,\delta) = \sum_{k=0}^\delta \eta(\tau-1,k)
```

## The backward rule of matrix multiplication

Let $\mathcal{T}$ be a stack, and $x \rightarrow \mathcal{T}$ and $x\leftarrow \mathcal{T}$ be the operation of pushing and poping an element from this stack.
Given $A \in R^{l\times m}$ and $B\in R^{m\times n}$, the forward pass computation of matrix multiplication is
```math
\begin{align}
&C = A B\\
&A \rightarrow \mathcal{T}\\
&B \rightarrow \mathcal{T}\\
&\ldots
\end{align}
```

Let the adjoint of $x$ be $\overline{x} = \frac{\partial \mathcal{L}}{\partial x}$, where $\mathcal{L}$ is a real loss as the final output.
The backward pass computes
```math
\begin{align}
&\ldots\\
&B \leftarrow \mathcal{T}\\
&\overline{A} = \overline{C}B\\
&A \leftarrow \mathcal{T}\\
&\overline{B} = A\overline{C}
\end{align}
```

The rules to compute $\overline{A}$ and $\overline{B}$ are called the backward rules for matrix multiplication. They are crucial for rule based automatic differentiation.


## Deriving the backward rules

Let us introduce a small perturbation $\delta A$ on $A$ and $\delta B$ on $B$,

```math
\delta C = \delta A B + A \delta B
```

```math
\delta \mathcal{L} = {\rm tr}(\delta C^T \overline{C}) = 
{\rm tr}(\delta A^T \overline{A}) + {\rm tr}(\delta B^T \overline{B})
```

It is easy to see
```math
\delta L = {\rm tr}((\delta A B)^T \overline C) + {\rm tr}((A \delta B)^T \overline C) = 
{\rm tr}(\delta A^T \overline{A}) + {\rm tr}(\delta B^T \overline{B})
```
We have the backward rules for matrix multiplication as
```math
\begin{align}
&\overline{A} = \overline{C}B^T\\
&\overline{B} = A^T\overline{C}
\end{align}
```



# The backward rule of eigen decomposition
Ref: [https://arxiv.org/abs/1710.08717](https://arxiv.org/abs/1710.08717)

Given a symmetric matrix $A$, the eigen decomposition is

```math
A = UEU^\dagger
```

We have

```math
\overline{A} = U\left[\overline{E} + \frac{1}{2}\left(\overline{U}^\dagger U \circ F + h.c.\right)\right]U^\dagger
```

Where $F_{ij}=(E_j- E_i)^{-1}$.

If $E$ is continuous, we define the density $\rho(E) = \sum\limits_k \delta(E-E_k)=-\frac{1}{\pi}\int_k \Im[G^r(E, k)] $ (check sign!). Where $G^r(E, k) = \frac{1}{E-E_k+i\delta}$.

We have
```math
\overline{A} = U\left[\overline{E} + \frac{1}{2}\left(\overline{U}^\dagger U \circ \Re [G(E_i, E_j)] + h.c.\right)\right]U^\dagger
```

### References
[^Griewank2008]: Griewank A, Walther A. Evaluating derivatives: principles and techniques of algorithmic differentiation. Society for industrial and applied mathematics, 2008.