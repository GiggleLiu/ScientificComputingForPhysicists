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






**Fixed typed vector is more restrictive.**


**But type stable vectors are faster!**

### Multiple dispatch

<: is the symbol for sybtyping， A <: B means A is a subtype of B.

**One can implement the same function on different types**

The most general one as the fall back method

**The most concrete method is called**

**Be careful about the ambiguity error!**

The combination of two types.

Quiz: How many method instances are generated for fight so far?

**A final comment: do not abuse the type system, otherwise the main memory might explode for generating too many functions.**


A "zero" cost implementation

However, this violates the Performance Tips, since it transfers the run-time to compile time.

### Multiple dispatch is more powerful than object-oriented programming!

Implement addition in Python.

Implement addition in Julia

**Multiple dispatch is easier to extend!**

If C wants to extend this method to a new type Z.

**Julia function space is exponetially large!**
Quiz: If a function has parameters, and the module has types, how many different functions can be generated?

If it is an object-oriented language like Python？

**Summary**
- Multiple dispatch is a feature of some programming languages in which a function or method can be dynamically dispatched based on the run-time type.

- Julia's mutiple dispatch provides exponential abstraction power comparing with an object-oriented language.

- By carefully designed type system, we can program in an exponentially large function space.

### Tuple, Array and broadcasting

**Tuple has fixed memory layout, but array does not.**



**Boardcasting**

**Broadcasting is fast (loop fusing)!**

**Broadcasting over non-concrete element types may be type unstable.**

### Julia package development

The file structure of a package

<img src="./assets/images/julia_dev.png" alt="image" width="500" height="auto">



**Unit Test**

### Case study: Create a package like HappyMolecules

With `PkgTemplates`.

[https://github.com/CodingThrust/HappyMolecules.jl](https://github.com/CodingThrust/HappyMolecules.jl)








