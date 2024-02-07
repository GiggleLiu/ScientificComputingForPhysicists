## Tuple, Array and broadcasting

**Tuple has fixed memory layout, but array does not.**

```jl
sco("""
	tp = (1, 2.0, 'c')
""")
```

```jl
sco("""
	typeof(tp)
""")
```

```jl
sco("""
	isbitstype(typeof(tp))
""")
```

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

```jl
sco("""
	eltype(tp)
""")
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


