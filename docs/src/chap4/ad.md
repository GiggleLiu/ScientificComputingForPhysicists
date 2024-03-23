# Automatic Differentiation

using Plots

using FiniteDifferences

using BenchmarkTools

using ForwardDiff

using Enzyme

```math
\newcommand{\comment}[1]{{\bf  \color{blue}{\text{◂~ #1}}}}
```


html
<button onclick="present()"> present </button>


TableOfContents(depth=2)

# The four methods to differentiate a function"


“谁要你教，不是草头底下一个来回的回字么？”

孔乙己显出极高兴的样子，将两个指头的长指甲敲着柜台，点头说，“对呀对呀！……回字有四样写法，你知道么？”我愈不耐烦了，努着嘴走远。

孔乙己刚用指甲蘸了酒，想在柜上写字，见我毫不热心，便又叹一口气，显出极惋惜的样子。



# The history of autodiff



* 1964 ~ Robert Edwin Wengert, A simple automatic derivative evaluation program. ``\comment{first forward mode AD}``
* 1970 ~ Seppo Linnainmaa, Taylor expansion of the accumulated rounding error. ``\comment{first backward mode AD}``
* 1986 ~ Rumelhart, D. E., Hinton, G. E., and Williams, R. J., Learning representations by back-propagating errors.``\comment{bring AD to machine learning people.}``
* 1992 ~ Andreas Griewank, Achieving logarithmic growth of temporal and spatial complexity in reverse automatic differentiation. ``\comment{also known as optimal checkpointing.}``
* 2000s ~ The boom of tensor based AD frameworks for machine learning.
* 2018 ~ Re-inventing AD as differential programming ([wiki](https://en.wikipedia.org/wiki/Differentiable_programming).)
![](https://qph.fs.quoracdn.net/main-qimg-fb2f8470f2120eb49c8142b08d9c4132)
* 2020 ~ Moses, William and Churavy, Valentin, Instead of Rewriting Foreign Code for Machine Learning, Automatically Synthesize Fast Gradients ``\comment{AD on LLVM}``.


# Differentiating the Bessel function"


```math
    J_\nu(z) = \sum\limits_{n=0}^{\infty} \frac{(z/2)^\nu}{\Gamma(k+1)\Gamma(k+\nu+1)} (-z^2/4)^{n}
```


## Poorman's Bessel function"

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


In each step, the state transfer can be described as $(k_i, s_i, out_i) \rightarrow (k_{i+1}, s_{k+1}, out_{i+1})$.


let
    x = 0.0:0.01:10
    plt = plot([], []; label="", xlabel="x", ylabel="y")
    for i=0:5
        yi = poor_besselj.(i, x)
        plot!(plt, x, yi; label="J(ν=$i)", lw=2)
    end
    plt
end

@bind select_gradient_method Select(["Manual", "Forward", "Backward", "FiniteDiff"])

let
    x = 0.0:0.01:10
    plt = plot([], []; label="", xlabel="x", ylabel="y")
    for i=0:3
        yi = poor_besselj.(i, x)
        if select_gradient_method == "Forward"
            gi = [autodiff(Forward, poor_besselj, i, Enzyme.Duplicated(xi, 1.0))[1] for xi in x]
        elseif select_gradient_method == "Manual"
            gi = ((i == 0 ? -poor_besselj.(i+1, x) : poor_besselj.(i-1, x)) - poor_besselj.(i+1, x)) ./ 2
        elseif select_gradient_method == "Backward"
            gi = [autodiff(Reverse, poor_besselj, i, Enzyme.Active(xi))[1] for xi in x]
        elseif select_gradient_method == "FiniteDiff"
            gi = [autodiff(Reverse, poor_besselj, i, Enzyme.Active(xi))[1] for xi in x]
        end
        plot!(plt, x, yi; label="J(ν=$i)", lw=2, color=i)
        plot!(plt, x, gi; label="g(ν=$i)", lw=2, color=i, ls=:dash)
    end
    plt
end


# Finite difference

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


let
    b = [0.0, 1, 0, 0, 0]
    A = [i^j for i=-2:2, j=0:4]
    A' \ b
end

[i^j for i=-2:2, j=0:4]

central_fdm(5, 1)(x->poor_besselj(2, x), 0.5)

@benchmark central_fdm(5, 1)(y->poor_besselj(2, y), x) setup=(x=0.5)

# Forward mode automatic differentiation"


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


autodiff(Forward, poor_besselj, 2, Duplicated(0.5, 1.0))[1]

@benchmark autodiff(Forward, poor_besselj, 2, Duplicated(x, 1.0))[1] setup=(x=0.5)


**What if we want to compute gradients for multiple inputs?**

The computing time grows **linearly** as the number of variables that we want to differentiate. But does not grow significantly with the number of outputs.



# Reverse mode automatic differentiation


On the other side, the back-propagation can differentiate **many inputs** with respect to a **single output** efficiently"


```math
\begin{align}
    \frac{\partial \mathcal{L}}{\partial \vec y_i} = \frac{\partial \mathcal{L}}{\partial \vec y_{i+1}}&\boxed{\frac{\partial \vec y_{i+1}}{\partial \vec y_i}}\\
&\text{local jacobian?}
\end{align}
```


autodiff(Reverse, poor_besselj, 2, Enzyme.Active(0.5))[1]

@benchmark autodiff(Reverse, poor_besselj, 2, Enzyme.Active(x))[1] setup=(x=0.5)

### How to visit local Jacobians in the reversed order? "


Caching intermediate results in a stack!



# Rule based autodiff



The backward rule of the Bessel function is
```math
\begin{align}
&J'_{\nu}(z) =  \frac{J_{\nu-1}(z) - J_{\nu+1}(z) }2\\
&J'_{0}(z) =  - J_{1}(z)
\end{align}
```


0.5 * (poor_besselj(1, 0.5) - poor_besselj(3, 0.5))

@benchmark 0.5 * (poor_besselj(1, x) - poor_besselj(3, x)) setup=(x=0.5)


# Deriving the backward rule of matrix multiplication


Please check [blog](https://giggleliu.github.io/posts/2019-04-02-einsumbp/)"


## Rule based or not?


html
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



# Obtaining Hessian



Hessian is the Jacobian of the gradient. We can use **forward over backward**.



# Optimal checkpointing, towards solving the memory wall problem



# Game: Pass the ball

In each step, if you have the ball, you pick one of the following actions
1. raise your hand, and pass the ball to the next,
2. pass the ball to the next without raising your hand,
2. only if you are the last one in the queue, you can left the queue and pass the ball to those raising hands.
Otherwise, you may
1. put down your hand, or
2. do nothing.

**Goal: We require the number of raised hands being at most $m$ at the same time, please empty the queue while minimizing the number of ball passings.**

### The connection to checkpointing
* A person: a computing state $s_k$,
* The queue: a linear program $s_1, s_2, \ldots, s_n$,
* Passing ball: program running forward $s_{k}\rightarrow s_{k+1}$,
* Left queue: the gradient $g_k$ being computed,
* Rasing hand: create a checkpoint in the main memory,
* put down the hand: deallocate a checkpoint.


# Homeworks
1. Given the binomial function $\eta(\tau, \delta) = \frac{(\tau + \delta)!}{\tau!\delta!}$, show that the following statement is true.
```math
\eta(\tau,\delta) = \sum_{k=0}^\delta \eta(\tau-1,k)
```
2. Given the following program to compute the $l_2$-norm of a vector $x\in R^n$.
```julia
function poorman_norm(x::Vector{<:Real})
    nm2 = zero(real(eltype(x)))
    for i=1:length(x)
        nm2 += abs2(x[i])
    end
    ret = sqrt(nm2)
    return ret
end
```

In the program, the `abs2` and `sqrt` functions can be treated as primitive functions, which means they should not be further decomposed as more elementary functions.

### Tasks
1. Rewrite the program (on paper or with code) to implement the forward mode autodiff, where you can use the notation $\dot y \equiv (\frac{\partial y}{\partial x_i}, \frac{\partial y}{\partial x_2},\ldots \frac{\partial y}{\partial x_n})$ to denote a derivative.

**Example**
To compute the gradient of
```julia
function f(x, y)
    a = 2 * x
    b = sin(a)
    c = cos(y)
    return b + c
end
```

The forward autodiff rewritten program is
```julia
function f_forward((x, ̇̇x), (y, ̇y))
    (a, ̇a) = (2 * x, 2 * ̇x)
    (b, ̇b) = (sin(a), cos(a) .* ̇a)
    (c, ̇c) = （cos(y), -sin(y) .* ̇y）
    return (b + c, ̇b + ̇c)
end
```
2. Rewrite the program (on paper or with code) to implement the reverse mode autodiff, where you can use the notation $\overline y \equiv \frac{\partial \mathcal{L}}{\partial y}$ to denote an adjoint, $y \rightarrow T$ to denote pushing a variable to the global stack, and $y \leftarrow T$ to denote poping a variable from the global stack. In your submission, both the forward pass and backward pass should be included.
3. Estimate how many intermediate states is cached in your reverse mode autodiff program?

### Reference
* Griewank A, Walther A. Evaluating derivatives: principles and techniques of algorithmic differentiation[M]. Society for industrial and applied mathematics, 2008.

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
