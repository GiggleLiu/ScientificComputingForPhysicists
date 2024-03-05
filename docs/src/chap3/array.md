# Array and Broadcasting

## Array indexing and broadcasting
Julia array can be **initialized** with multiple ways.
```@repl array
A = [1, 2, 3] # a vector
B = [1 2 3; 4 5 6; 7 8 9]  # a matrix
zero_vector = zeros(3) # zero vector
rand_vector = randn(Float32, 3, 3) # random normal distribution
step_vector = collect(1:3)  # collect from a range
uninitialized_vector = Vector{Int}(undef, 3) # uninitialized vector of size 3
```

Julia array **indexing** starts from 1, which is different from C, Python, and R. 😞
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

Julia has a powerful **broadcasting** mechanism. It is a way to apply a function to each element of an array. The broadcasting is done by adding a dot `.` before the function name.
```@repl array
x = 0:0.1π:2π
y = sin.(x) .+ cos.(3 .* x);
```

The broadcasting also does the **loop fusion**, which means only one loop is used to iterate over the elements of the array and no intermediate array is created. This is often more efficient than the step-by-step loop.

We can use `Ref` to protect an object from being broadcasted.
```@repl array
Ref([3,2,1,0]) .* (1:3)
```
We can see the vector is treated as a whole.

## Julia array is column-major

In Julia, arrays are stored in **column-major** order. This may affect the performance of the code.

```@raw html
<img src="../../assets/images/colmajor.png" alt="column-major" width="200"/>
```

For example, we can implement the Frobenius norm of a matrix as follows.
```@repl array
function frobenius_norm(A::AbstractMatrix)
    s = zero(eltype(A))
    # the `@inbounds` macro tells the compiler that the loop is safe and it can skip the boundary check.
    @inbounds for i in 1:size(A, 1)
        for j in 1:size(A, 2)
            s += A[i, j]^2
        end
    end
    return sqrt(s)
end
```

```@repl array
A = randn(1000, 1000);
frobenius_norm(A)
```

```julia-repl
julia> using BenchmarkTools

julia> @benchmark frobenius_norm($A)
BenchmarkTools.Trial: 25 samples with 1 evaluation.
 Range (min … max):  203.310 ms … 214.439 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     204.769 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   205.331 ms ±   2.247 ms  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▃   ▃▃███▃ ▃                                                   
  █▁▇▁██████▇█▁▁▇▁▁▁▁▁▁▇▁▁▁▁▁▁▁▁▁▁▇▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▇ ▁
  203 ms           Histogram: frequency by time          214 ms <

 Memory estimate: 0 bytes, allocs estimate: 0.
```

Alternatively, we can loop over the second index first.
```@repl array
function frobenius_norm_colmajor(A::AbstractMatrix)
    s = zero(eltype(A))
    @inbounds for j in 1:size(A, 2)
        for i in 1:size(A, 1)
            s += A[i, j]^2
        end
    end
    return sqrt(s)
end
```

```julia-repl
julia> @benchmark frobenius_norm_colmajor($A)
BenchmarkTools.Trial: 53 samples with 1 evaluation.
 Range (min … max):  90.380 ms … 133.823 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     92.729 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   94.415 ms ±   6.425 ms  ┊ GC (mean ± σ):  0.00% ± 0.00%

      ▂ ▂█ ▄   ▂                                                
  ▆██▄█▆████▆▆▄█▄▁▁▁▁▄▄▄▁▁▁▁▁▁▁▁▁▄▁▁▁▄▁▁▁▁▄▁▄▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▄ ▁
  90.4 ms         Histogram: frequency by time          108 ms <

 Memory estimate: 0 bytes, allocs estimate: 0.
```

We can see by simply changing the order of the loop, the performance is improved by more than 2 times. This is because the memory access pattern is more cache-friendly.

### Example: create a meshgrid for triangular lattice
```@repl array
b1 = [1, 0]
b2 = [0.5, sqrt(3)/2]
n = 5
mesh1 = [i * b1 + j * b2 for i in 1:n, j in 1:n]  # list comprehension
mesh2= (1:n) .* Ref(b1) .+ (1:n)' .* Ref(b2)  # broadcasting
```

```@example array
using Plots

scatter(vec(getindex.(mesh2, 1)), vec(getindex.(mesh2, 2)), label="mesh2", ratio=1, markersize=5)
```

## Array performance tips
1. Fix the type of an array

Arrays with a fixed type are faster than arrays with abstract types.
`Any` type vector is the most flexible, but it is also very slow.

```@repl array
vany = Any[]  # same as vany = []
typeof(vany)
push!(vany, "a")
push!(vany, 1)
```

Fixed typed vector is more restrictive.

```@repl array
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

