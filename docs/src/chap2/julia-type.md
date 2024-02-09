# Types and Multiple-dispatch
### Julia Types

Julia has rich type system, which is not limited to the **primitive types** that supported by the hardware. The type system is the key to the **multiple dispatch** feature of Julia.

As an example, let us consider the type for complex numbers.
```@repl types
Complex{Float64}
```
where `Float64` is the **type parameter** of `Complex`. Type parameters are a part of a type, without which the type is not fully specified. A fully specified type is called a **concrete type**, which has a fixed memory layout and can be instantiated in memory. For example, the `Complex{Float64}` consists of two fields of type `Float64`, which are the real and imaginary parts of the complex number.
```@repl types
fieldnames(Complex{Float64})
fieldtypes(Complex{Float64})
```

Extending the example, we can define the type for a matrix of complex numbers.

```@repl types
Array{Complex{Float64}, 2}
```
`Array` type has two type parameters, the first one is the **element type** and the second one is the **dimension** of the array.

One can get the type of value with `typeof` function.

```@repl types
typeof(1+2im)
typeof(randn(Complex{Float64}, 2, 2))
```

Then, what the type of a type?
```@repl types
typeof(Complex{Float64})
```

There is a very special type: `Tuple`, which is different from regular types in the following ways:

- Tuple types may have any number of parameters.
- Tuple types are covariant in their parameters: `Tuple{Int}` is a subtype of `Tuple{Any}`. Therefore `Tuple{Any}` is considered an abstract type, and tuple types are only concrete if their parameters are.
- Tuples do not have field names; fields are only accessed by index.

```@repl types
tp = (1, 2.0, 'c')
typeof(tp)
tp[2]
```

### Example: define you first type
We first define of an abstract type `AbstractAnimal` with the keyword `abstract type`:
```@repl animal
abstract type AbstractAnimal{L} end
```
where the type parameter `L` stands for the number of legs.
Defining the number of legs as a type parameter or a field of a concrete type is a design choice. Providing more information in the type system can help the compiler to optimize the code, but it can also make the compiler generate more code.

Abstract types can have subtypes. In the following we define a concrete subtype type `Dog` with 4 legs, which is a subtype of `AbstractAnimal{4}`.
```@repl animal
struct Dog <: AbstractAnimal{4}
	color::String
end
```
where `<:` is the symbol for sybtyping， `A <: B` means A is a subtype of B.
Concrete types can have fields, which are the data members of the type. However, they can not have subtypes.

Similarly, we define a `Cat` with 4 legs, a `Cock` with 2 legs and a `Human` with 2 legs.

```@repl animal
struct Cat <: AbstractAnimal{4}
	color::String
end

struct Cock <: AbstractAnimal{2}
	gender::Bool
end

struct Human{FT <: Real} <: AbstractAnimal{2}
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

```@repl animal
fight(a::AbstractAnimal, b::AbstractAnimal) = "draw"
```
where `::` is a type assertion.
This function will be invoked if two subtypes of `AbstractAnimal` are fed into the function `fight` and no more **explicit** methods are defined.

We can define many more explicit methods with the same name.

```@repl animal
fight(dog::Dog, cat::Cat) = "win"
fight(hum::Human, a::AbstractAnimal) = "win"
fight(hum::Human, a::Union{Dog, Cat}) = "loss"
fight(hum::AbstractAnimal, a::Human) = "loss"
```
where `Union{Dog, Cat}` is a **union type**. It is a type that can be either `Dog` or `Cat`.
`Union` types are not concrete since they do not have a fixed memory layout, meanwhile, they can not be subtyped!
Here, we defined 5 methods for the function `fight`. However, defining too many methods for the same function can be dangerous. You need to be careful about the ambiguity error!


```@repl animal; allow_error=true
fight(Human(170), Human(180))
```

It makes sense because we claim `Human` wins any other animals, but we also claim any animal losses to `Human`. When it comes to two `Human`s, the two functions are equally valid. To resolve the ambiguity, we can define a new method for the function `fight` as follows.
```@repl animal
fight(hum::Human{T}, hum2::Human{T}) where T<:Real = hum.height > hum2.height ? "win" : "loss"
```

Now, we can test the function `fight` with different combinations of animals.
```@repl animal
fight(Cock(true), Cat("red"))
fight(Dog("blue"), Cat("white"))
fight(Human(180), Cat("white"))
fight(Human(170), Human(180))
```

Quiz: How many method instances are generated for fight so far?

```@repl animal
julia> methodinstances(fight)
```

### Julia number system
The Julia type system is a tree, and `Any` is the root of type tree, i.e. it is a super type of any other type.
The `Number` type is the root type of Julia number system, which is also a subtype of `Any`.
```@repl number
Number <: Any
```

The type tree rooted on `Number` looks like:
```
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

There are utilities to analyze the type tree:

```@repl number
using InteractiveUtils # hide
subtypes(Number)
supertype(Float64)
AbstractFloat <: Real
```

The leaf nodes of the type tree are called **concrete types**. They are the types that can be instantiated in memory. Among the concrete types, there are **primitive types** and **composite types**. Primitive types are built into the language, such as `Int64`, `Float64`, `Bool`, and `Char`, while composite types are built on top of primitive types, such as `Dict`, `Complex` and the user-defined types.

**The list of primitive types**

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

### Extending the number system - a comparison with object-oriented programming
Extending the number system in Julia is much easier than in object-oriented languages like Python. In the following example, we show how to implement addition operation of a user defined class in Python (feel free to skip if you do not know Python).
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
Here, we implemented the addition operation of two classes `X` and `Y`. The `__add__` method is called when the `+` operator is used with the object on the left-hand side, while the `__radd__` method is called when the object is on the right-hand side.
The output is as follows:
```
X = 8
X = 8
```
It turns out the `__radd__` method of `Y` is not called at all. This is because the `__radd__` method is only called when the object on the left-hand side does not have the `__add__` method by some artifical rules.

Implement addition in Julian style is much easier. We can define the addition operation of two types `X` and `Y` as follows.
```@repl number
struct X{T} <: Number
	num::T
end

struct Y{T} <: Number
	num::T
end

Base.:(+)(a::X, b::Y) = X(a.num + b.num);

Base.:(+)(a::Y, b::X) = X(a.num + b.num);

Base.:(+)(a::X, b::X) = X(a.num + b.num);

Base.:(+)(a::Y, b::Y) = Y(a.num + b.num);
```

Multiple dispatch seems to be more expressive than object-oriented programming.

Now, supposed you want to extend this method to a new type `Z`. In python, he needs to define a new class `Z` as follows.

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
The output is as follows:
```
X = 8
Z = 8
```

No matter how hard you try, you can not make the `__add__` method of `Z` to be called when the object is on the left-hand side.
In Julia, this is not a problem at all. We can define the addition operation of `Z` as follows.

```@repl number
struct Z{T} <: Number
    num::T
end
Base.:(+)(a::X, b::Z) = Z(a.num + b.num);
Base.:(+)(a::Z, b::X) = Z(a.num + b.num);
Base.:(+)(a::Y, b::Z) = Z(a.num + b.num);
Base.:(+)(a::Z, b::Y) = Z(a.num + b.num);
Base.:(+)(a::Z, b::Z) = Z(a.num + b.num);
X(3) + Y(5)
Y(3) + X(5)
X(3) + Z(5)
Z(3) + Y(5)
```

There is a deeper reason why multiple dispatch is more expressive than object-oriented programming. *The Julia function space is exponentially large*!
If a function $f$ has $k$ parameters, and the module has $t$ types, there can be $t^k$ methods for the function $f$:
```jula
f(x::T1, y::T2, z::T3...)
```

Exponential function space allows us to specify the behavior of a function in a very fine-grained way.
However, in an object-oriented language like Python, the function space is only linear to the number of classes.
```python
class T1:
    def f(self, y, z, ...):
        self.num = num

```
The behavior of method `f` is completely determined by the first argument `self`, which means *object-oriented programming is equivalent to single dispatch*.

### Example: Computing Fibonacci number at compile time
The Fibonacci number has a recursive definition:
```@repl number
using BenchmarkTools
fib(x::Int) = x <= 2 ? 1 : fib(x-1) + fib(x-2)
addup(x::Int, y::Int) = x + y
```

```julia-repl
julia> @btime fib(40)
  278.066 ms (0 allocations: 0 bytes)
102334155
```

Oops, it is really slow. There is definitely a better way to calculate the Fibonacci number, but let us stick to this recursive implementation for now.

If you know the Julia type system, you can implement the Fibonacci number in a zero cost way. The trick is to use the type system to calculate the Fibonacci number at compile time. There is a type `Val` defined in the `Base` module, which is just a type with a type parameter. The type parameter can be a number:

```@repl number
Val(3.0)
```

We can define the addition operation of `Val` as the addition of the type parameters.
```@repl number
addup(::Val{x}, ::Val{y}) where {x, y} = Val(x + y)
addup(Val(5), Val(7))
```

Finally, we can define the Fibonacci number in a zero cost way.
```@repl
fib(::Val{x}) where x = x <= 2 ? Val(1) : addup(fib(Val(x-1)), fib(Val(x-2)))
```

```julia-repl
julia> @btime fib(Val(40))
  0.792 ns (0 allocations: 0 bytes)
Val{102334155}()
```
Wow, it computes in no time! However, this trick is not recommended in the [Julia performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/). This implementation simply transfers the run-time computation to the compile time.
On the other hand, we find the compiling time of the function `fib` is much shorter than the run-time. The recursive form turns out to be optimized away by the Julia compiler. But still, it is not recommended to abuse the type system.

### Summary
* *Multiple dispatch* is a feature of some programming languages in which a function or method can be dynamically dispatched based on the **run-time** type.
* Julia's multiple dispatch provides exponential large function space, which allows extending the number system easily.