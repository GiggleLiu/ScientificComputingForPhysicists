## An Introduction to the Julia programming language

### A survey
What programming language do you use? Do you have any pain point about this language?

### What is JuliaLang?
**A modern, open-source, high performance programming lanaguage**

JuliaLang was born in 2012 in MIT, now is maintained by Julia Computing Inc. located in Boston, US. Founders are Jeff Bezanson, Alan Edelman, Stefan Karpinski, Viral B. Shah.

JuliaLang is open-source, its code is maintained on [Github](https://github.com/JuliaLang/julia)(https://github.com/JuliaLang/julia) and it open source LICENSE is MIT.
Julia packages can be found on [JuliaHub](https://juliahub.com/ui/Packages), most of them are open-source.

It is designed for speed.

 <img src="./assets/images/benchmark.png" alt="image" width="500" height="auto">

### Reference
[arXiv:1209.5145](https://arxiv.org/abs/1209.5145)

**Julia: A Fast Dynamic Language for Technical Computing**

-- Jeff Bezanson, Stefan Karpinski, Viral B. Shah, Alan Edelman

**Dynamic** languages have become popular for scientific computing. They are generally considered highly productive, but lacking in performance. This paper presents Julia, a new dynamic language for technical computing, designed for performance from the beginning by adapting and extending modern programming language techniques. A design based on generic functions and a rich type system simultaneously enables an expressive programming model and successful type inference, leading to good performance for a wide range of programs. This makes it possible for much of the Julia library to be written in Julia itself, while also incorporating best-of-breed C and Fortran libraries.

### Terms explained
- dynamic programming language: In computer science, a dynamic programming language is a class of high-level programming languages, which at runtime execute many common programming behaviours that static programming languages perform during compilation. These behaviors could include an extension of the program, by adding new code, by extending objects and definitions, or by modifying the type system.
- type: In a programming language, a type is a description of a set of values and a set of allowed operations on those values.
- generic function: In computer programming, a generic function is a function defined for polymorphism.
- type inference: Type inference refers to the automatic detection of the type of an expression in a formal language.


### The two language problem
**Executing a C program**

- C code is typed.

- C code needs to be compiled

**One can use `Libdl` package to open a shared library**

```jl
sco("""
	using Libdl
""")
```

```jl
sco("""
	c_factorial(x) = Libdl.@ccall "clib/demo".c_factorial(x::Csize_t)::Int
""")
```

**Typed code may overflow, but is fast!**


```jl
sco("""
	using BenchmarkTools
""")
```



[learn more about calling C code in Julia](https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/)

Discussion: not all type specifications are nessesary.


**Executing a Pyhton Program**

**Dynamic programming language does not require compiling"**

**Dynamic typed language is more flexible, but slow!**

```jl
sco("""
	typemax(Int)
""")
```

**The reason why dynamic typed language is slow is related to caching.**

Dynamic typed language uses `Box(type, *data)` to represent an object.

<img src="./assets/images/data.png" alt="image" width="300" height="auto">



Cache miss!


### Two languages, e.g. Python & C/C++?
**From the maintainance's perspective**

- Requires a build system and configuration files,
- Not easy to train new developers.

**There are many problems can not be vectorized**
- Monte Carlo method and simulated annealing method,
- Generic Tensor Network method: the tensor elements has tropical algebra or finite field algebra,
- Branching and bound.
<img src="./assets/images/pythonc.png" alt="image" width="500" height="auto">

### Julia's solution
NOTE: I should open a Julia REPL now!

**1. Your computer gets a Julia program**

```jl
sco("""
	function jlfactorial(n)
	x = 1
	for i in 1:n
    	x = x * i
	end
	return x
end
""")
```


Method instance is a compiled binary of a function for specific input types. When the function is written, the binary is not yet generated.

```jl
sco("""
	using MethodAnalysis
""")
```


```jl
sco("""
	methodinstances(jlfactorial)
""")
```


**2. When calling a function, the Julia compiler infers types of variables on an intermediate representation (IR)**

<img src="./assets/images/calling function.png" alt="image" width="500" height="auto">

**3. The typed program is then compiled to LLVM IR**
<img src="./assets/images/dragon.png" alt="image" width="300" height="auto">

LLVM is a set of compiler and toolchain technologies that can be used to develop a front end for any programming language and a back end for any instruction set architecture. LLVM is the backend of multiple languages, including Julia, Rust, Swift and Kotlin.



**4. LLVM IR does some optimization, and then compiled to binary code.**

```
with_terminal() do
	@code_native jlfactorial(10)
end
```

**Aftering calling a function, a method instance will be generated.**


**A new method will be generatd whenever there is a new type as the input.**


```jl
sco("""
	jlfactorial(UInt32(10))
""")
```

```jl
sco("""
	methodinstances(jlfactorial)
""")
```

Dynamically generating method instances is also called Just-in-time compiling (JIT), the secret why Julia is fast!

**The key ingredients of performance**
- Rich type information, provided naturally by multiple dispatch;
- aggressive code specialization against run-time types;
- JIT compilation using the LLVM compiler framework.

### Julia's type system
1. Abstract types, which may have declared subtypes and supertypes (a subtype relation is declared using the notation Sub <: Super) 
2. Composite types (similar to C structs), which have named fields and declared supertypes 
3. Bits types, whose values are represented as bit strings, and which have declared supertypes 
4. Tuples, immutable ordered collections of values 
5. Union types, abstract types constructed from other types via set union

**Numbers**
**Type hierachy in Julia is a tree (without multiple inheritance)**

```jl
sco("""
	AbstractFloat <: Real
""")
```

**Abstract types does not have fields, while composite types have**

```jl
sco("""
	Base.isabstracttype(Number)
""")
```

```jl
sco("""
	Base.isconcretetype(Complex{Float64})
""")
```

```jl
sco("""
	fieldnames(Complex)
""")
```


**We have only finite primitive types on a machine, they are those supported natively by computer instruction.**

```jl
sco("""
	Base.isprimitivetype(Float64)
""")
```


**`Any` is a super type of any other type**


```jl
sco("""
	Number <: Any
""")
```


**A type contains two parts: type name and type parameters**

```jl
sco("""
	Complex{Float64}
""")
```


**ComplexF64 is a bits type, it has fixed size**

```jl
sco("""
	sizeof(Complex{Float32})
""")
```

```jl
sco("""
	sizeof(Complex{Float64})
""")
```

But Complex{BigFloat} is not


```jl
sco("""
	sizeof(Complex{BigFloat})
""")
```

```jl
sco("""
	isbitstype(Complex{BigFloat})
""")
```

```jl
sco("""
	Complex{Float64}
""")
```



The size of Complex{BigFloat} is not true! It returns the pointer size!

**A type can be neither abstract nor concrete.**

To represent a complex number with its real and imaginary parts being floating point numbers

```jl
sco("""
	Complex{<:AbstractFloat}
""")
```

```jl
sco("""
	Complex{Float64} <: Complex{<:AbstractFloat}
""")
```

```jl
sco("""
	Base.isabstracttype(Complex{<:AbstractFloat})
""")
```

```jl
sco("""
	Base.isconcretetype(Complex{<:AbstractFloat})
""")
```



**We use Union to represent the union of two types**

```jl
sco("""
	Union{AbstractFloat, Complex} <: Number
""")
```

```jl
sco("""
	Union{AbstractFloat, Complex} <: Real
""")
```

NOTE: it is similar to multiple inheritance, but Union can not have subtype!

**You can make an alias for a type name if you think it is too long**

```jl
sco("""
	FloatAndComplex{T} = Union{T, Complex{T}} where T<:AbstractFloat
""")
```

### Case study: Vector element type and speed

**Any type vector is flexible. You can add any element into it.**

```jl
sco("""
	vany = Any[]  # same as vany = []
""")
```

```jl
sco("""
	typeof(vany)
""")
```

```jl
sco("""
	push!(vany, "a")
""")
```

```jl
sco("""
	push!(vany, 1)
""")
```


**Fixed typed vector is more restrictive.**

```jl
sco("""
	vfloat64 = Float64[]
""")
```

```jl
sco("""
	vfloat64 |> typeof
""")
```

### Multiple dispatch

```jl
sco("""
	abstract type AbstractAnimal{L} end
""")
```

```jl
sco("""
	struct Dog <: AbstractAnimal{4}
	color::String
end
""")
```

<: is the symbol for sybtyping， A <: B means A is a subtype of B.

```jl
sco("""
	struct Cat <: AbstractAnimal{4}
	color::String
end
""")
```

```jl
sco("""
	abstract type AbstractAnimal{L} end
""")
```
**One can implement the same function on different types**

The most general one as the fall back method

```jl
sco("""
	fight(a::AbstractAnimal, b::AbstractAnimal) = "draw"
""")
```


**The most concrete method is called**

```jl
sco("""
	fight(dog::Dog, cat::Cat) = "win"
""")
```

```jl
sco("""
	fight(Dog("blue"), Cat("white"))
""")
```


**A final comment: do not abuse the type system, otherwise the main memory might explode for generating too many functions.**

```jl
sco("""
	fib(x::Int) = x <= 2 ? 1 : fib(x-1) + fib(x-2)
""")
```

**A "zero" cost implementation**

```jl
sco("""
	Val(3.0)
""")
```

```jl
sco("""
	addup(::Val{x}, ::Val{y}) where {x, y} = Val(x + y)
""")
```

```jl
sco("""
	f(::Val{x}) where x = addup(f(Val(x-1)), f(Val(x-2)))
""")
```

```jl
sco("""
	f(::Val{1}) = Val(1)
""")
```

```jl
sco("""
	f(::Val{2}) = Val(1)
""")
```

However, this violates the Performance Tips, since it transfers the run-time to compile time.

### Multiple dispatch is more powerful than object-oriented programming!

Implement addition in Python.

```py
class X:
  def __init__(self, num):
    self.num = num

  def __add__(self, other_obj):
    return X(self.num+other_obj.num)

  def __radd__(self, other_obj):
    return X(other_obj.num + self.num)

  def __str__(self):
    return "X = " + str(self.num)

class Y:
  def __init__(self, num):
    self.num = num

  def __radd__(self, other_obj):
    return Y(self.num+other_obj.num)

  def __str__(self):
    return "Y = " + str(self.num)

print(X(3) + Y(5))


print(Y(3) + X(5))
```

Implement addition in Julia

```jl
sco("""
	struct X{T}
	num::T
end
""")
```

```jl
sco("""
	struct Y{T}
	num::T
end
""")
```

```jl
sco("""
	Base.:(+)(a::X, b::Y) = X(a.num + b.num)
""")
```

```jl
sco("""
	Base.:(+)(a::Y, b::X) = X(a.num + b.num)
""")
```

```jl
sco("""
	Base.:(+)(a::X, b::X) = X(a.num + b.num)
""")
```

```jl
sco("""
	Base.:(+)(a::Y, b::Y) = Y(a.num + b.num)
""")
```

**Multiple dispatch is easier to extend!**

If C wants to extend this method to a new type Z.
```c
class Z:
  def __init__(self, num):
    self.num = num

  def __add__(self, other_obj):
    return Z(self.num+other_obj.num)

  def __radd__(self, other_obj):
    return Z(other_obj.num + self.num)

  def __str__(self):
    return "Z = " + str(self.num)

print(X(3) + Z(5))

print(Z(3) + X(5))
```

```jl
sco("""
	struct Z{T}
	num::T
end
""")
```

```jl
sco("""
	Base.:(+)(a::X, b::Z) = Z(a.num + b.num)
""")
```

```jl
sco("""
	Base.:(+)(a::Z, b::X) = Z(a.num + b.num)
""")
```

```jl
sco("""
	Base.:(+)(a::Y, b::Z) = Z(a.num + b.num)
""")
```

```jl
sco("""
	Base.:(+)(a::Z, b::Y) = Z(a.num + b.num)
""")
```

```jl
sco("""
	Base.:(+)(a::Z, b::Z) = Z(a.num + b.num)
""")
```

```jl
sco("""
	X(3) + Y(5)
""")
```

```jl
sco("""
	Y(3) + X(5)
""")
```

```jl
sco("""
	X(3) + Z(5)
""")
```

```jl
sco("""
	Z(3) + Y(5)
""")
```

**Julia function space is exponetially large!**
Quiz: If a function has parameters, and the module has types, how many different functions can be generated?

```py
f(x::T1, y::T2, z::T3...)
```

If it is an object-oriented language like Python？

```py
class T1:
    def f(self, y, z, ...):
        self.num = num
```

**Summary**
- Multiple dispatch is a feature of some programming languages in which a function or method can be dynamically dispatched based on the run-time type.

- Julia's mutiple dispatch provides exponential abstraction power comparing with an object-oriented language.

- By carefully designed type system, we can program in an exponentially large function space.

### Tuple, Array and broadcasting

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




