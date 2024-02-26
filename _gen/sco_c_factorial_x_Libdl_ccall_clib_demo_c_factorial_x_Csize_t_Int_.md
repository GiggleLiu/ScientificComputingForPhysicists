
```language-julia
c_factorial(x) = Libdl.@ccall "clib/demo".c_factorial(x::Csize_t)::Int
```


```output
c_factorial (generic function with 1 method)
```



