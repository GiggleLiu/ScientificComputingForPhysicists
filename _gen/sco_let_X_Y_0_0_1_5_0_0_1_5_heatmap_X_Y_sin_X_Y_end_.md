
```language-julia
let
	X, Y = 0:0.1:5, 0:0.1:5
	heatmap(X, Y, sin.(X .+ Y'))
end
```


```output
Plot{Plots.GRBackend() n=1}
```



