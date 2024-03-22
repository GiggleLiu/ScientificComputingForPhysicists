# Plotting tutorial

In this section, we have prepared a set of plotting scripts and simple tutorials to show how to generate different type of pictures.

## Importing 
First, we should import Makie.

```julia
julia> using Pkg
julia> Pkg.add("Makie")
julia> Pkg.add("GLMakie")
```

```julia
julia> using Makie, GLMakie
```

The objects most important for our first steps with Makie are the Figure, the Axis and plots. In a normal Makie plot you will usually find a Figure which contains an Axis which contains one or more plot objects like Lines or Scatter.

In the next steps, we will take a look at how we can create these objects.

### Adding Axis, Lables and Title to a Figure
The most common object you can add to a figure which you need for most plotting is the Axis. The usual syntax for adding such an object to a figure is to specify a position in the Figure's layout as the first argument. We'll learn more about layouts later, but for now the position f[1, 1] will just fill the whole figure.

```julia 
f = Figure()
ax = Axis(f[1, 1],
    title = "A Makie Axis",
    xlabel = "The x label",
    ylabel = "The y label"
)
f
fig.savefig("axis.png")
```
![](/docs/src/assets/images/plot_axis.png)

We can generate a Figure and add axis, xlable, y lable and title to it. 

### Adding a Line Plot to an Axis
Makie has many different plotting functions, the first we will learn about is lines!. Try plotting a sine function into an Axis.
    
```julia
f = Figure()
ax = Axis(f[1, 1])
x = range(0, 10, length=100)
y = sin.(x)
lines!(ax, x, y)
f
```
![](/docs/src/assets/images/plot_lines.png)
There we can get our first line plot.

### Adding a Scatter Plot to an Axis
Another common function is scatter!. It works very similar to lines! but shows separate markers for each input point.

```julia
f = Figure()
ax = Axis(f[1, 1])
x = range(0, 10, length=100)
y = sin.(x)
scatter!(ax, x, y)
f
```
![](/docs/src/assets/images/plot_scatter.png)

### Creating Figure, Axis and plot in one call
We can make a line plot without creating Figure and Axis ourselves first in a easy way.

```julia
x = range(0, 10, length=100)
y = sin.(x)
lines(x, y)
```
![](/docs/src/assets/images/plot_lines_2.png)

