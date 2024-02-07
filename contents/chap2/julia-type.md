## Type and Multiple-dispatch
### Julia Types

Julia has rich type system, which is not limited to the **primitive types** that supported by the hardware. The type system is the key to the **multiple dispatch** feature of Julia.

As an example, let us consider the type for complex numbers.
```julia
Complex{Float64}
```
where `Float64` is the **type parameter** of `Complex`. Type parameters are a part of a type, without which the type is not fully specified. A fully specified type is called a **concrete type**, which can be instantiated in memory.

Extending the example, we can define the type for a matrix of complex numbers.

```julia
Array{Complex{Float64}, 2}
```
`Array` type has two type parameters, the first one is the **element type** and the second one is the **dimension** of the array.

One can get the type of value with `typeof` function.

```julia
julia> typeof(1+2im)

julia> typeof(randn(Complex{Float64}, 2, 2))
```

Then, what the type of a type?
```julia
julia> typeof(Complex{Float64})
DataType
```

### Example: you first type system
We first define of an abstract type for animals with `L` legs.
```julia
julia> abstract type AbstractAnimal{L} end
```

Then we define a concrete type `Dog` with 4 legs, which is a subtype of `AbstractAnimal{4}`.
```julia
julia> struct Dog <: AbstractAnimal{4}
	color::String
end
```

`<:` is the symbol for sybtyping， `A <: B` means A is a subtype of B. Similarly, we define a `Cat` with 4 legs, a `Cock` with 2 legs and a `Human` with 2 legs.

```julia
julia> struct Cat <: AbstractAnimal{4}
	color::String
end

julia> struct Cock <: AbstractAnimal{2}
	gender::Bool
end

julia> struct Human{FT <: Real} <: AbstractAnimal{2}
	height::FT
	function Human(height::T) where T <: Real
		if height <= 0 || height > 300
			error("The tall of a Human being must be in range 0~300, got $(height)")
		end
		return new{T}(height)
	end
end
```
Here, the `Human` type has its own constructor. The `new` function is the default constructor.

We can define a **fall back method** `fight` on the abstract type `AbstractAnimal`

```julia
julia> fight(a::AbstractAnimal, b::AbstractAnimal) = "draw"
```
where `::` is a type assertion.
This function will be invoked if two subtypes of `AbstractAnimal` are fed into the function `fight` and no more **explicit** methods are defined.

We can define many more explicit methods with the same name.

```julia
julia> fight(dog::Dog, cat::Cat) = "win"
fight (generic function with 2 methods)

julia> fight(hum::Human, a::AbstractAnimal) = "win"
fight (generic function with 3 methods)

julia> fight(hum::Human, a::Union{Dog, Cat}) = "loss"
fight (generic function with 4 methods)

julia> fight(hum::AbstractAnimal, a::Human) = "loss"
fight (generic function with 5 methods)
```
where `Union{Dog, Cat}` is a **union type**. It is a type that can be either `Dog` or `Cat`.
Here, we defined 5 methods for the function `fight`. However, defining too many methods for the same function can be dangerous. You need to be careful about the ambiguity error!


```julia
julia> fight(Human(170), Human(180))
ERROR: MethodError: fight(::Human{Int64}, ::Human{Int64}) is ambiguous.

Candidates:
  fight(hum::AbstractAnimal, a::Human)
    @ Main REPL[37]:1
  fight(hum::Human, a::AbstractAnimal)
    @ Main REPL[35]:1

Possible fix, define
  fight(::Human, ::Human)

Stacktrace:
 [1] top-level scope
   @ REPL[38]:1
```

It makes sense because we claim `Human` wins any other animals, but we also claim any animal losses to `Human`. When it comes to two `Human`s, the two functions are equally valid. To resolve the ambiguity, we can define a new method for the function `fight` as follows.
```julia
julia> fight(hum::Human{T}, hum2::Human{T}) where T<:Real = hum.height > hum2.height ? "win" : "loss"
```

Now, we can test the function `fight` with different combinations of animals.
```julia
julia> fight(Cock(true), Cat("red"))
"draw"

julia> fight(Dog("blue"), Cat("white"))
"win"

julia> fight(Human(180), Cat("white"))
"loss"

julia> fight(Human(170), Human(180))
"loss"
```

Quiz: How many method instances are generated for fight so far?

```julia
julia> methodinstances(fight)
```

### Type system
Abstract types and concrete types

- abstract types: types that can have other types as their supertype, but cannot be instantiated themselves. For example, Number is an abstract type, and Integer is a subtype of Number.
- concrete types: types that can be instantiated.
    - primitive types: types that are built into the language, such as `Int64`, `Float64`, `Bool`, and `Char`.
    - composite types: types that are built out of other types. For example, `Complex{Float64}` is a composite type, built out of two `Float64` values.

Only concrete types can be instantiated

```julia
julia> fieldnames(Number)
ERROR: ArgumentError: type does not have a definite number of fields
Stacktrace:
 [1] fieldcount
   @ Base ./reflection.jl:895 [inlined]
 [2] fieldnames(t::DataType)
   @ Base ./reflection.jl:167
 [3] top-level scope
   @ REPL[21]:1

julia> fieldnames(Complex{Float64})
(:re, :im)
```

**Primitive Types**

```bash
primitive type Float16 <: AbstractFloat 16 end
primitive type Float32 <: AbstractFloat 32 end
primitive type Float64 <: AbstractFloat 64 end

primitive type Bool <: Integer 8 end
primitive type Char <: AbstractChar 32 end

primitive type Int8    <: Signed   8 end
primitive type UInt8   <: Unsigned 8 end
primitive type Int16   <: Signed   16 end
primitive type UInt16  <: Unsigned 16 end
primitive type Int32   <: Signed   32 end
primitive type UInt32  <: Unsigned 32 end
primitive type Int64   <: Signed   64 end
primitive type UInt64  <: Unsigned 64 end
primitive type Int128  <: Signed   128 end
primitive type UInt128 <: Unsigned 128 end
```

***Type tree**

```julia
Number
├─ Base.MultiplicativeInverses.MultiplicativeInverse{T}
│  ├─ Base.MultiplicativeInverses.SignedMultiplicativeInverse{T<:Signed}
│  └─ Base.MultiplicativeInverses.UnsignedMultiplicativeInverse{T<:Unsigned}
├─ Complex{T<:Real}
├─ Real
│  ├─ AbstractFloat
│  │  ├─ BigFloat
│  │  ├─ Float16
│  │  ├─ Float32
│  │  └─ Float64
│  ├─ AbstractIrrational
...
```

```julia
julia> subtypes(Number)

julia> supertype(Float64)

julia> AbstractFloat <: Real
```

`Any` is a super type of any other type

```julia
julia> Number <: Any
```

### How to measure the performance of your CPU?

```julia
julia> using BenchmarkTools

julia> A, B = rand(1000, 1000), rand(1000, 1000);

julia> @btime $A * $B
```

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

### The union of types

```julia
julia> Union{AbstractFloat, Complex} <: Number

julia> Union{AbstractFloat, Complex} <: Real
```

NOTE: Union of types is similar to multiple inheritance, but Union can not have subtype!

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

### Multiple dispatch is more powerful than object-oriented programming!
Implement addition in Python.
```python
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

Implement addition in Julian style
```julia
struct X{T}
	num::T
end

struct Y{T}
	num::T
end

Base.:(+)(a::X, b::Y) = X(a.num + b.num)

Base.:(+)(a::Y, b::X) = X(a.num + b.num)

Base.:(+)(a::X, b::X) = X(a.num + b.num)

Base.:(+)(a::Y, b::Y) = Y(a.num + b.num)
```

Multiple dispatch is easier to extend!

If `C` wants to extend this method to a new type `Z`.

```python
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

```julia
struct Z{T}
    num::T
end

Base.:(+)(a::X, b::Z) = Z(a.num + b.num)

Base.:(+)(a::Z, b::X) = Z(a.num + b.num)

Base.:(+)(a::Y, b::Z) = Z(a.num + b.num)

Base.:(+)(a::Z, b::Y) = Z(a.num + b.num)

Base.:(+)(a::Z, b::Z) = Z(a.num + b.num)
```

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

```julia
X(3) + Y(5)
```

```julia
Y(3) + X(5)
```

```julia
X(3) + Z(5)
```

```julia
Z(3) + Y(5)
```

Julia function space is exponetially large!

Quiz: If a function $f$ has $k$ parameters, and the module has $t$ types, how many different functions can be generated?
```jula
f(x::T1, y::T2, z::T3...)
```

If it is an object-oriented language like Python？
```python
class T1:
    def f(self, y, z, ...):
        self.num = num

```

### Summary
* *Multiple dispatch* is a feature of some programming languages in which a function or method can be dynamically dispatched based on the **run-time** type.
* Julia's mutiple dispatch provides exponential abstraction power comparing with an object-oriented language.
* By carefully designed type system, we can program in an exponentially large function space.

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