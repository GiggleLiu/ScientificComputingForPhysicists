# Optimization

```@example optimization
using Plots
using Optim
using ForwardDiff
using Luxor
```

A general continous optimization problem has the following form
```math
\min_{\mathbf x}f(\mathbf x)~~~\text{ subject to certian constraints}
```
The constraints may be either equality or inequality constraints.

## Gradient free optimization

Gradient-free optimizers are optimization algorithms that do not rely on the gradient of the objective function to find the optimal solution. Instead, they use other methods such as random search, genetic algorithms, or simulated annealing to explore the search space and find the optimal solution. These methods are particularly useful when the objective function is non-differentiable or when the gradient is difficult to compute. However, gradient-free optimizers can be $(PlutoLecturing.highlight("slower and less efficient than gradient-based methods")), especially when the search space is high-dimensional.

There are several popular gradient-free optimizers, including:
* **Genetic algorithms**: These are optimization algorithms inspired by the process of natural selection. They use a population of candidate solutions and apply genetic operators such as crossover and mutation to generate new solutions.

* **Simulated annealing**: This is a probabilistic optimization algorithm that uses a temperature parameter to control the probability of accepting a worse solution. It starts with a high temperature that allows for exploration of the search space and gradually decreases the temperature to converge to the optimal solution.

* **Particle swarm optimization**: This is a population-based optimization algorithm that simulates the movement of particles in a search space. Each particle represents a candidate solution, and they move towards the best solution found so far.

* **Bayesian optimization**: This is a probabilistic optimization algorithm that uses a probabilistic model to approximate the objective function and guides the search towards promising regions of the search space.

* **Nelder-Mead algorithm**: This is a direct search method that does not require the computation of gradients of the objective function. Instead, it uses a set of simplex (a geometrical figure that generalizes the concept of a triangle to higher dimensions) to iteratively explore the search space and improve the objective function value. The Nelder-Mead algorithm is particularly effective in optimizing nonlinear and non-smooth functions, and it is widely used in engineering, physics, and other fields.


NOTE: [Optim.jl documentation](https://julianlsolvers.github.io/Optim.jl/stable/) contains more detailed introduction of gradient free, gradient based and hessian based optimizers.


## The downhill simplex method



Here are the steps involved in the one dimentional downhill simplex algorithm:
1. Initialize a one dimensional simplex, evaluate the function at the end points $x_1$ and $x_2$ and assume $f(x_2) > f(x_1)$.
2. Evaluate the function at $x_c = 2x_1 - x_2$.
3. Select one of the folloing operations
    1. If $f(x_c)$ is smaller than $f(x_1)$, **flip** the simplex by doing $x_1 \leftarrow x_c$ and $x_2 \leftarrow x_1$.
    2. If $f(x_c)$ is larger than $f(x_1)$, but smaller than $f(x_2)$, then $x_2\leftarrow x_c$, goto case 3.
    3. If $f(x_c)$ is larger than $f(x_2)$, then **shrink** the simplex: evaluate $f$ on $x_d\leftarrow (x_1 + x_2)/2$, if it is larger than $f(x_1)$, then $x_2 \leftarrow x_d$, otherwise $x_1\leftarrow x_d, x_2\leftarrow x_1$.
4. Repeat step 2-3 until convergence.


function simplex1d(f, x1, x2; tol=1e-6)
	# initial simplex
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

simplex1d(x->x^2, -1.0, 6.0)


The Nelder-Mead method is well summarized in this [wiki page](https://en.wikipedia.org/wiki/Nelder%E2%80%93Mead_method).
Here is a Julia implementation:


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


The `simplex` function takes three arguments: the objective function `f`, the initial guess `x0`, and optional arguments for the tolerance `tol` and maximum number of iterations `maxiter`.

The algorithm initializes a simplex (a high dimensional triangle) with `n+1` vertices, where `n` is the number of dimensions of the problem. The vertices are initially set to `x0` and `x0 + h_i`, where `h_i` is a small step size in the `i`th dimension. The function values at the vertices are also calculated.

The algorithm then iteratively performs **reflection**, **expansion**, **contraction**, and **shrink** operations on the simplex until convergence is achieved. The best vertex and function value are returned.



We use the [Rosenbrock function](https://en.wikipedia.org/wiki/Rosenbrock_function) as the test function.


function rosenbrock(x)
	(1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
end

let
	x = -2:0.01:2
	y = -2:0.01:2
	f = [rosenbrock((a, b)) for b in y, a in x]
	heatmap(x, y, log.(f); label="log(f)", xlabel="x₁", ylabel="x₂")
end

function show_triangles(history)
	x = -2:0.02:2
	y = -2:0.02:2
	f = [rosenbrock((a, b)) for b in y, a in x]
	@gif for item in history
		plt = heatmap(x, y, log.(f); label="log(f)", xlabel="x₁", ylabel="x₂", xlim=(-2, 2), ylim=(-2, 2))
		plot!(plt, [item[:,1]..., item[1,1]], [item[:,2]..., item[1, 2]]; label="", color="white")
	end fps=5
end

let
	bestx, bestf, history = simplex(rosenbrock, [-1.2, -1.0]; tol=1e-3)
	@info "converged in $(length(history)) steps, with error $bestf"
	show_triangles(history)
end

let
	# Set the initial guess
	x0 = [-1, -1.0]
	# Set the optimization options
	options = Optim.Options(iterations = 1000)
	# Optimize the Rosenbrock function using the simplex method
	result = optimize(rosenbrock, x0, NelderMead(), options)
	# Print the optimization result
	result
end

# Gradient based optimization


If $f: R^n \rightarrow R$ is differentiable, then the vector-valued function $\nabla f: R^n \rightarrow R^n$ defined by
```math
\nabla f(x) = \left(\begin{matrix}
\frac{\partial f(\mathbf{x})}{\partial x_1}\\
\frac{\partial f(\mathbf{x})}{\partial x_2}\\
\vdots\\
\frac{\partial f(\mathbf{x})}{\partial x_n}\\
\end{matrix}\right)
```
is called the gradient of $f$.



Gradient descent is based on the observation that changing $\mathbf x$ slightly towards the negative gradient direction always decrease $f$ in the first order perturbation.
```math
f(\mathbf{x} - \epsilon \nabla f(\mathbf x)) \approx f(\mathbf x) - \epsilon \nabla f(\mathbf x)^T \nabla f(\mathbf x) = f(\mathbf x) - \epsilon \|\nabla f(\mathbf x)\|_2 < f(\mathbf{x})
```


## Gradient descent

In each iteration, the update rule of the gradient descent method is
```math
\begin{align}
&\theta_{t+1} = \theta_t - \alpha g_t
\end{align}
```

where 
*  $\theta_t$ is the values of variables at time step $t$.
*  $g_t$ is the gradient at time $t$ along $\theta_t$, i.e. $\nabla_{\theta_t} f(\theta_t)$.
*  $\alpha$ is the learning rate.


One can obtain the gradient with `ForwardDiff`.

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

function show_history(history)
	x = -2:0.01:2
	y = -2:0.01:2
	f = [rosenbrock((a, b)) for b in y, a in x]
	plt = heatmap(x, y, log.(f); label="log(f)", xlabel="x₁", ylabel="x₂", xlim=(-2, 2), ylim=(-2, 2))
	plot!(plt, getindex.(history, 1), getindex.(history, 2); label="optimization", color="white")
end

let
	x0 = [-1, -1.0]
	history = gradient_descent(rosenbrock, x0; niters=10000, learning_rate=0.002)
	@info rosenbrock(history[end])

	# plot
	show_history(history)
end


The problem of gradient descent: easy trapped by plateaus.

```@example optimization
using Enzyme
using Optim
rosenbrock_inp(x) = (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
function g!(G, x)
    G[1:length(x)]=gradient(Reverse, rosenbrock_inp, x)
end
a=optimize(rosenbrock_inp, g!, x0, LBFGS())
```

## Gradient descent with momentum

We can add a "momentum" term to the weight update, which helps the optimization algorithm to move more quickly in the right direction and avoid getting stuck in local minima.

The intuition behind the momentum method can be understood by considering a ball rolling down a hill. Without momentum, the ball would roll down the hill and eventually come to a stop at the bottom. However, with momentum, the ball would continue to roll past the bottom of the hill and up the other side, before eventually coming to a stop at a higher point. This is because the momentum of the ball helps it to overcome small bumps and obstacles in its path and continue moving in the right direction.

In each iteration, the update rule of gradient descent method with momentum is
```math
\begin{align}
&v_{t+1} = \beta v_t - \alpha g_t\\
&\theta_{t+1} = \theta_t + v_{t+1}
\end{align}
```

where 
*  $g_t$ is the gradient at time $t$ along $\theta_t$, i.e. $\nabla_{\theta_t} f(\theta_t)$.
*  $\alpha$ is the initial learning rate.
*  $\beta$ is the parameter for the gradient accumulation.

```@example optimization
```
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

let
	x0 = [-1, -1.0]
	history = gradient_descent_momentum(rosenbrock, x0; niters=10000, learning_rate=0.002, β=0.5)
	@info rosenbrock(history[end])

	# plot
	show_history(history)
end


The problem of momentum based method, easily got overshoted.
Moreover, it is not **scale-invariant**.



## AdaGrad
AdaGrad is an optimization algorithm used in machine learning for solving convex optimization problems. It is a gradient-based algorithm that adapts the learning rate for each parameter based on the historical gradient information. The main idea behind AdaGrad is to give more weight to the parameters that have a smaller gradient magnitude, which allows for a larger learning rate for those parameters.



In each iteration, the update rule of AdaGrad is

```math
\begin{align}
	&r_t = r_t + g_t^2\\
    &\mathbf{\eta} = \frac{\alpha}{\sqrt{r_t + \epsilon}}\\
    &\theta_{t+1} = \theta_t - \eta \odot g_t
\end{align}
```

where 
*  $\theta_t$ is the values of variables at time $t$.
*  $\alpha$ is the initial learning rate.
*  $g_t$ is the gradient at time $t$ along $\theta_t$
*  $r_t$ is the historical squared gradient sum, which is initialized to $0$.
*  $\epsilon$ is a small positive number.
*  $\odot$ is the element-wise multiplication.


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

let
	x0 = [-1, -1.0]
	history = adagrad_optimize(rosenbrock, x0; niters=10000, learning_rate=1.0)
	@info rosenbrock(history[end])

	# plot
	show_history(history)
end

## Adam
The Adam optimizer is a popular optimization algorithm used in deep learning for training neural networks. It stands for Adaptive Moment Estimation and is a variant of stochastic gradient descent (SGD) that is designed to be more efficient and effective in finding the optimal weights for the neural network.

The Adam optimizer maintains a running estimate of the first and second moments of the gradients of the weights with respect to the loss function. These estimates are used to adaptively adjust the learning rate for each weight parameter during training. The first moment estimate is the mean of the gradients, while the second moment estimate is the uncentered variance of the gradients.

The Adam optimizer combines the benefits of two other optimization algorithms: AdaGrad, which adapts the learning rate based on the historical gradient information, and RMSProp, which uses a moving average of the squared gradients to scale the learning rate.

The Adam optimizer has become a popular choice for training deep neural networks due to its fast convergence and good generalization performance. It is widely used in many deep learning frameworks, such as TensorFlow, PyTorch, and Keras.


In each iteration, the update rule of Adam is

```math
\begin{align}
&v_t = \beta_1 v_{t-1} - (1-\beta_1) g_t\\
&s_t = \beta_2 s_{t-1} - (1-\beta_2) g^2\\
&\hat v_t = v_t / (1-\beta_1^t)\\
&\hat s_t = s_t / (1-\beta_2^t)\\
&\theta_{t+1} = \theta_t -\eta \frac{\hat v_t}{\sqrt{\hat s_t} + \epsilon}
&\end{align}
```
where
*  $\theta_t$ is the values of variables at time $t$.
*  $\eta$ is the initial learning rate.
*  $g_t$ is the gradient at time $t$ along $\theta$.
*  $v_t$ is the exponential average of gradients along $\theta$.
*  $s_t$ is the exponential average of squares of gradients along $\theta$.
*  $\beta_1, \beta_2$ are hyperparameters.


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

let
	x0 = [-1, -1.0]
	history = adam_optimize(rosenbrock, x0; niters=10000, learning_rate=0.01)
	@info rosenbrock(history[end])

	# plot
	show_history(history)
end


## The Julia package `Optimisers.jl`


import Optimisers

PlutoLecturing.@xbind gradient_based_optimizer Select(["Descent", "Momentum", "Nesterov", "Rprop", "RMSProp", "Adam", "RAdam", "AdaMax", "OAdam", "AdaGrad", "AdaDelta", "AMSGrad", "NAdam", "AdamW", "AdaBelief"])

PlutoLecturing.@xbind learning_rate NumberField(0:1e-4:1.0, default=1e-4)

The different optimizers are introduced in the [documentation page](https://fluxml.ai/Optimisers.jl/dev/api/)

let
	x0 = [-1, -1.0]
	method = eval(:(Optimisers.$(Symbol(gradient_based_optimizer))(learning_rate)))
	state = Optimisers.setup(method, x0)
	history = [x0]
	for i=1:10000
		grad = ForwardDiff.gradient(rosenbrock, x0)
		state, x0 = Optimisers.update(state, x0, grad)
		push!(history, x0)
	end
	@info rosenbrock(history[end])

	# plot
	show_history(history)
end

[Optimisers.jl documentation](https://fluxml.ai/Optimisers.jl/dev/api/#Optimisation-Rules) contains **stochastic** gradient based optimizers.



# Hessian based optimizers


## Newton's Method


Newton's method is an optimization algorithm used to find the roots of a function, which can also be used to find the minimum or maximum of a function. The method involves using the first and second derivatives of the function to approximate the function as a quadratic function and then finding the minimum or maximum of this quadratic function. The minimum or maximum of the quadratic function is then used as the next estimate for the minimum or maximum of the original function, and the process is repeated until convergence is achieved.



```math
\begin{align}
& H_{k}p_{k}=-g_k\\
& x_{k+1}=x_{k}+p_k
\end{align}
```
where
*  $g_k$ is the gradient at time $k$ along $x_k$.


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

let
	x0 = [-1, -1.0]
	history = newton_optimizer(rosenbrock, x0; tol=1e-5)
	@info "number iterations = $(length(history)), got $(rosenbrock(history[end]))"

	# plot
	show_history(history)
end

The drawback of Newton's method is, the Hessian is very expensive to compute!
While gradients can be computed with the automatic differentiation method with constant overhead. The Hessian requires $O(n)$ times more resources, where $n$ is the number of parameters.

## The Broyden–Fletcher–Goldfarb–Shanno (BFGS) algorithm


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


let
	# Set the initial guess
	x0 = [-1.0, -1.0]
	# Set the optimization options
	options = Optim.Options(iterations = 1000, store_trace=true, extended_trace=true)
	# Optimize the Rosenbrock function using the simplex method
	result = optimize(rosenbrock, x->ForwardDiff.gradient(rosenbrock, x), x0, BFGS(), options, inplace=false)
	# Print the optimization result
	@info result
	show_history([t.metadata["x"] for t in result.trace])
end


# Mathematical optimization


## Convex optimization

A set $S\subseteq \mathbb{R}^n$ is convex if it contains the line segment between any two of its points, i.e.,
```math
\{\alpha \mathbf{x} + (1-\alpha)\mathbf{y}: 0\leq \alpha \leq 1\} \subseteq S
```
for all $\mathbf{x}, \mathbf{y} \in S$.

let
	@drawsvg begin
	function segment(a, b)
		line(a, b, :stroke)
		circle(a, 5, :fill)
		circle(b, 5, :fill)
	end
	fontsize(20)
	c1 = Point(-180, -20)
	sethue("red")
	ellipse(c1, 130, 80, :fill)
	sethue("black")
	ellipse(c1, 130, 80, :stroke)
	segment(c1 - Point(50, 25), c1 + Point(50, -25))
	Luxor.text("convex set", c1 + Point(0, 90), halign=:center)
	c2 = Point(0, -20)
	f(t) = Point(4cos(t) + 2cos(3t), 4sin(t) + 3sin(3t+π/2))
	sethue("red")
    poly(10 .* f.(range(0, 2π, length=160)) .+ c2, action = :fill)
	sethue("black")
    poly(10 .* f.(range(0, 2π, length=160)) .+ c2, action = :stroke)
	a, b = Point(c2.x-30, c2.y+30), Point(c2.x+45, c2.y)
	segment(a, b)
	Luxor.text("nonconvex set", c2 + Point(0, 90), halign=:center)
end 520 200
end


A function $f: S \in R^n \rightarrow R$ is convex on a convex set $S$ if its graph along any line segment in $S$ lies on or blow the chord connecting the function values at the endpoints of the segment, i.e., if
```math
f(\alpha \mathbf{x} + (1-\alpha) \mathbf{y}) \leq \alpha f(\mathbf{x}) + (1+\alpha)f(\mathbf{y})
```
for all $\alpha \in [0, 1]$ and all $\mathbf{x}, \mathbf{y}\in S$.


let
@drawsvg begin
	function segment(a, b)
		line(a, b, :stroke)
		circle(a, 5, :fill)
		circle(b, 5, :fill)
	end
	fontsize(20)
	c1 = Point(-180, -20)
	xs = -1.6:0.01:1.6
	ys = 0.8 * (2.0xs .^ 2 .- xs .^ 4 .- 0.2*xs .+ 1)
	Luxor.poly(30 .* Point.(xs, ys) .+ Ref(c1), :stroke)
	Luxor.text("nonconvex", c1 + Point(0, 90), halign=:center)
	segment(c1+Point(-17, 40), c1+Point(18, 35))
	
	c2 = Point(0, -20)
	xs = [-1.8, -0.9, 0.0, 0.7, 1.8]
	ys = [-0.7, 1.3, 1.7, 1.2, -0.7]
	Luxor.poly(30 .* Point.(xs, ys) .+ Ref(c2), :stroke)
	Luxor.text("convex", c2 + Point(0, 90), halign=:center)
	segment(c2+Point(-17, 43), c2+Point(25, 30))

	
	fontsize(20)
	c3 = Point(180, -20)
	xs = -1.4:0.01:1.3
	ys = 0.8 * (- xs .^ 4 .- 0.2*xs .+ 2.2)
	Luxor.poly(30 .* Point.(xs, ys) .+ Ref(c3), :stroke)
	Luxor.text("strictly convex", c3 + Point(0, 90), halign=:center)
	segment(c3+Point(-27, 40), c3+Point(25, 35))
end 520 200
end

Any local minimum of a convex function $f$ on a convex set $S\subseteq \mathbb{R}^n$ is a global minimum of $f$ on $S$.

## Linear programming


Linear programs are problems that can be expressed in canonical form as
```math
{\begin{aligned}&{\text{Find a vector}}&&\mathbf {x} \\&{\text{that maximizes}}&&\mathbf {c} ^{T}\mathbf {x} \\&{\text{subject to}}&&A\mathbf {x} \leq \mathbf {b} \\&{\text{and}}&&\mathbf {x} \geq \mathbf {0} .\end{aligned}}
```
Here the components of $\mathbf x$ are the variables to be determined, $\mathbf c$ and $\mathbf b$ are given vectors (with $\mathbf {c} ^{T}$ indicating that the coefficients of $\mathbf c$ are used as a single-row matrix for the purpose of forming the matrix product), and $A$ is a given matrix.


## Example
[https://jump.dev/JuMP.jl/stable/tutorials/linear/diet/](https://jump.dev/JuMP.jl/stable/tutorials/linear/diet/)



[JuMP.jl documentation](https://jump.dev/JuMP.jl/stable/) also contains mathematical models such as **semidefinite programming** and **integer programming**.



# Assignments

1. Show the following graph $G=(V, E)$ has a unit-disk embedding.
```
V = 1, 2, ..., 10
E = [(1, 2), (1, 3),
	(2, 3), (2, 4), (2, 5), (2, 6),
	(3, 5), (3, 6), (3, 7),
	(4, 5), (4, 8),
	(5, 6), (5, 8), (5, 9),
	(6, 7), (6, 8), (6, 9),
	(7,9), (8, 9), (8, 10), (9, 10)]
```

So what is uni-disk embedding of a graph? Ask Chat-GPT with the following question
```
What is a unit-disk embedding of a graph?
```

### Hint:
To solve this issue, you can utilize an optimizer. Here's how:

1. Begin by assigning each vertex with a coordinate. You can represent the locations of all vertices as a $2 \times n$ matrix, denoted as $x$, where each column represents a coordinate of vertices in a two-dimensional space.

2. Construct a loss function, denoted as $f(x)$, that returns a positive value as punishment if any connected vertex pair $(v, w)$ has a distance ${\rm dist}(x_v, x_w) > 1$ (the unit distance), or if any disconnected vertex pair has a distance smaller than $1$. If all unit-disk constraints are satisfied, the function returns $0$.

3. Use an optimizer to optimize the loss function $f(x)$. If the loss can be reduced to $0$, then the corresponding $x$ represents a unit-disk embedding. If not, you may need to try multiple times to ensure that your optimizer does not trap you into a local minimum.


## Golden section search";

function golden_section_search(f, a, b; tol=1e-5)
	τ = (√5 - 1) / 2
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
			x2 = a + τ * (b - a)
			f2 = f(x2)
		else
			b = x2
			x2 = x1
			f2 = f1
			x1 = a + (1 - τ) * (b - a)
			f1 = f(x1)
		end
	end
	#@info "number of iterations = $k"
	return f1 < f2 ? (a, f1) : (b, f2)
end;

golden_section_search(x->(x-4)^2, -5, 5; tol=1e-5);
