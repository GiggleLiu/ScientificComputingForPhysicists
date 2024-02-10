# Understanding Performance
## Array

Initializing an array in Julia is simple. You can initialize an array with different types of elements.
```@repl array
zero_vector = zeros(3) # zero vector
direct_matrix = [5 2 1; 1 4 5; 2 4 9] # explicit
rand_vector = randn(Float32, 3, 3) # random normal distribution
step_vector = collect(1:3)  # collect from a range
uninitialized_vector = Vector{Int}(undef, 3) # uninitialized vector of size 3
```

- **Julia array is fast.** In memory, it is a contiguous block if the element type is bitstype - having a fixed size in memory.
  ```@repl array
  isbitstype(Int)
  isbitstype(Complex{Float64})   # complex number has a fixed size
  sizeof(Complex{Float64})
  isbitstype(typeof(('a', 2, false)))  # tuple has a fixed size
  sizeof(typeof(('a', 2, false)))
  isbitstype(typeof(randn(3)))   # array does not have a fixed size
  sizeof(typeof(randn(3)))  # an array of array may cause slow indexing.
  ```
- **Julia array memory layout is column-major**. Looping over the first index is faster than looping over the last index.

  ```@repl array
  function mysum_col(A::AbstractMatrix)
      s = zero(eltype(A)) # zero of the element type of A
      for j in 1:size(A, 2) # loop over the second index
          for i in 1:size(A, 1)  # loop over the first index
              s += A[i, j]
          end
      end
      return s
  end
  function mysum_row(A::AbstractMatrix)
      s = zero(eltype(A)) # zero of the element type of A
      for i in 1:size(A, 1)  # loop over the first index
         for j in 1:size(A, 2) # loop over the second index
              s += A[i, j]
          end
      end
      return s
  end
  ```
  For small scale matrix, their performance is similar since the matrix can be cached well. However, for large scale matrix, the column-major layout is much faster due to the cache locality.
  ```julia-repl
  julia> using BenchmarkTools

  julia> A = rand(10000, 10000);

  julia> @btime mysum_col($A)
    85.885 ms (0 allocations: 0 bytes)
  4.999830721534851e7

  julia> @btime mysum_row($A)
    189.794 ms (0 allocations: 0 bytes)
  4.9998307215344414e7
  ```
- **Julia array indexing starts from 1**. It is different from C, Python, and R, which start from 0. 😞
  ```@repl array
  A = [1, 2, 3]
  A[1]     # the first element
  A[end]   # the last element
  A[1:2]   # the first two elements
  A[2:-1:1] # the first two elements in the reversed order
  B = [1 2 3; 4 5 6; 7 8 9];
  B[1:2]   # the first two elements, returns B[1,1] and B[2,1] since B is column-major
  B[1:2, 1:2] # returns a submatrix
  ```

## Broadcasting
Julia has a powerful broadcasting mechanism. It is a way to apply a function to each element of an array. The broadcasting is done by adding a dot `.` before the function name.
```@repl broadcast
x = 0:0.1:2π
y = sin.(x) .+ cos.(3 .* x);
```

```@example broadcast
using Plots; gr(dpi=100)  # for high-quality plots, we suggest using `Makie.jl`
Plots.plot(x, y; label="sin(x) + cos(3x)")
```

### Loop fusion

The broadcasting is very efficient due to **loop fusion**. In the above example, only one loop is needed to calculate `sin` and `cos` for each element of `x` and only one array is allocated to store the result.

Loop fused:
```julia-repl
julia> using BenchmarkTools
julia> @benchmark sin.($x) .+ cos.(3 .* $x);
BenchmarkTools.Trial: 10000 samples with 107 evaluations.
 Range (min … max):  775.308 ns …  2.984 μs  ┊ GC (min … max): 0.00% … 62.53%
 Time  (median):     781.159 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   798.606 ns ± 78.472 ns  ┊ GC (mean ± σ):  0.28% ±  2.36%

  ▅█▄    ▁ ▃▂ ▃▄▁      ▁                                       ▁
  ███▆▆▇██▇██▆███▇▆▆▆▆▇██▆▆▅▆▅▅▅▆▅▇▆▅▅▅▄▅▄▅▆▅▅▅▄▄▄▅▅▅▄▄▄▄▃▄▅▅▆ █
  775 ns        Histogram: log(frequency) by time       995 ns <

 Memory estimate: 576 bytes, allocs estimate: 1.
```

Loop not fused
```julia-repl
julia> @benchmark sin.($x) + cos.(3 * $x);
BenchmarkTools.Trial: 10000 samples with 107 evaluations.
 Range (min … max):  778.430 ns …  2.714 μs  ┊ GC (min … max): 0.00% … 66.36%
 Time  (median):     802.570 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   809.210 ns ± 66.113 ns  ┊ GC (mean ± σ):  0.26% ±  2.30%

   ▃        ▅█▇▄        ▂   ▄▄                                 ▂
  ███▄▁▁▁▃▄█████▇▆▇▇▇█▅███▆███▇▄▅▃▅▇▇▇▆▅▆▅▅▅▅▆▆▅▅▄▅▄▃▄▄▄▃▄▅▄▄▆ █
  778 ns        Histogram: log(frequency) by time       900 ns <

 Memory estimate: 576 bytes, allocs estimate: 1.
```

### When shapes do not match
```@repl broadcast
A = [1 2 3; 4 5 6]
B = [1 2 3]
A .+ B   # B is broadcasted to match the size of A
```

B is a (column) vector, which means its shape is (3, 1). The broadcasting is done by repeating the vector to match the shape of A.

With this trick, we can easily evaluate a function on a meshgrid.
```@repl broadcast
a = sin.(x) + cos.(3 * x);
b = cos.(x);
mesh = a' .* b # a has shape (1, length(x)), b has shape (length(x), 1)
```
```@example broadcast
heatmap(mesh)
```

### Unwanted broadcasting
Consider we have a vector, and we want to scale it with factors `1, 2, 3` and store the results in to a vector, i.e. we will get a vector of vectors. The following code will not work as expected.
```@repl broadcast
[3,2,1,0] .* (1:3)
```
Note a range is an iterable object. The broadcasting operation works on any iterable object, hence it tries to broadcast over the elements of the vector. A shape mismatch error is raised, which is unwanted.

In this case, we can use `Ref` to protect the vector from broadcasting.
```@repl broadcast
Ref([3,2,1,0]) .* (1:3)
```
We can see the vector is treated as a whole.

### Example: create a meshgrid for triangular lattice
```@repl broadcast
b1 = [1, 0]
b2 = [0.5, sqrt(3)/2]
n = 5
mesh1 = [i * b1 + j * b2 for i in 1:n, j in 1:n]  # list comprehension
mesh2= (1:n) .* Ref(b1) .+ (1:n)' .* Ref(b2)  # broadcasting
```

```@example broadcast
scatter(vec(getindex.(mesh2, 1)), vec(getindex.(mesh2, 2)), label="mesh2", ratio=1, markersize=5)
```

### Case study: Image processing

1. Download an image from the internet:
```@example image
url = "https://avatars.githubusercontent.com/u/8445510?v=4"
target_path = tempname() * ".png"
download(url, target_path)
```

2. Load the image with [`Images.jl`](https://github.com/JuliaImages/Images.jl):
```@example image
#using Images
#img = load(target_path)
nothing
```

*Quiz*:
- How to invert the color of the image?

### Array element type and performance

Any type vector is flexible. You can add any element into it.

```@repl broadcast
vany = Any[]  # same as vany = []
typeof(vany)
push!(vany, "a")
push!(vany, 1)
```

Fixed typed vector is more restrictive.

```@repl broadcast
vfloat64 = Float64[]
vfloat64 |> typeof
push!(vfloat64, "a")
```

The performance of the vector with a fixed type is much better than the vector with any type.
```julia-repl
julia> biganyv = collect(Any, 1:2:20000);

julia> @benchmark for i=1:length($biganyv)
    $biganyv[i] += 1
end
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  117.833 μs …  1.090 ms  ┊ GC (min … max): 0.00% … 71.28%
 Time  (median):     124.458 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   128.512 μs ± 39.121 μs  ┊ GC (mean ± σ):  1.55% ±  4.49%

  ▁   ▃▇█▅▂▂▅▆▄▂▃▄▃▃▄▄▄▃▂▂▂▂▁▁▁▁▁▁                             ▂
  █▆▄▄█████████████████████████████████▇█▇▇▇█▇▇▇▆▆▄▆▆▆▅▅▅▅▅▅▂▄ █
  118 μs        Histogram: log(frequency) by time       155 μs <

 Memory estimate: 156.25 KiB, allocs estimate: 10000.
```

```julia-repl
julia> bigfloatv = collect(Float64, 1:2:20000);

julia> @benchmark for i=1:length($bigfloatv)
    $bigfloatv[i] += 1
end
BenchmarkTools.Trial: 10000 samples with 40 evaluations.
 Range (min … max):  908.325 ns …  2.020 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     936.475 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   955.204 ns ± 69.933 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▃   ▇█  ▂▅▁  ▁     ▂                                         ▁
  █▄▃▃██▇▆███▇▆█▆█▇▄▆█▇▆▆▆█▇▇▆▇▇▇▇▆▅▅▆▆▆▅▅▅▅▃▄▅▄▅▄▄▃▄▄▄▄▄▄▅▅▄▆ █
  908 ns        Histogram: log(frequency) by time      1.24 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.
```
We can see that the performance of the vector with a fixed type can be 100 times faster than the vector with any type.

## Benchmark and profile
### How to measure the performance of your CPU?
The performance of a CPU is measured by the number of **floating point operations per second** (FLOPS) it can perform. The floating point operations include addition, subtraction, multiplication and division. The FLOPS can be related to multiple factors, such as the clock frequency, the number of cores, the number of instructions per cycle, and the number of floating point units. A simple way to measure the FLOPS is to benchmarking the speed of matrix multiplication.
```@repl profile
A, B = rand(1000, 1000), rand(1000, 1000);
```
```julia-repl
julia> using BenchmarkTools

julia> @btime $A * $B;
  12.122 ms (2 allocations: 7.63 MiB)
```

The number of FLOPS in a $n\times n\times n$ matrix multiplication is $2n^3$. The FLOPS can be calculated as: $2 \times 1000^3 / (12.122 \times 10^{-3}) = 165~{\rm GFLOPS}$.

### Profiling
Profiling is a way to measure the performance of your code. It can help you to identify the bottleneck of your code and optimize it. The [Profile](https://docs.julialang.org/en/v1/manual/profile/) module in Julia provides a set of tools to profile your code.

We can start the profiler by
```@repl profile
using Profile
Profile.init(n = 10^7, delay = 0.001) # set the number of samples and the delay between samples
```

Then you can profile your code by running it.
```@repl profile
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