# Automatic Differentiation

Automatic differentiation[^Griewank2008] is a technique to compute the derivative of a function automatically. It is a powerful tool for scientific computing, machine learning, and optimization. The automatic differentiation can be classified into two types: forward mode and backward mode. The forward mode AD computes the derivative of a function with respect to many inputs, while the backward mode AD computes the derivative of a function with respect to many outputs. The forward mode AD is efficient when the number of inputs is small, while the backward mode AD is efficient when the number of outputs is small.

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

A poorman's implementation of this Bessel function is as follows

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

Let us plot the Bessel function
```@example ad
using CairoMakie

x = 0.0:0.01:10
fig = Figure()
ax = Axis(fig[1, 1]; xlabel="x", ylabel="J(ν, x)")
for i=0:5
    yi = poor_besselj.(i, x)
    lines!(ax, x, yi; label="J(ν=$i)", linewidth=2)
end
fig
```

The derivative of the Bessel function is
```math
\frac{d J_\nu(z)}{dz} = \frac{J_{\nu-1}(z) - J_{\nu+1}(z) }2
```
In the following code, we compute the gradient of the Bessel function with respect to $\nu=2$ using different methods.
```@repl ad
using FiniteDifferences: central_fdm
using Enzyme

ν = 2
yi = poor_besselj.(ν, x)

g_f = [Enzyme.autodiff(Enzyme.Forward, poor_besselj, ν, Enzyme.Duplicated(xi, 1.0))[1] for xi in x] # forward mode
g_m = (poor_besselj.(ν-1, x) - poor_besselj.(ν+1, x)) ./ 2 # manual
g_b = [Enzyme.autodiff(Enzyme.Reverse, poor_besselj, ν, Enzyme.Active(xi))[1][2] for xi in x]
g_c = central_fdm(5, 1).(z->poor_besselj(ν, z), x) # central finite difference
```
Here, the forward and backward mode AD are implemented using the [`Enzyme`](https://github.com/EnzymeAD/Enzyme.jl) package. The manual method is the direct application of the derivative formula. The central finite difference is computed using the `central_fdm` function from the [`FiniteDifferences`](https://github.com/JuliaDiff/FiniteDifferences.jl) package.

```@example ad
fig = Figure()
ax = Axis(fig[1, 1]; xlabel="x", ylabel="y")
lines!(ax, x, yi; label="J(ν=$ν, x)", linewidth=2)
lines!(ax, x, g_b; label="g(ν=$ν, x)", linewidth=2, linestyle=:dash)
axislegend(ax)
fig
```

## Finite difference
The finite difference is a numerical method to approximate the derivative of a function. The finite difference is a simple and efficient method to compute the derivative of a function. The finite difference can be classified into three types: forward, backward, and central.

For example, the first order forward difference is
```math
\frac{\partial f}{\partial x} \approx \frac{f(x+\Delta) - f(x)}{\Delta}
```

The first order backward difference is
```math
\frac{\partial f}{\partial x} \approx \frac{f(x) - f(x-\Delta)}{\Delta}
```

The first order central difference is
```math
\frac{\partial f}{\partial x} \approx \frac{f(x+\Delta) - f(x-\Delta)}{2\Delta}
```

Among these three methods, the central difference is the most accurate. It has an error of $O(\Delta^2)$, while the forward and backward differences have an error of $O(\Delta)$.

Higher order finite differences can be found in the [wiki page](https://en.wikipedia.org/wiki/Finite_difference_coefficient).

!!! note "Example: central finite difference to the 4th order"
    The coefficients of the central finite difference to the 4th order are

    |  -2  | -1  | 0 | 1 | 2 |
    | --- | --- | --- | --- | --- |
    | 1/12 | −2/3 | 0 | 2/3 | −1/12 |

    The induced formula is
    ```math
    \frac{\partial f}{\partial x} \approx \frac{f(x-2\Delta) - 8f(x-\Delta) + 8f(x+\Delta) - f(x+2\Delta)}{12\Delta}
    ```

    In the following, we will derive this formula using the Taylor expansion.
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
    Let us denote the matrix on the right-hand side as $A$. Then we want to find the coefficients $\vec \alpha = (\alpha_{-2}, \alpha_{-1}, \alpha_{0}, \alpha_{1}, \alpha_{2})^T$ such that
    ```math
    \begin{align*}
    &\alpha_{-2}f(x-2\Delta) + \alpha_{-1}f(x-\Delta) + \alpha_{0}f(x) + \alpha_{1}f(x+\Delta) + \alpha_{2}f(x+2\Delta)\\
    & = f'(x)\Delta + O(\Delta^5),
    \end{align*}
    ```
    which can be computed by solving the linear system
    ```math
    A \vec \alpha = (0, 1, 0, 0, 0)^T.
    ```

    The following code demonstrates the central finite difference to the 4th order.
    ```@repl ad
    b = [0.0, 1, 0, 0, 0]
    A = [i^j for i=-2:2, j=0:4]
    A' \ b  # the central_fdm(5, 1) coefficients
    central_fdm(5, 1)(x->poor_besselj(2, x), 0.5)
    ```

    ```julia-repl
    julia> using BenchmarkTools

    julia> @benchmark central_fdm(5, 1)(y->poor_besselj(2, y), x) setup=(x=0.5)
    BenchmarkTools.Trial: 10000 samples with 9 evaluations.
    Range (min … max):  2.588 μs … 434.102 μs  ┊ GC (min … max): 0.00% … 98.68%
    Time  (median):     2.708 μs               ┊ GC (median):    0.00%
    Time  (mean ± σ):   2.832 μs ±   5.422 μs  ┊ GC (mean ± σ):  3.49% ±  1.96%

    ▁▂▅▆▇██▆▅▄▂▁                                               ▂
    ▇███████████████▆▆▆▅▄▅▅▄▆▄▅▇██▆▆▆▄▆▆▆▆▅▆▄▄▄▄▃▄▄▄▃▁▄▄▄▁▁▄▁▃▄ █
    2.59 μs      Histogram: log(frequency) by time      3.62 μs <

    Memory estimate: 2.47 KiB, allocs estimate: 36.
    ```
The central finite difference can be generalized to the $n$th order. The $n$th order central finite difference has an error of $O(\Delta^{n+1})$.

## Forward mode automatic differentiation

Forward mode AD attaches a infitesimal number $\epsilon$ to a variable, when applying a function $f$, it does the following transformation
```math
f(x+g \epsilon) = f(x) + f'(x) g\epsilon + \mathcal{O}(\epsilon^2)
```

The higher order infinitesimal is ignored. 

**In the program**, we can define a *dual number* with two fields, just like a complex number
```
f((x, g)) = (f(x), f'(x)*g)
```

```@repl ad
using ForwardDiff
res = sin(ForwardDiff.Dual(π/4, 2.0))
res === ForwardDiff.Dual(sin(π/4), cos(π/4)*2.0)
```


We can apply this transformation consecutively, it reflects the chain rule.
```math
\begin{align*}
\frac{\partial \vec y_{i+1}}{\partial x} &= \boxed{\frac{\partial \vec y_{i+1}}{\partial \vec y_i}}\frac{\partial \vec y_i}{\partial x}\\
&\text{local Jacobian}
\end{align*}
```


**Example:** Computing two gradients $\frac{\partial z\sin x}{\partial x}$ and $\frac{\partial \sin^2x}{\partial x}$ at one sweep

```julia-repl
julia> autodiff(Forward, poor_besselj, 2, Duplicated(0.5, 1.0))[1]
0.11985236384014333

julia> @benchmark autodiff(Forward, poor_besselj, 2, Duplicated(x, 1.0))[1] setup=(x=0.5)
BenchmarkTools.Trial: 10000 samples with 996 evaluations.
 Range (min … max):  22.256 ns … 66.349 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     23.050 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   23.290 ns ±  1.986 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▅▅  █▆▂▂▄▂▂▂▁                                               ▁
  ██▅▇██████████▅▅▄▅▅▅▅▃▄▄▄▅▆▅▅▃▄▃▄▅▄▅▄▆▅▅▄▃▂▄▃▃▂▃▄▃▄▄▃▂▂▃▂▃▃ █
  22.3 ns      Histogram: log(frequency) by time      31.8 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.
```

The computing time grows **linearly** as the number of variables that we want to differentiate. But does not grow significantly with the number of outputs.

## Reverse mode automatic differentiation

On the other side, the back-propagation can differentiate **many inputs** with respect to a **single output** efficiently

```math
\begin{align*}
    \frac{\partial \mathcal{L}}{\partial \vec y_i} = \frac{\partial \mathcal{L}}{\partial \vec y_{i+1}}&\boxed{\frac{\partial \vec y_{i+1}}{\partial \vec y_i}}\\
&\text{local jacobian?}
\end{align*}
```

```julia-repl
julia> autodiff(Enzyme.Reverse, poor_besselj, 2, Enzyme.Active(0.5))[1]
(nothing, 0.11985236384014332)

julia> @benchmark autodiff(Enzyme.Reverse, poor_besselj, 2, Enzyme.Active(x))[1] setup=(x=0.5)
BenchmarkTools.Trial: 10000 samples with 685 evaluations.
 Range (min … max):  182.482 ns … 503.771 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     208.880 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   210.059 ns ±  17.016 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▃                 ▁▁█▃                                        
  █▂▁▂▃▁▁▁▁▂▂▁▁▁▁▁▁▃████▄▃▄▄▃▂▂▃▂▃▃▃▂▂▂▂▂▂▂▁▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ▂
  182 ns           Histogram: frequency by time          260 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.
```

Computing local Jacobian directly can be expensive. In practice, we can use the back-propagation rules to update the adjoint of the variables directly. It requires the forward pass storing the intermediate variables.

## Rule based AD and source code transformation
Rule based AD is a technique to define the backward rules of the functions. The backward rules are the derivatives of the functions with respect to the inputs. The backward rules are crucial for the reverse mode AD. For example, the backward rule of the Bessel function is
```math
\begin{align*}
&J'_{\nu}(z) =  \frac{J_{\nu-1}(z) - J_{\nu+1}(z) }2\\
&J'_{0}(z) =  - J_{1}(z)
\end{align*}
```

```julia-repl
julia> 0.5 * (poor_besselj(1, 0.5) - poor_besselj(3, 0.5))
0.11985236384014333


julia> @benchmark 0.5 * (poor_besselj(1, x) - poor_besselj(3, x)) setup=(x=0.5)
BenchmarkTools.Trial: 10000 samples with 998 evaluations.
 Range (min … max):  17.576 ns … 56.947 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     17.702 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   17.999 ns ±  1.796 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▇█▃ ▁     ▁                                                 ▁
  ███▆██▆▃▅▆█▆▆▅▅▄▅▆▄▄▃▄▂▄▂▄▃▄▃▄▄▄▄▅▄▃▃▅▃▅▅▆▅▅▂▄▄▂▅▄▅▃▅▄▄▅▅▆▆ █
  17.6 ns      Histogram: log(frequency) by time      24.6 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.
```

### Rule based or not?

```@raw html
<table>
<tr>
<th width=200></th>
<th width=300>Rule based</th>
<th width=300>Source code transformation</th>
</tr>
<tr style="vertical-align:top">
<td></td>
<td>defining backward rules manully for functions on tensors</td>
<td>defining backward rules on a limited set of basic scalar operations, and generate gradient code using source code transformation</td>
</tr>
<tr style="vertical-align:top">
<td>pros and cons</td>
<td>
<ol>
<li style="color:green">Good tensor performance</li>
<li style="color:green">Mature machine learning ecosystem</li>
</ol>
</td>
<td>
<ol>
<li style="color:green">Reasonalbe scalar performance</li>
<li style="color:red">Automatically generated backward rules</li>
</ol>
</td>
<td>
</td>
</tr>
<tr style="vertical-align:top">
<td>packages</td>
<td><a href="https://jax.readthedocs.io/en/latest/">JAX</a><br>
<a href="https://pytorch.org/">PyTorch</a>
</td>
<td><a href="http://tapenade.inria.fr:8080/tapenade/">Tapenade</a><br>
<a href="http://www.met.reading.ac.uk/clouds/adept/">Adept</a><br>
<a href="https://github.com/EnzymeAD/Enzyme">Enzyme</a>
</td>
</tr>
</table>
```

## Deriving the backward rules for linear algebra

Many backward rules could be found in the notes[^Giles2008][^Seeger2017]. Here we list some of the latest improvements.

### Matrix multiplication
Let $\mathcal{T}$ be a stack, and $x \rightarrow \mathcal{T}$ and $x\leftarrow \mathcal{T}$ be the operation of pushing and poping an element from this stack.
Given $A \in R^{l\times m}$ and $B\in R^{m\times n}$, the forward pass computation of matrix multiplication is
```math
\begin{align*}
&C = A B\\
&A \rightarrow \mathcal{T}\\
&B \rightarrow \mathcal{T}\\
&\ldots
\end{align*}
```

Let the adjoint of $x$ be $\overline{x} = \frac{\partial \mathcal{L}}{\partial x}$, where $\mathcal{L}$ is a real loss as the final output.
The backward pass computes
```math
\begin{align*}
&\ldots\\
&B \leftarrow \mathcal{T}\\
&\overline{A} = \overline{C}B\\
&A \leftarrow \mathcal{T}\\
&\overline{B} = A\overline{C}
\end{align*}
```

The rules to compute $\overline{A}$ and $\overline{B}$ are called the backward rules for matrix multiplication. They are crucial for rule based automatic differentiation.


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
\begin{align*}
&\overline{A} = \overline{C}B^T\\
&\overline{B} = A^T\overline{C}
\end{align*}
```

### Einsum

### Symmetric Eigen decomposition

Given a symmetric matrix $A$, the eigen decomposition is

```math
A = UEU^\dagger
```

Where $U$ is the eigenvector matrix, and $E$ is the eigenvalue matrix. The backward rules for the symmetric eigen decomposition are[^Seeger2017]

```math
\overline{A} = U\left[\overline{E} + \frac{1}{2}\left(\overline{U}^\dagger U \circ F + h.c.\right)\right]U^\dagger
```

Where $F_{ij}=(E_j- E_i)^{-1}$.

If $E$ is continuous, we define the density $\rho(E) = \sum\limits_k \delta(E-E_k)=-\frac{1}{\pi}\int_k \Im[G^r(E, k)] $ (check sign!). Where $G^r(E, k) = \frac{1}{E-E_k+i\delta}$.

We have
```math
\overline{A} = U\left[\overline{E} + \frac{1}{2}\left(\overline{U}^\dagger U \circ \Re [G(E_i, E_j)] + h.c.\right)\right]U^\dagger
```

### Singular Value Decomposition (SVD)

*references*:

Complex valued SVD is defined as $A = USV^\dagger$. For simplicity, we consider a **full rank square matrix** $A$.
Differentiating the SVD[^Wan2019][^Francuz2023], we have

```math
dA = dUSV^\dagger + U dS V^\dagger + USdV^\dagger
```

```math
U^\dagger dA V = U^\dagger dU S + dS + SdV^\dagger V
```

Defining matrices $dC=U^\dagger dU$ and $dD = dV^\dagger V$ and $dP = U^\dagger dA V$, then we have

```math
\begin{cases}dC^\dagger+dC=0,\\dD^\dagger +dD=0\end{cases}
```

We have

```math
dP = dC S + dS + SdD
```

where $dCS$ and $SdD$ has zero real part in diagonal elements. So that $dS = \Re[{\rm diag}(dP)]$. 

```math
\begin{align*}
d\mathcal{L} &= {\rm Tr}\left[\overline{A}^TdA+\overline{A^*}^TdA^*\right]\\
&= {\rm Tr}\left[\overline{A}^TdA+dA^\dagger\overline{A}^*\right] ~~~~~~~\#rule~3
\end{align*}
```

Easy to show $\overline A_s = U^*\overline SV^T$. Notice here, $\overline A$ is the **derivative** rather than **gradient**, they are different by a conjugate, this is why we have transpose rather than conjugate here. see my [complex valued autodiff blog](https://giggleliu.github.io/2018/02/01/complex_bp.html) for detail.

Using the relations $dC^\dagger+dC=0$ and $dD^\dagger+dD=0$ 

```
\begin{cases}
dPS + SdP^\dagger &= dC S^2-S^2dC\\
SdP + dP^\dagger S &= S^2dD-dD S^2
\end{cases}
```

```math
\begin{cases}
dC = F\circ(dPS+SdP^\dagger)\\
dD = -F\circ (SdP+dP^\dagger S)
\end{cases}
```

where $F_{ij} = \frac{1}{s_j^2-s_i^2}$, easy to verify $F^T = -F$. Notice here, the relation between the imaginary diagonal parts  is lost

```math
\color{red}{\Im[I\circ dP] = \Im[I\circ(dC+dD)]}
```

This **the missing diagonal imaginary part** is definitely not trivial, but has been ignored for a long time until [@refraction-ray](https://github.com/tensorflow/tensorflow/issues/13641#issuecomment-526976200) (Shixin Zhang) mentioned and solved it. Let's first focus on the off-diagonal contributions from $dU$


```math
\begin{align*}
{\rm Tr}\overline U^TdU &= {\rm Tr} \overline U ^TU dC + \overline U^T (I-UU^\dagger) dAVS^{-1}\\
&= {\rm Tr}\overline U^T U (F\circ(dPS+SdP^\dagger))\\
 &=  {\rm Tr}(dPS+SdP^\dagger)(-F\circ (\overline U^T U)) \# rule~1,2\\
 &= {\rm Tr}(dPS+SdP^\dagger)J^T
\end{align*}
```

Here, we defined $J=F\circ(U^T\overline U)$.

```math
\begin{align*}
d\mathcal L &= {\rm Tr} (dPS+SdP^\dagger)(J+J^\dagger)^T\\
&= {\rm Tr} dPS(J+J^\dagger)^T+h.c.\\
&= {\rm Tr} U^\dagger dA V S(J+J^\dagger)^T+h.c.\\
&= {\rm Tr}\left[ VS(J+J^\dagger)^TU^\dagger\right] dA+h.c.
\end{align*}
```

By comparing with $d\mathcal L = {\rm Tr}\left[\overline{A}^TdA+h.c. \right]$, we have

```math
\bar A_U^{(\rm real)} =  \left[VS(J+J^\dagger)^TU^\dagger\right]^T\\
=U^*(J+J^\dagger)SV^T
```

#### Update: The missing diagonal imaginary part

Now let's inspect the diagonal imaginary parts of $dC$ and $dD$ in Eq. 16. At a first glance, it is not sufficient to derive $dC$ and $dD$ from $dP$, but consider there is still an information not used, **the loss must be gauge invariant**, which means

```math
\mathcal{L}(U\Lambda, S, V\Lambda)
```

Should be independent of the choice of gauge $\Lambda$, which is defined as ${\rm diag}(e^i\phi, ...)$

```math
\begin{align*}
d\mathcal{L} &={\rm Tr}[ \overline{U\Lambda}^T d(U\Lambda) +\overline  SdS+\overline{V\Lambda}^Td(V\Lambda)] + h.c.\\
&={\rm Tr}[ \overline {U\Lambda}^T (dU\Lambda+Ud\Lambda) +\overline{S}dS+  \overline{V\Lambda}^T(Vd\Lambda +dV\Lambda)] + h.c.\\
&= {\rm Tr}[(\overline{U\Lambda}^TU+\overline{V\Lambda}^TV )d\Lambda ] + \ldots + h.c.
\end{align*}
```

Gauge invariance refers to

```math
\overline{\Lambda} =  I\circ(\overline{U\Lambda}^TU+\overline{V\Lambda}^TV) = 0
```

For any $\Lambda$, where $I$ refers to the diagonal mask matrix. It is of cause valid when $\Lambda\rightarrow1$, $I\circ(\overline{U}^TU+\overline V^TV) = 0$.

Consider the contribution from the **diagonal imaginary part**, we have

```math
\begin{align*}
&{\rm Tr} [\overline U^T U (I \circ \Im [dC])+\overline V^T V (I \circ \Im [dD^\dagger])] + h.c.\\
&={\rm Tr} [ I \circ (\overline U^T U)\Im [dC]-I\circ (\overline V^T V) \Im [dD]] +h.c. ~~~~~~~~~~~~~~\#  rule 1\\
&={\rm Tr} [ I \circ (\overline U^T U)(\Im [dC]+ \Im [dD])] \\
&={\rm Tr}[I\circ (\overline U^T U) \Im[dP]S^{-1}]  \\
&={\rm Tr}[S^{-1}\Lambda_J U^{\dagger}dA V]\\
\end{align*}
```

where $\Lambda_J  = \Im[I\circ(\overline U^TU)]= \frac 1 2I\circ(\overline U^TU)-h.c.$, with $I$ the mask for diagonal part. Since only the real part contribute to $\delta \mathcal{L}$ (the imaginary part will be canceled by the Hermitian conjugate counterpart), we can safely move $\Im$ from right to left.

```math
\color{red}{\bar A_{U+V}^{(\rm imag)} = U^*\Lambda_J S^{-1}V^T}
```

When $U$ is **not full rank**, this formula should take an extra term (Ref. 2)

```math
\bar A_U^{(\rm real)} =U^*(J+J^\dagger)SV^T + (VS^{-1}\overline U^T(I-UU^\dagger))^T
```

Similarly, for $V​$ we have

```math
\overline A_V^{(\rm real)} =U^*S(K+K^\dagger)V^T + (U S^{-1} \overline V^T (I - VV^\dagger))^*,
```

where $K=F\circ(V^T\overline V)​$.

To wrap up

```math
\overline A = \overline A_U^{\rm (real)} + \overline A_S + \overline A_V^{\rm (real)} +  \overline A_{U+V}^{\rm (imag)}
```

This result can be directly used in **autograd**.

For the **gradient** used in training, one should change the convention

```math
\mathcal{\overline A} = \overline A^*,\\ \mathcal{\overline U} = \overline U^*,\\ \mathcal{\overline V}= \overline V^*.
```

This convention is used in **tensorflow**, **Zygote.jl**. Which is

```math
\begin{align*}
\mathcal{\overline A} =& U(\mathcal{J}+\mathcal{J}^\dagger)SV^\dagger + (I-UU^\dagger)\mathcal{\overline U}S^{-1}V^\dagger\\
&+ U\overline SV^\dagger\\
&+US(\mathcal{K}+\mathcal{K}^\dagger)V^\dagger + U S^{-1} \mathcal{\overline V}^\dagger (I - VV^\dagger)\\
&\color{red}{+\frac 1 2 U (I\circ(U^\dagger\overline U)-h.c.)S^{-1}V^\dagger}
\end{align*}
```

where $J=F\circ(U^\dagger\mathcal{\overline U})$ and $K=F\circ(V^\dagger \mathcal{\overline V})$.

#### Rules

rule 1. ${\rm Tr} \left[A(C\circ B\right)] = \sum A^T\circ C\circ B = {\rm Tr} ((C\circ A^T)^TB)={\rm Tr}(C^T\circ A)B$

rule2. $(C\circ A)^T = C^T \circ A^T$

rule3. When $\mathcal L$ is real, 
```math
\frac{\partial \mathcal{L}}{\partial x^*} =  \left(\frac{\partial \mathcal{L}}{\partial x}\right)^*
```

### QR decomposition

Let $A$ be a full rank matrix, the QR decomposition is defined as
```math
A = QR
```
with $Q^\dagger Q = \mathbb{I}$, so that $dQ^\dagger Q+Q^\dagger dQ=0$. $R$ is a complex upper triangular matrix, with diagonal part real.

The backward rules for QR decomposition are derived in multiple references, including [^Hubig2019] and [^Liao2019]. To derive the backward rules, we first consider differentiating the QR decomposition
```math
dA = dQR+QdR
```

$
```math
dQ = dAR^{-1}-QdRR^{-1}

```math
\begin{cases}
Q^\dagger dQ = dC - dRR^{-1}\\
dQ^\dagger Q =dC^\dagger - R^{-\dagger}dR^\dagger
\end{cases}
```

where $dC=Q^\dagger dAR^{-1}$.

Then

```math
dC+dC^\dagger = dRR^{-1} +(dRR^{-1})^\dagger
```

Notice $dR$ is upper triangular and its diag is lower triangular, this restriction gives

```math
U\circ(dC+dC^\dagger) = dRR^{-1}
```

where $U$ is a mask operator that its element value is $1$ for upper triangular part, $0.5$ for diagonal part and $0$ for lower triangular part. One should also notice here both $R$ and $dR$ has real diagonal parts, as well as the product $dRR^{-1}$.

Now let's wrap up using the Zygote convension of gradient

```math
\begin{align*}
d\mathcal L &= {\rm Tr}\left[\overline{\mathcal{Q}}^\dagger dQ+\overline{\mathcal{R}}^\dagger dR +h.c. \right]\\
&={\rm Tr}\left[\overline{\mathcal{Q}}^\dagger dA R^{-1}-\overline{\mathcal{Q}}^\dagger QdR
R^{-1}+\overline{\mathcal{R}}^\dagger dR +h.c. \right]\\
&={\rm Tr}\left[ R^{-1}\overline{\mathcal{Q}}^\dagger dA+ R^{-1}(-\overline{\mathcal{Q}}^\dagger Q +R\overline{\mathcal{R}}^\dagger) dR +h.c. \right]\\
&={\rm Tr}\left[ R^{-1}\overline{\mathcal{Q}}^\dagger dA+ R^{-1}M dR +h.c. \right]
\end{align*}
```

here, $M=R\overline{\mathcal{R}}^\dagger-\overline{\mathcal{Q}}^\dagger Q$. Plug in $dR$ we have

```math
\begin{align*}
d\mathcal{L}&={\rm Tr}\left[ R^{-1}\overline{\mathcal{Q}}^\dagger dA + M \left[U\circ(dC+dC^\dagger)\right] +h.c. \right]\\
&={\rm Tr}\left[ R^{-1}\overline{\mathcal{Q}}^\dagger dA + (M\circ L)(dC+dC^\dagger) +h.c. \right]  \;\;\# rule\; 1\\
&={\rm Tr}\left[ (R^{-1}\overline{\mathcal{Q}}^\dagger dA+h.c.) + (M\circ L)(dC + dC^\dagger)+ (M\circ L)^\dagger (dC + dC^\dagger)\right]\\
&={\rm Tr}\left[ R^{-1}\overline{\mathcal{Q}}^\dagger dA + (M\circ L+h.c.)dC + h.c.\right]\\
&={\rm Tr}\left[ R^{-1}\overline{\mathcal{Q}}^\dagger dA + (M\circ L+h.c.)Q^\dagger dAR^{-1}\right]+h.c.\\
\end{align*}
```

where $L =U^\dagger = 1-U$ is the mask of lower triangular part of a matrix.

```math
\begin{align*}
\mathcal{\overline A}^\dagger &= R^{-1}\left[\overline{\mathcal{Q}}^\dagger + (M\circ L+h.c.)Q^\dagger\right]\\
\mathcal{\overline A} &= \left[\overline{\mathcal{Q}} + Q(M\circ L+h.c.)\right]R^{-\dagger}\\
&=\left[\overline{\mathcal{Q}} + Q \texttt{copyltu}(M)\right]R^{-\dagger}
\end{align*}
```

Here, the $\texttt{copyltu}​$ takes conjugate when copying elements to upper triangular part.

## Obtaining Hessian

The second order gradient, Hessian, is also recognized as the Jacobian of the gradient. In practice, we can compute the Hessian by differentiating the gradient function with forward mode AD, which is also known as the forward-over-reverse mode AD.

## Optimal checkpointing
The main drawback of the reverse mode AD is the memory usage. The memory usage of the reverse mode AD is proportional to the number of intermediate variables, which scales linearly with the number of operations. The optimal checkpointing[^Griewank2008] is a technique to reduce the memory usage of the reverse mode AD. It is a trade-off between the memory and the computational cost. The optimal checkpointing is a step towards solving the memory wall problem

Given the binomial function $\eta(\tau, \delta) = \frac{(\tau + \delta)!}{\tau!\delta!}$, show that the following statement is true.
```math
\eta(\tau,\delta) = \sum_{k=0}^\delta \eta(\tau-1,k)
```

## References
[^Griewank2008]: Griewank A, Walther A. Evaluating derivatives: principles and techniques of algorithmic differentiation. Society for industrial and applied mathematics, 2008.
[^Wan2019]: Wan, Zhou-Quan, and Shi-Xin Zhang. "Automatic differentiation for complex valued SVD." arXiv preprint arXiv:1909.02659 (2019).
[^Francuz2023]: Francuz, Anna, Norbert Schuch, and Bram Vanhecke. "Stable and efficient differentiation of tensor network algorithms." arXiv preprint arXiv:2311.11894 (2023).
[^Seeger2017]: Seeger, Matthias, et al. "Auto-differentiating linear algebra." arXiv preprint arXiv:1710.08717 (2017).
[^Giles2008]: Giles, Mike. "An extended collection of matrix derivative results for forward and reverse mode automatic differentiation." (2008).
[^Hubig2019]: Hubig, Claudius. "Use and implementation of autodifferentiation in tensor network methods with complex scalars." arXiv preprint arXiv:1907.13422 (2019).
[^Liao2019]: Liao, Hai-Jun, et al. "Differentiable programming tensor networks." Physical Review X 9.3 (2019): 031041.