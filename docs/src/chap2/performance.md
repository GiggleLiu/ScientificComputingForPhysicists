# Performance and Profile
## Profiling
Profiling is a way to measure the performance of your code. It can help you to identify the bottleneck of your code and optimize it. The [Profile](https://docs.julialang.org/en/v1/manual/profile/) module in Julia provides a set of tools to profile your code.

Consider we have two random matrices `A` and `B`, and we want to measure the performance of the matrix multiplication `A * B`.

We can start the profiler by
```@repl profile
using Profile
Profile.init(n = 10^7, delay = 0.001) # set the number of samples and the delay between samples
```

Then you can profile your code by running it.
```@repl profile
A, B = rand(1000, 1000), rand(1000, 1000);
A * B;  # the first run contains the compilation time
@profile A * B;
```

To view the profile result, you can use the `Profile.print()` function.
```@repl profile
Profile.print(; C=true, mincount=3)
```

The majority of the time is spent in the GEMM function of the BLAS library, which is a highly optimized library for matrix multiplication. The performance of the matrix multiplication is close to the theoretical peak performance of the CPU.

### Example: Optimizing the performance of Lorenz attractor

Consider we have a simple implementation of the [Lorenz attractor](https://en.wikipedia.org/wiki/Lorenz_system) using the [Runge-Kutta method](https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods). The code is as follows:
```@example profile
# Point in 3D space
struct P3{T}
    x::T
    y::T
    z::T
end

# Overload the zero function
Base.zero(::Type{P3{T}}) where T = P3(zero(T), zero(T), zero(T))
Base.zero(::P3{T}) where T = P3(zero(T), zero(T), zero(T))


# Overload the addition, subtraction, division and multiplication
@inline function Base.:(+)(a::P3, b::P3)
    P3(a.x + b.x, a.y + b.y, a.z + b.z)
end

@inline function Base.:(/)(a::P3, b::Real)
    P3(a.x/b, a.y/b, a.z/b)
end

@inline function Base.:(*)(a::Real, b::P3)
    P3(a*b.x, a*b.y, a*b.z)
end


# define the Lorenz attractor
function lorenz(t, y)
    P3(10*(y.y-y.x), y.x*(27-y.z)-y.y, y.x*y.y-8/3*y.z)
end

# define the single step update for the Runge-Kutta method of order 4
# f: the function to be integrated
# t: the current time
# y: the current value
# Δt: the current time step
function rk4_step(f, t, y, Δt)
    k1 = Δt * f(t, y)
    k2 = Δt * f(t+Δt/2, y + k1 / 2)
    k3 = Δt * f(t+Δt/2, y + k2 / 2)
    k4 = Δt * f(t+Δt, y + k3)
    return y + k1/6 + k2/3 + k3/3 + k4/6
end

# define the Runge-Kutta method of order 4
# f: the function to be integrated
# y0: the initial value
# t0: the initial time
# Δt: the time step
# Nt: the number of steps
function rk4(f, y0; t0, Δt, Nt, history=nothing)
    y = y0
    for i=1:Nt
        y = rk4_step(f, t0+(i-1)*Δt, y, Δt)
        # record the history
        record!(history, y)
    end
    return y
end

# record the history: if history is a vector, push the value to the vector
record!(v::AbstractVector, y) = push!(v, y)
record!(::Nothing, y) = nothing
nothing # hide
```

If we run the code, we can see the Lorenz attractor.
```@example profile
y = P3(1.0, 0.0, 0.0)
history = [y]
rk4(lorenz, y; t0=0.0, Δt=0.001, Nt=100000, history)

using Plots; gr(dpi=100)
plot([h.x for h in history], [h.y for h in history], [h.z for h in history], legend=false)
```

The performance of the code 
```julia-repl
julia> @benchmark rk4(lorenz, P3(1.0, 0.0, 0.0); t0=0.0, Δt=0.001, Nt=100000, history=[])
BenchmarkTools.Trial: 1479 samples with 1 evaluation.
 Range (min … max):  3.167 ms …   7.822 ms  ┊ GC (min … max): 0.00% … 56.98%
 Time  (median):     3.263 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   3.381 ms ± 321.910 μs  ┊ GC (mean ± σ):  3.06% ±  6.93%

  ▂▃▅█▇▅▄▃▃▁▁▂▂▁                              ▁▂▂▁             
  ██████████████▇▅▄▄▅▁▄▄▁▁▄▁▁▄▁▁▁▁▁▁▁▁▁▁▁▁▅▇▆▆████▇▇▆▅▆▅▄▅▅▅▄ █
  3.17 ms      Histogram: log(frequency) by time      4.43 ms <

 Memory estimate: 4.88 MiB, allocs estimate: 100011.
```

It is reasonable to suspect that the performance bottleneck is the `record!` function, because the `history` is a vector of element type `Any`.
In order to verify our intuition, we can profile the code to see the performance bottleneck.

```@example profile
Profile.clear()   # clear the previous profile result
@profile rk4(lorenz, P3(1.0, 0.0, 0.0); t0=0.0, Δt=0.001, Nt=5000000, history=[]) # record the profile
Profile.print(format=:flat, mincount=5)  # show the profile result, only show the functions that are called more than 5 times
```
The `print` also supports other formats, such as `:tree`.

In this example, we can see that the `record!` function has only a few counts, each count stands for $10^{-3}s$. So the `record!` function is not the performance bottleneck. The performance bottleneck is the `rk4` function.