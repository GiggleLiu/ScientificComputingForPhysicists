## An Introduction to the Julia programming language

### A survey
What programming language do you use? Do you have any pain point about this language?

### What is JuliaLang?
**A modern, open-source, high performance programming lanaguage**

JuliaLang was born in 2012 in MIT, now is maintained by Julia Computing Inc. located in Boston, US. Founders are Jeff Bezanson, Alan Edelman, Stefan Karpinski, Viral B. Shah.

JuliaLang is open-source, its code is maintained on [Github](https://github.com/JuliaLang/julia)(https://github.com/JuliaLang/julia) and it open source LICENSE is MIT.
Julia packages can be found on [JuliaHub](https://juliahub.com/ui/Packages), most of them are open-source.

It is designed for speed.

    <img src="./assets/images/benchmark.svg" alt="image" width="300" height="auto">

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
#### Executing a C program

```jl
# A notebook utility to run code in a terminal style
with_terminal() do
	# display the file
	run(`cat clib/demo.c`)
end# compile to a shared library by piping C_code to gcc;
```

```jl
do_the_fucking_printing()
```








