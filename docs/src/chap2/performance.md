# Understanding Performance
### Array and Broadcasting

```jl
sco("""
	arr = [1, 2.0, 'c']
""")
```

```jl
sco("""
	typeof(arr)
""")
```

```jl
sco("""
	isbitstype(typeof(arr))
""")
```


**Boardcasting**

```jl
sc("""
	x = 0:0.1:π
""")
```

```jl
sc("""
	y = sin.(x)
""")
```

```jl
sc("""
	using Plots
""")
```

```jl
sc("""
	plot(x, y; label="sin")
""")
```

```jl
sc("""
	mesh = (1:100)'
""")
```

**Broadcasting over non-concrete element types may be type unstable.**

```jl
sco("""
	eltype(arr)
""")
```

```jl
sco("""
	arr .+ 1
""")
```

```julia
eltype(tp)
```

### Julia package development

```jl
sco("""
	using TropicalNumbers
""")
```

The file structure of a package

```jl
sco("""
	project_folder = dirname(dirname(pathof(TropicalNumbers)))
""")
```

<img src="./assets/images/julia_dev.png" alt="image" width="500" height="auto">



**Unit Test**

```jl
sco("""
	using Test
""")
```

```jl
sco("""
	@test Tropical(3.0) + Tropical(2.0) == Tropical(3.0)
""")
```

```jl
sco("""
	@test_throws BoundsError [1,2][3]
""")
```

```jl
sco("""
	@test_broken 3 == 2
""")
```

```jl
sco("""
	@testset "Tropical Number addition" begin
	@test Tropical(3.0) + Tropical(2.0) == Tropical(3.0)
	@test_throws BoundsError [1][2]
	@test_broken 3 == 2
end
""")
```




### Case study: Create a package like HappyMolecules

With `PkgTemplates`.

[https://github.com/CodingThrust/HappyMolecules.jl](https://github.com/CodingThrust/HappyMolecules.jl)



```julia
julia> isbitstype(Complex{Float64})

julia> sizeof(Complex{Float32})

julia> sizeof(Complex{Float64})
```

But `Complex{BigFloat}` is not

```julia
julia> sizeof(Complex{BigFloat})

julia> isbitstype(Complex{BigFloat})
```

The size of `Complex{BigFloat}` is not true! It returns the pointer size!

### How to measure the performance of your CPU?
The performance of a CPU is measured by the number of **floating point operations per second** (FLOPS) it can perform. The floating point operations include addition, subtraction, multiplication and division. The FLOPS can be related to multiple factors, such as the clock frequency, the number of cores, the number of instructions per cycle, and the number of floating point units. A simple way to measure the FLOPS is to benchmarking the speed of matrix multiplication.
```julia
julia> using BenchmarkTools

julia> A, B = rand(1000, 1000), rand(1000, 1000);

julia> @btime $A * $B;
  12.122 ms (2 allocations: 7.63 MiB)
```

The number of FLOPS in a $n\times n\times n$ matrix multiplication is $2n^3$. The FLOPS can be calculated as: $2 \times 1000^3 / (12.122 \times 10^{-3}) = 165~{\rm GFLOPS}$.

### Case study: Vector element type and speed

Any type vector is flexible. You can add any element into it.

```julia
vany = Any[]  # same as vany = []

typeof(vany)

push!(vany, "a")

push!(vany, 1)
```

Fixed typed vector is more restrictive.

```julia
vfloat64 = Float64[]

vfloat64 |> typeof

push!(vfloat64, "a")
```

Do not abuse the type system. e.g. a "zero" cost implementation

```julia
Val(3.0) # just a type

f(::Val{1}) = Val(1)

f(::Val{2}) = Val(1)
```

It violates the [Performance Tips](https://docs.julialang.org/en/v1/manual/performance-tips/), since it transfers the run-time to compile time.

```julia
let biganyv = collect(Any, 1:2:20000)
    @benchmark for i=1:length($biganyv)
        $biganyv[i] += 1
    end
end
```

```julia
let bigfloatv = collect(Float64, 1:2:20000)
    @benchmark for i=1:length($bigfloatv)
        $bigfloatv[i] += 1
    end
end
```

```julia
fib(x::Int) = x <= 2 ? 1 : fib(x-1) + fib(x-2)

@benchmark fib(20)
```

```julia
addup(::Val{x}, ::Val{y}) where {x, y} = Val(x + y)
```

```julia
f(::Val{x}) where x = addup(f(Val(x-1)), f(Val(x-2)))
```

```julia
@benchmark f(Val(20)) end
```


### Example: Image processing

1. Download an image from the internet:
```jl
sco("""
    url = "https://avatars.githubusercontent.com/u/8445510?v=4"
    target_path = tempname() * ".png"
    download(url, target_path)
""")
```

2. Load the image with `Images.jl`:
```jl
using Images
img = load(target_path)

filename = tempname() * ".png"
save(filename, img)
using Markdown
Markdown.MD("![]($filename)")
```

```jl
println("!")
```

```jl
"!"
```