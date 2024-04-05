# Optimization

A general continuous optimization problem has the following form
```math
\min_{\mathbf x}f(\mathbf x)~~~\text{ subject to certian constraints}
```
The constraints may be either equality or inequality constraints.

## Gradient free optimization

Gradient-free optimizers are optimization algorithms that do not rely on the gradient of the objective function to find the optimal solution. Instead, they use other methods such as Bayesian optimization, Nelder-Mead algorithm, genetic algorithms, or simulated annealing to explore the search space and find the optimal solution. These methods are particularly useful when the objective function is non-differentiable or when the gradient is difficult to compute. However, gradient-free optimizers can be slower and less efficient than gradient-based methods, especially when the search space is high-dimensional.

### Golden section search
The golden section search is a simple optimization algorithm that can be used to find the minimum of a unimodal function. A unimodal function is a function that has a single minimum within a given interval. The golden section search algorithm works by iteratively narrowing down the search interval until the minimum is found with a specified tolerance.

The Julia implementation of the golden section search algorithm is as follows:

```@example optimization
function golden_section_search(f, a, b; tol=1e-5)
    τ = (√5 - 1) / 2  # golden ratio
    x1 = a + (1 - τ) * (b - a)
    x2 = a + τ * (b - a)
    f1, f2 = f(x1), f(x2)
    k = 0
    while b - a > tol
        k += 1
        if f1 > f2
            a = x1
            x1 = x2
            f1 = f2
            x2 = a + τ * (b - a)  # update x2
            f2 = f(x2)
        else
            b = x2
            x2 = x1
            f2 = f1
            x1 = a + (1 - τ) * (b - a)  # update x1
            f1 = f(x1)
        end
    end
    return f1 < f2 ? (a, f1) : (b, f2)
end;

golden_section_search(x->(x-4)^2, -5, 5; tol=1e-5)
```

It converges to the minimum in $O(\log(\frac{b-a}{\epsilon}))$ iterations, where $\epsilon$ is the tolerance.

### The downhill simplex method - the one-dimensional case

The downhill simplex method, also known as the Nelder-Mead method, is a popular optimization algorithm that does not require the gradient of the objective function. It is a heuristic algorithm that iteratively constructs a simplex (a geometric shape with $n+1$ vertices in $n$ dimensions) and updates the vertices of the simplex to minimize the objective function. The algorithm is based on the concept of "downhill" movement, where the simplex moves towards the minimum of the objective function by iteratively evaluating the function at different points in the search space.

The following is the basic idea of the one-dimensional downhill simplex method:
1. Initialize a one dimensional simplex, evaluate the function at the end points $x_1$ and $x_2$ and assume $f(x_2) > f(x_1)$.
2. Evaluate the function at $x_c = 2x_1 - x_2$.
3. Select one of the folloing operations
    1. If $f(x_c)$ is smaller than $f(x_1)$, **flip** the simplex by doing $x_1 \leftarrow x_c$ and $x_2 \leftarrow x_1$.
    2. If $f(x_c)$ is larger than $f(x_1)$, but smaller than $f(x_2)$, then $x_2\leftarrow x_c$, goto case 3.
    3. If $f(x_c)$ is larger than $f(x_2)$, then **shrink** the simplex: evaluate $f$ on $x_d\leftarrow (x_1 + x_2)/2$, if it is larger than $f(x_1)$, then $x_2 \leftarrow x_d$, otherwise $x_1\leftarrow x_d, x_2\leftarrow x_1$.
4. Repeat step 2-3 until convergence.

```@example optimization
function simplex1d(f, x1, x2; tol=1e-6)
    # initial 1D simplex with two points
    history = [[x1, x2]]
    f1, f2 = f(x1), f(x2)
    while abs(x2 - x1) > tol
        xc = 2x1 - x2
        fc = f(xc)
        if fc < f1   # flip
            x1, f1, x2, f2 = xc, fc, x1, f1
        else         # shrink
            if fc < f2   # let the smaller one be x2.
                x2, f2 = xc, fc
            end
            xd = (x1 + x2) / 2
            fd = f(xd)
            if fd < f1   # update x1 and x2
                x1, f1, x2, f2 = xd, fd, x1, f1
            else
                x2, f2 = xd, fd
            end
        end
        push!(history, [x1, x2])
    end
    return x1, f1, history
end

simplex1d(x -> (x-1)^2, -1.0, 6.0) # optimize a simple quadratic function
```

### The Nelder-Mead method
The Nelder-Mead method for multidimensional optimization is a generalization of the one-dimensional downhill simplex method to higher dimensions. The algorithm constructs an $n$-dimensional simplex in the search space and iteratively updates the vertices of the simplex to minimize the objective function. The algorithm is based on the concept of "reflection," "expansion," "contraction," and "shrink" operations on the simplex to explore the search space efficiently.

Here is a Julia implementation:

```@example optimization
function simplex(f, x0; tol=1e-6, maxiter=1000)
    n = length(x0)
    x = zeros(n+1, n)
    fvals = zeros(n+1)
    x[1,:] = x0
    fvals[1] = f(x0)
    alpha = 1.0
    beta = 0.5
    gamma = 2.0
    for i in 1:n
        x[i+1,:] = x[i,:]
        x[i+1,i] += 1.0
        fvals[i+1] = f(x[i+1,:])
    end
    history = [x]
    for iter in 1:maxiter
        # Sort the vertices by function value
        order = sortperm(fvals)
        x = x[order,:]
        fvals = fvals[order]
        # Calculate the centroid of the n best vertices
        xbar = dropdims(sum(x[1:n,:], dims=1) ./ n, dims=1)
        # Reflection
        xr = xbar + alpha*(xbar - x[n+1,:])
        fr = f(xr)
        if fr < fvals[1]
            # Expansion
            xe = xbar + gamma*(xr - xbar)
            fe = f(xe)
            if fe < fr
                x[n+1,:] = xe
                fvals[n+1] = fe
            else
                x[n+1,:] = xr
                fvals[n+1] = fr
            end
        elseif fr < fvals[n]
            x[n+1,:] = xr
            fvals[n+1] = fr
        else
            # Contraction
            if fr < fvals[n+1]
                xc = xbar + beta*(x[n+1,:] - xbar)
                fc = f(xc)
                if fc < fr
                    x[n+1,:] = xc
                    fvals[n+1] = fc
                else
                    # Shrink
                    for i in 2:n+1
                        x[i,:] = x[1,:] + beta*(x[i,:] - x[1,:])
                        fvals[i] = f(x[i,:])
                    end
                end
            else
                # Shrink
                for i in 2:n+1
                    x[i,:] = x[1,:] + beta*(x[i,:] - x[1,:])
                    fvals[i] = f(x[i,:])
                end
            end
        end
        push!(history, x)
        # Check for convergence
        if maximum(abs.(x[2:end,:] .- x[1,:])) < tol && maximum(abs.(fvals[2:end] .- fvals[1])) < tol
            break
        end
    end
    # Return the best vertex and function value
    bestx = x[1,:]
    bestf = fvals[1]
    return (bestx, bestf, history)
end
```

The `simplex` function takes three arguments: the objective function `f`, the initial guess `x0`, and optional arguments for the tolerance `tol` and maximum number of iterations `maxiter`.

The algorithm initializes a simplex (a high dimensional triangle) with `n+1` vertices, where `n` is the number of dimensions of the problem. The vertices are initially set to `x0` and `x0 + h_i`, where `h_i` is a small step size in the `i`th dimension. The function values at the vertices are also calculated.

The algorithm then iteratively performs **reflection**, **expansion**, **contraction**, and **shrink** operations on the simplex until convergence is achieved. The best vertex and function value are returned.

We use the [Rosenbrock function](https://en.wikipedia.org/wiki/Rosenbrock_function) as the test function.

```@example optimization
function rosenbrock(x)
    (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
end
```

```@example optimization
using CairoMakie
x = -2:0.01:2
y = -2:0.01:2
f = [rosenbrock((a, b)) for b in y, a in x]
fig = Figure()
ax = Axis(fig[1, 1]; xlabel="x₁", ylabel="x₂")
heatmap!(ax, x, y, log.(f))
contour!(ax, x, y, f; levels=exp.(-2:2:7), labels=true, color="white", lw=0.5)
scatter!(ax, [1.0], [1.0]; color="red", marker=:star, markersize=5)
CairoMakie.text!(ax, 1.02, 0.8; text="Minimum at (1, 1)", color="black")
fig
```
    
```@example optimization
bestx, bestf, history = simplex(rosenbrock, [-1.2, -1.0]; tol=1e-3)
bestx, bestf
```

The optimization process can be visualized by plotting the simplex at each iteration.

```@raw html
<video width="560" height="480" controls>
  <source src="../../assets/images/simplex.mp4" type="video/mp4">
</video>
```

[Optim.jl](https://julianlsolvers.github.io/Optim.jl/stable/) is a Julia package for optimization algorithms. It provides a common interface for various optimization algorithms, including the Nelder-Mead method.

```@example optimization
using Optim
# Set the initial guess
x0 = [-1, -1.0]
# Set the optimization options
options = Optim.Options(iterations = 1000)
# Optimize the Rosenbrock function using the simplex method
result = optimize(rosenbrock, x0, NelderMead(), options)
# Print the optimization result
result.minimizer, result.minimum
```

## Gradient based optimization

Consider a differentiable function $f: R^n \rightarrow R$, the gradient of $f$ is defined as
```math
\nabla f(\mathbf{x}) = \left(\begin{matrix}
\frac{\partial f(\mathbf{x})}{\partial x_1}\\
\frac{\partial f(\mathbf{x})}{\partial x_2}\\
\vdots\\
\frac{\partial f(\mathbf{x})}{\partial x_n}\\
\end{matrix}\right).
```

Gradient descent is a first-order optimization algorithm that is used to find the minimum of a function. It works by iteratively moving in the direction of the negative gradient of the function at each point until convergence is achieved. The learning rate is a hyperparameter that determines the step size of the update at each iteration. At the first-order approximation, the gradient descent method can be understood as follows:
```math
f(\mathbf{x} - \epsilon \nabla f(\mathbf x)) \approx f(\mathbf x) - \epsilon \nabla f(\mathbf x)^T \nabla f(\mathbf x) = f(\mathbf x) - \epsilon \|\nabla f(\mathbf x)\|_2 < f(\mathbf{x})
```
The loss function is reduced at each iteration.

### Simple gradient descent

The update rule of gradient descent is
```math
\begin{align*}
&\theta_{t+1} = \theta_t - \alpha g_t
\end{align*}
```
where 
*  $\theta_t$ is the values of variables at time step $t$.
*  $g_t$ is the gradient at time $t$ along $\theta_t$, i.e. $\nabla_{\theta_t} f(\theta_t)$.
*  $\alpha$ is the learning rate.

In the following example, we optimize the Rosenbrock function using the gradient descent method.

```@example optimization
using ForwardDiff  # forward mode automatic differentiation
ForwardDiff.gradient(rosenbrock, [1.0, 3.0])

function gradient_descent(f, x; niters::Int, learning_rate::Real)
    history = [x]
    for i=1:niters
        g = ForwardDiff.gradient(f, x)
        x -= learning_rate * g
        push!(history, x)
    end
    return history
end

x0 = [-1, -1.0]
history = gradient_descent(rosenbrock, x0; niters=10000, learning_rate=0.002)
history[end], rosenbrock(history[end])
```
In the above example, we use the [`ForwardDiff`](https://github.com/JuliaDiff/ForwardDiff.jl) package to compute the gradient of the Rosenbrock function. The `gradient_descent` function implements the gradient descent algorithm with a specified number of iterations and learning rate.

The training history can be visualized by plotting the loss function and the optimization path.
```@example optimization
function show_history(history)
    x = -2:0.01:2
    y = -2:0.01:2
    f = [rosenbrock((a, b)) for b in y, a in x]
    fig = Figure()
    ax = Axis(fig[1, 1]; xlabel="x₁", ylabel="x₂", limits=(-2, 2, -2, 2))
    hm = heatmap!(ax, x, y, log.(f); label="log(f)")
    lines!(ax, getindex.(history, 1), getindex.(history, 2); color="white")
    scatter!(ax, getindex.(history, 1), getindex.(history, 2); color="red", markersize=3)
    CairoMakie.text!(ax, -1.8, 1.5; text="Minimum loss = $(rosenbrock(history[end]))", color="black")
    CairoMakie.text!(ax, -1.8, 1.3; text="Steps = $(length(history))", color="black")
    Colorbar(fig[1, 2], hm)
    fig
end

# plot
show_history(history)
```

The main drawback of the simple gradient descent method is that it can be slow to converge, especially for functions with complex or high-dimensional surfaces. It can also get stuck in local minima and saddle points.

### Gradient descent with momentum

We can add a "momentum" term to the weight update, which helps the optimization algorithm to move more quickly in the right direction and avoid getting stuck in local minima.

The intuition behind the momentum method can be understood by considering a ball rolling down a hill. Without momentum, the ball would roll down the hill and eventually come to a stop at the bottom. However, with momentum, the ball would continue to roll past the bottom of the hill and up the other side, before eventually coming to a stop at a higher point. This is because the momentum of the ball helps it to overcome small bumps and obstacles in its path and continue moving in the right direction.

The update rule of gradient descent with momentum is
```math
\begin{align*}
&v_{t+1} = \beta v_t - \alpha g_t\\
&\theta_{t+1} = \theta_t + v_{t+1}
\end{align*}
```
where 
*  $g_t$ is the gradient at time $t$ along $\theta_t$, i.e. $\nabla_{\theta_t} f(\theta_t)$.
*  $\alpha$ is the initial learning rate.
*  $\beta$ is the parameter for the gradient accumulation.

```@example optimization
function gradient_descent_momentum(f, x; niters::Int, β::Real, learning_rate::Real)
    history = [x]
    v = zero(x)
    for i=1:niters
        g = ForwardDiff.gradient(f, x)
        v = β .* v .- learning_rate .* g
        x += v
        push!(history, x)
    end
    return history
end

x0 = [-1, -1.0]
history = gradient_descent_momentum(rosenbrock, x0; niters=10000, learning_rate=0.002, β=0.5)

# plot
show_history(history)
```

We can see the optimization path is more direct and faster than the simple gradient descent method. However, the momentum method may overshoot the minimum and oscillate around it.

#### Adaptive Gradient Algorithm (Adagrad) 
AdaGrad is an optimization algorithm used in machine learning for solving convex optimization problems. It is a gradient-based algorithm that adapts the learning rate for each parameter based on the historical gradient information. The main idea behind AdaGrad is to give more weight to the parameters that have a smaller gradient magnitude, which allows for a larger learning rate for those parameters.

The update rule of AdaGrad is
```math
\begin{align*}
    &r_t = r_t + g_t^2\\
    &\mathbf{\eta} = \frac{\alpha}{\sqrt{r_t + \epsilon}}\\
    &\theta_{t+1} = \theta_t - \eta \odot g_t
\end{align*}
```
where 
*  $\theta_t$ is the values of variables at time $t$.
*  $\alpha$ is the initial learning rate.
*  $g_t$ is the gradient at time $t$ along $\theta_t$
*  $r_t$ is the historical squared gradient sum, which is initialized to $0$.
*  $\epsilon$ is a small positive number.
*  $\odot$ is the element-wise multiplication.

```@example optimization
function adagrad_optimize(f, x; niters, learning_rate, ϵ=1e-8)
    rt = zero(x)
    η = zero(x)
    history = [x]
    for step in 1:niters
        Δ = ForwardDiff.gradient(f, x)
        @. rt = rt + Δ .^ 2
        @. η = learning_rate ./ sqrt.(rt + ϵ)
        x = x .- Δ .* η
        push!(history, x)
    end
    return history
end

x0 = [-1, -1.0]
history = adagrad_optimize(rosenbrock, x0; niters=10000, learning_rate=1.0)

# plot
show_history(history)
```

#### Adaptive Moment Estimation (Adam)
The Adam optimizer is a popular optimization algorithm used in deep learning for training neural networks. It stands for Adaptive Moment Estimation and is a variant of stochastic gradient descent (SGD) that is designed to be more efficient and effective in finding the optimal weights for the neural network.

The Adam optimizer maintains a running estimate of the first and second moments of the gradients of the weights with respect to the loss function. These estimates are used to adaptively adjust the learning rate for each weight parameter during training. The first moment estimate is the mean of the gradients, while the second moment estimate is the uncentered variance of the gradients.

The Adam optimizer combines the benefits of two other optimization algorithms: AdaGrad, which adapts the learning rate based on the historical gradient information, and RMSProp, which uses a moving average of the squared gradients to scale the learning rate.

The Adam optimizer has become a popular choice for training deep neural networks due to its fast convergence and good generalization performance. It is widely used in many deep learning frameworks, such as TensorFlow, PyTorch, and Keras.

The update rule of Adam is
```math
\begin{align*}
&v_t = \beta_1 v_{t-1} - (1-\beta_1) g_t\\
&s_t = \beta_2 s_{t-1} - (1-\beta_2) g^2\\
&\hat v_t = v_t / (1-\beta_1^t)\\
&\hat s_t = s_t / (1-\beta_2^t)\\
&\theta_{t+1} = \theta_t -\eta \frac{\hat v_t}{\sqrt{\hat s_t} + \epsilon}
&\end{align*}
```
where
*  $\theta_t$ is the values of variables at time $t$.
*  $\eta$ is the initial learning rate.
*  $g_t$ is the gradient at time $t$ along $\theta$.
*  $v_t$ is the exponential average of gradients along $\theta$.
*  $s_t$ is the exponential average of squares of gradients along $\theta$.
*  $\beta_1, \beta_2$ are hyperparameters.

```@example optimization
function adam_optimize(f, x; niters, learning_rate, β1=0.9, β2=0.999, ϵ=1e-8)
    mt = zero(x)
    vt = zero(x)
    βp1 = β1
    βp2 = β2
    history = [x]
    for step in 1:niters
        Δ = ForwardDiff.gradient(f, x)
        @. mt = β1 * mt + (1 - β1) * Δ
        @. vt = β2 * vt + (1 - β2) * Δ^2
        @. Δ =  mt / (1 - βp1) / (√(vt / (1 - βp2)) + ϵ) * learning_rate
        βp1, βp2 = βp1 * β1, βp2 * β2
        x = x .- Δ
        push!(history, x)
    end
    return history
end

x0 = [-1, -1.0]
history = adam_optimize(rosenbrock, x0; niters=10000, learning_rate=0.01)

# plot
show_history(history)
```

#### More gradient based optimizers

The Julia package [Optimisers.jl](https://fluxml.ai/Optimisers.jl/dev/api/) contains various optimization algorithms for differentiable functions.

```@example optimization
import Optimisers

x0 = [-1, -1.0]
method = Optimisers.RMSProp(0.01)
state = Optimisers.setup(method, x0)
history = [x0]
for i=1:10000
    global x0, state
    grad = ForwardDiff.gradient(rosenbrock, x0)
    state, x0 = Optimisers.update(state, x0, grad)
    push!(history, x0)
end

# plot
show_history(history)
```

[Optimisers.jl documentation](https://fluxml.ai/Optimisers.jl/dev/api/#Optimisation-Rules) contains **stochastic** gradient based optimizers.

## Hessian based optimizers

### Newton's Method

Newton's method is an optimization algorithm used to find the roots of a function, which can also be used to find the minimum or maximum of a function. The method involves using the first and second derivatives of the function to approximate the function as a quadratic function and then finding the minimum or maximum of this quadratic function. The minimum or maximum of the quadratic function is then used as the next estimate for the minimum or maximum of the original function, and the process is repeated until convergence is achieved.



```math
\begin{align}
& H_{k}p_{k}=-g_k\\
& x_{k+1}=x_{k}+p_k
\end{align}
```
where
*  $g_k$ is the gradient at time $k$ along $x_k$.

```@example optimization
function newton_optimizer(f, x; tol=1e-5)
    k = 0
    history = [x]
    while k < 1000
        k += 1
        gk = ForwardDiff.gradient(f, x)
        hk = ForwardDiff.hessian(f, x)
        dx = -hk \ gk
        x += dx
        push!(history, x)
        sum(abs2, dx) < tol && break
    end
    return history
end

x0 = [-1, -1.0]
history = newton_optimizer(rosenbrock, x0; tol=1e-5)

# plot
show_history(history)
```

The drawback of Newton's method is, the Hessian is very expensive to compute!
While gradients can be computed with the automatic differentiation method with constant overhead. The Hessian requires $O(n)$ times more resources, where $n$ is the number of parameters.

### The Broyden–Fletcher–Goldfarb–Shanno (BFGS) algorithm


The BFGS method is a popular numerical optimization algorithm used to solve unconstrained optimization problems. It is an iterative method that seeks to find the minimum of a function by iteratively updating an estimate of the inverse Hessian matrix of the function.

The BFGS method belongs to a class of $(PlutoLecturing.highlight("quasi-Newton methods")), which means that it approximates the Hessian matrix of the function using only first-order derivative information. The BFGS method updates the inverse Hessian matrix at each iteration using information from the current and previous iterations. This allows it to converge quickly to the minimum of the function.

The BFGS method is widely used in many areas of science and engineering, including machine learning, finance, and physics. It is particularly well-suited to problems where the Hessian matrix is too large to compute directly, as it only requires first-order derivative information.

```math
\begin{align}
& B_{k}p_{k}=-g_k~~~~~~~~~~\text{// Newton method like update rule}\\
& \alpha_k = {\rm argmin} ~f(x + \alpha p_k)~~~~~~~~~~\text{// using line search}\\
& s_k=\alpha_{k}p_k\\
& x_{k+1}=x_{k}+s_k\\
&y_k=g_{k+1}-g_k\\
&B_{k+1}=B_{k}+{\frac {y_{k}y_{k}^{\mathrm {T} }}{y_{k}^{\mathrm {T} }s_{k}}}-{\frac {B_{k}s_{k}s_{k}^{\mathrm {T} }B_{k}^{\mathrm {T} }}{s_{k}^{\mathrm {T} }B_{k}s_{k}}}
\end{align}
```
where
*  $B_k$ is an approximation of the Hessian matrix, which is intialized to identity.
*  $g_k$ is the gradient at time $k$ along $x_k$.

We can show $B_{k+1}s_k = y_k$ (secant equation) is satisfied.

```@example optimization
# Set the initial guess
x0 = [-1.0, -1.0]
# Set the optimization options
options = Optim.Options(iterations = 1000, store_trace=true, extended_trace=true)
# Optimize the Rosenbrock function using the simplex method
result = optimize(rosenbrock, x->ForwardDiff.gradient(rosenbrock, x), x0, BFGS(), options, inplace=false)
# Print the optimization result
show_history([t.metadata["x"] for t in result.trace])
```

```@example optimization
using Enzyme
using Optim
rosenbrock_inp(x) = (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
function g!(G, x)
    G[1:length(x)]=gradient(Enzyme.Reverse, rosenbrock_inp, x)
end
x0 = [-1, -1.0]
a = optimize(rosenbrock_inp, g!, x0, LBFGS())
a.minimizer, a.minimum
```


## Mathematical optimization


### Convex optimization

A set $S\subseteq \mathbb{R}^n$ is convex if it contains the line segment between any two of its points, i.e.,
```math
\{\alpha \mathbf{x} + (1-\alpha)\mathbf{y}: 0\leq \alpha \leq 1\} \subseteq S
```
for all $\mathbf{x}, \mathbf{y} \in S$.


A function $f: S \in R^n \rightarrow R$ is convex on a convex set $S$ if its graph along any line segment in $S$ lies on or blow the chord connecting the function values at the endpoints of the segment, i.e., if
```math
f(\alpha \mathbf{x} + (1-\alpha) \mathbf{y}) \leq \alpha f(\mathbf{x}) + (1+\alpha)f(\mathbf{y})
```
for all $\alpha \in [0, 1]$ and all $\mathbf{x}, \mathbf{y}\in S$.


Any local minimum of a convex function $f$ on a convex set $S\subseteq \mathbb{R}^n$ is a global minimum of $f$ on $S$.

### Linear programming

Linear programs are problems that can be expressed in canonical form as
```math
{\begin{aligned}&{\text{Find a vector}}&&\mathbf {x} \\&{\text{that maximizes}}&&\mathbf {c} ^{T}\mathbf {x} \\&{\text{subject to}}&&A\mathbf {x} \leq \mathbf {b} \\&{\text{and}}&&\mathbf {x} \geq \mathbf {0} .\end{aligned}}
```
Here the components of $\mathbf x$ are the variables to be determined, $\mathbf c$ and $\mathbf b$ are given vectors (with $\mathbf {c} ^{T}$ indicating that the coefficients of $\mathbf c$ are used as a single-row matrix for the purpose of forming the matrix product), and $A$ is a given matrix.


### Example
[https://jump.dev/JuMP.jl/stable/tutorials/linear/diet/](https://jump.dev/JuMP.jl/stable/tutorials/linear/diet/)



[JuMP.jl documentation](https://jump.dev/JuMP.jl/stable/) also contains mathematical models such as **semidefinite programming** and **integer programming**.

