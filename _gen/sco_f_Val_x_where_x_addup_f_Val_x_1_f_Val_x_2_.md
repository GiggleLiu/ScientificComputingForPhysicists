
```language-julia
f(::Val{x}) where x = addup(f(Val(x-1)), f(Val(x-2)))
```


```output
f (generic function with 1 method)
```



