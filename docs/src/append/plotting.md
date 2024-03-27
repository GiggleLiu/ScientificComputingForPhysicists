# Plotting recipes with CairoMakie

In this appendix, we have prepared a set of plotting scripts and simple tutorials to show how to generate different type of pictures, such as line plots, scatter plots, subplots, heatmaps, contour plots, colorbars, arrows, brackets, error bars, stream plots, and text. We will use the CairoMakie library, which is a high-performance, interactive plotting library for Julia. They could be installed by running the following command in the Julia REPL:

```julia
julia> ]add CairoMakie
```
## Importing 
First, we should import CairoMakie libraries to start plotting.

```julia
julia> using CairoMakie
```

Before we start, let's introduce some basic concepts in Makie.jl:
- **Figure**: This is the top-level container for all the elements of your visualization. It can contain multiple plots, as well as other elements like legends, colorbars, etc.

- **Axis**: This is the actual plot, where your data is visualized. An axis can contain multiple graphical elements, like lines, scatter points, surfaces, etc. It also contains the x-axis and y-axis, which have scales (linear, logarithmic, etc.) and ticks. 
- **Plots**: These are the graphical representations of your data. In Makie.jl, create a plot by adding graphical elements (like lines, scatter points, etc.) to an axis. Each type of plot is suited to represent a certain kind of data.

In the next steps, we will take a look at how we can create these objects.


## Line Plot
The following code create line plot with the CairoMakie library, including setting titles, labels, and legends.

```@example makie
using CairoMakie
x = range(0, 10, length=100)
fig = Figure()
# Create an axis with title and labels
ax = Axis(fig[1, 1], title = "Line Plots", xlabel = "X", ylabel = "Y") 
# Create a line plot, set color and label
lines!(ax, x, sin.(x), color = :red, label = "sin") 
# Add another line plot to the same axis
lines!(ax, x, cos.(x), color = :blue, label = "cos") 
# Add a lengend at the bottom right with label size 15
axislegend(ax; position = :rb, labelsize = 15)
save("plot_lines6.png", fig)
fig
```

### Error Bars
Error bars are graphical representations used in statistics and data visualization to indicate the standard deviation of data.

```@example makie
using CairoMakie


fig = Figure()
ax = Axis(fig[1, 1])

xs = 0:0.5:10
ys = 0.5 .* sin.(xs)
# Define the lower and upper errors for each point. 
lowerrors = fill(0.1, length(xs))
higherrors = LinRange(0.1, 0.4, length(xs))
# Add error bars to the plot, with the color ranging from 0 to 1, and the width of the whiskers set to 10.
lines!(ax, xs, ys, color = :blue)
errorbars!(ax, xs, ys, lowerrors, higherrors,
    color = range(0, 1, length = length(xs)),
    whiskerwidth = 10)

# plot position scatters so low and high errors can be discriminated
scatter!(xs, ys, markersize = 3, color = :black)

fig
```

### Texts
In CairoMakie, text can be positioned at specific coordinates on the plot, aligned to different sides, and styled with different fonts, sizes, colors, and rotations.

```@example makie
using CairoMakie

fig = Figure()
ax = Axis(fig[1, 1])
# Add the first line to the axis, with x ranging from 0 to 10 and y, and add a label
lines!(0..10, x -> sin(3x) / (cos(x) + 2),
    label = L"\frac{\sin(3x)}{\cos(x) + 2}")
# Add the second line to the axis, with x ranging from 0 to 10 and y, and add a label.
lines!(0..10, x -> sin(x^2) / (cos(sqrt(x)) + 2),
    label = L"\frac{\sin(x^2)}{\cos(\sqrt{x}) + 2}")
# Add a legend to the figure
Legend(fig[1, 2], ax)

fig
```

### Bracket
In the context of plotting in Julia with the CairoMakie library, a bracket can be added to a plot to highlight or annotate a specific range of values.

```@example makie
using CairoMakie
# Create a line plot of the sine function from 0 to 9, with the x and y grid lines turned off
fig, ax, l = lines(0..9, sin; axis = (; xgridvisible = false, ygridvisible = false))
ylims!(ax, -1.5, 1.5)
# Add a bracket to highlight the period length of the sine function, from (pi/2, 1) to (5pi/2, 1), with an offset of 5, and the text "Period length". The bracket style is square.
bracket!(pi/2, 1, 5pi/2, 1, offset = 5, text = "Period length", style = :square)
# Add a bracket to highlight the amplitude of the sine function, with the text "Amplitude". The bracket is oriented downwards, and the text is aligned to the right and centered vertically.
bracket!(pi/2, 1, pi/2, -1, text = "Amplitude", orientation = :down,
    linestyle = :dash, rotation = 0, align = (:right, :center), textoffset = 4, linewidth = 2, color = :red, textcolor = :red)
# Add a bracket to highlight a falling portion of the sine function, from (2.3, sin(2.3)) to (4.0, sin(4.0)), with the text "Falling". The bracket is oriented upwards.
bracket!(2.3, sin(2.3), 4.0, sin(4.0),
    text = "Falling", offset = 10, orientation = :up, color = :purple, textcolor = :purple)
# Add a bracket to highlight a rising portion of the sine function, from (5.5, sin(5.5)) to (7.0, sin(7.0)), with the text "Rising". The bracket is oriented downwards.
bracket!(Point(5.5, sin(5.5)), Point(7.0, sin(7.0)),
    text = "Rising", offset = 10, orientation = :down, color = :orange, textcolor = :orange, 
    fontsize = 30, textoffset = 30, width = 50)
fig
```

### Subplots
Subplots are a way to display multiple plots in different sub-regions of the same window. The following code demonstrates how to create multiple subplots using the CairoMakie library. It will generate a figure with three line plots, each representing the sin function, but with different colors (red, blue, and green).
```@example makie
using CairoMakie
x = LinRange(0, 10, 100)
y = sin.(x)
fig = Figure()
# Create an axis with title and labels
ax1 = Axis(fig[1, 1], title = "Red Sin Plot", xlabel = "X", ylabel = "Y") 
lines!(ax1, x, y, color = :red, label = "sin")
ax2 = Axis(fig[1, 2], title = "Blue Sin Plot", xlabel = "X", ylabel = "Y")
lines!(ax2, x, y, color = :blue, label = "sin")
# Create a third axis spanning the first two positions of the second row of the figure, set the title, x-axis label, and y-axis label
ax3 = Axis(fig[2, 1:2], title = "Green Sin Plot", xlabel = "X", ylabel = "Y") 
lines!(ax3, x, y, color = :green, label = "sin")

fig
```

## Scatter Plot
A scatter plot is a type of plot used to display the relationship between two variables, where each point represents an observation. The following code will generate a figure with two scatter plots, one representing the sin function and the other representing the cos function.
```@example makie
using CairoMakie

x = range(0, 10, length=100)
fig = Figure()

# Create an axis at the first position of the figure, set the title, x-axis label, and y-axis label
ax = Axis(fig[1, 1], title = "Scatter Plots", xlabel = "X", ylabel = "Y")

# Create a scatter plot on the axis, set the color to red, marker size to 5, and label to "sin"
scatter!(ax, x, sin.(x), color = :red, markersize = 5, label = "sin") 

# Add another scatter plot to the same axis, set the color to blue, marker size to 10, and label to "cos"
scatter!(ax, x, cos.(x), color = :blue, markersize = 10, label = "cos") 

# Set the legend for the axis, position it at the bottom right, and set the label size to 15
axislegend(ax; position = :rb, labelsize = 15)

fig
```

## Bar plot
A bar plot is a type of plot used to visualize categorical data. It consists of rectangular bars with lengths proportional to the values they represent. Bar plots are commonly used to compare the values of different categories or groups.

The following code demonstrates how to create a bar plot using the CairoMakie library. It will generate a figure with a bar plot.
```@example makie
using CairoMakie
# Generate a color palette
colors = Makie.wong_colors()
# Define the data for the bar plot
tbl = (cat = [1, 1, 1, 2, 2, 2, 3, 3, 3],
       height = 0.1:0.1:0.9,
       grp = [1, 2, 3, 1, 2, 3, 1, 2, 3],
       grp1 = [1, 2, 2, 1, 1, 2, 1, 1, 2],
       grp2 = [1, 1, 2, 1, 2, 1, 1, 2, 1]
       )
    
# Figure and Axis
fig = Figure()
ax = Axis(fig[1,1], xticks = (1:3, ["left", "middle", "right"]),
        title = "Dodged bars with legend")

# Plot
barplot!(ax, tbl.cat, tbl.height,
        dodge = tbl.grp,
        color = colors[tbl.grp])

# Define the labels for the legend
labels = ["group 1", "group 2", "group 3"]
# # Create the elements for the legend with custom colors
elements = [PolyElement(polycolor = colors[i]) for i in 1:length(labels)]
title = "Groups"

Legend(fig[1,2], elements, labels, title)

fig
```

## Heatmap 
A heatmap is a graphical representation of data where individual values contained in a matrix are represented as colors. It is a way of visualizing data density or intensity, making it easier to perceive patterns, trends, and outliers within large data sets.

This following code is using CairoMakie to create a heatmap of the Mandelbrot set. The Mandelbrot set is a set of complex numbers for which the function $f(c) = z^2 + c$ does not diverge when iterated from z = 0.

```@example makie
using CairoMakie
fig = Figure()
# Create an axis with title and labels
ax = Axis(fig[1, 1], title = "Heatmap", xlabel = "X", ylabel = "Y") 
# The Mandelbrot function
function mandelbrot(x, y)
    z = c = x + y*im
    for i in 1:30.0; abs(z) > 2 && return i; z = z^2 + c; end; 0
end

hm = heatmap!(ax, -2:0.001:1, -1.1:0.001:1.1, mandelbrot,
    colormap = Reverse(:deep))

# Add a colorbar to the right of the heatmap with the label "Color scale"
Colorbar(fig[1, 2], hm, label = "Color scale") 
fig
```

## Contour Plot
A contour plot is a graphical technique used to represent a 3-dimensional surface in two dimensions. It is like a topographical map in which x and y show the location, and the contour lines represent the third dimension (z) by their level.

Each contour line in a contour plot represents a set of points at the same height or value. The contour plot provides a way to visualize the relationship between three continuous variables. The color or the line style often indicates the value of the third variable. The following code demonstrates how to create a contour plot using the CairoMakie library.

```@example makie
using CairoMakie
# Define the Himmelblau function
himmelblau(x, y) = (x^2 + y - 11)^2 + (x + y^2 - 7)^2
x = y = range(-6, 6; length=100)
# Calculate z-values as the Himmelblau function for each combination of x and y
z = himmelblau.(x, y')
# Define the contour levels as powers of 10 from 0.3 to 3.5
levels = 10.0.^range(0.3, 3.5; length=10)
colorscale = ReversibleScale(x -> x^(1 / 10), x -> x^10)
# Create a contour plot of the z-values, with labels, levels, a hsv colormap, and the defined color scale.

fig = Figure()
ax = Axis(fig[1, 1])

ct = contour!(ax, x, y, z; labels=true, levels, colormap=:hsv, colorscale)
fig
```

### 3D Contour Plot
```@example makie
using CairoMakie

fig = Figure()
# Create a 3D axis at the first position of the figure, set the aspect ratio and perspective
Axis3(fig[1, 1], aspect=(0.5,0.5,1), perspectiveness=0.75)
# Create a linear range of numbers from -0.5 to 0.5, with 100 steps for x and y axes
xs = ys = LinRange(-0.5, 0.5, 100)
zs = [sqrt(x^2+y^2) for x in xs, y in ys]
# Create a 3D contour plot of the negative z-values
contour3d!(-zs, levels=-(.025:0.05:.475), linewidth=2, color=:blue2)
contour3d!(+zs, levels=  .025:0.05:.475,  linewidth=2, color=:red2)

fig
```

## Surface plot
In Makie.jl, a surface plot is a three-dimensional plot that displays a surface defined by a grid of x, y, and z values. It's used to visualize data that changes over two independent variables, much like a topographical map or a view of a landscape.
```@example makie
using CairoMakie
xs = LinRange(0, 10, 100)
ys = LinRange(0, 15, 100)
zs = [cos(x) * sin(y) for x in xs, y in ys]

surface(xs, ys, zs, axis=(type=Axis3,))
```

## Colorbar of heatmap/contour
This Julia code demonstrates how to create heatmaps and contour plots with colorbars using CairoMakie. It first defines a range of x and y values and calculates a corresponding z value for each (x, y) pair. It then creates four subplots: two heatmaps and two contour plots, each with different color maps and level settings. A colorbar is added to each subplot for reference. The `heatmap`, `contourf`, and `Colorbar` functions are used to create the plots and colorbars.
```@example makie
using CairoMakie

xs = LinRange(0, 20, 50)
ys = LinRange(0, 15, 50)
# Calculate z-values 
zs = [cos(x) * sin(y) for x in xs, y in ys]

fig = Figure()
# Create a heatmap at the first position of the figure and add a colorbar
ax, hm = heatmap(fig[1, 1][1, 1], xs, ys, zs)
Colorbar(fig[1, 1][1, 2], hm)
# Create a second heatmap at the second position of the figure with a grayscale colormap
ax, hm = heatmap(fig[1, 2][1, 1], xs, ys, zs, colormap = :grays,
    colorrange = (-0.75, 0.75), highclip = :red, lowclip = :blue)
Colorbar(fig[1, 2][1, 2], hm)
# Create a filled contour plot at the third position of the figure
ax, hm = contourf(fig[2, 1][1, 1], xs, ys, zs,
    levels = -1:0.25:1, colormap = :heat)
Colorbar(fig[2, 1][1, 2], hm, ticks = -1:0.25:1)
# Create a second filled contour plot
ax, hm = contourf(fig[2, 2][1, 1], xs, ys, zs,
    colormap = :Spectral, levels = [-1, -0.5, -0.25, 0, 0.25, 0.5, 1])
Colorbar(fig[2, 2][1, 2], hm, ticks = -1:0.25:1)

fig
```

## Quiver Plot
An arrow plot, also known as a quiver plot, is a type of plot that displays vector fields. This means it shows the direction and magnitude (strength) of data at different points in space. In these plots, each arrow represents a vector and points in the direction the vector is heading. The length (or color) of the arrow can also represent the magnitude of the vector.

The following examples demonstrate how to create 2D and 3D arrows using the CairoMakie library. 

```@example makie
using CairoMakie

fig = Figure(size = (800, 800))
Axis(fig[1, 1], backgroundcolor = "black")

xs = LinRange(0, 2pi, 20)
ys = LinRange(0, 3pi, 20)
# Calculate the u-component of the vectors as the sine of x times the cosine of y for each combination of x and y
us = [sin(x) * cos(y) for x in xs, y in ys]
# Calculate the v-component of the vectors as the negative cosine of x times the sine of y for each combination of x and y
vs = [-cos(x) * sin(y) for x in xs, y in ys]
# Calculate the strength (magnitude) of each vector as the square root of the sum of squares of its u and v components
strength = vec(sqrt.(us .^ 2 .+ vs .^ 2))
# Create a quiver plot with the calculated vectors, specified arrow size and length scale, and color the arrows based on their strength
arrows!(xs, ys, us, vs, arrowsize = 10, lengthscale = 0.3,
    arrowcolor = strength, linecolor = strength)

fig
```


### 3D Quiver Plot

```@example makie
using CairoMakie
using LinearAlgebra

# Create a list of 3D points from -5 to 5 in steps of 2 for x, y, and z coordinates
ps = [Point3f(x, y, z) for x in -5:2:5 for y in -5:2:5 for z in -5:2:5]
# Calculate the direction vectors for each point by swapping the coordinates and scaling by 0.1
ns = map(p -> 0.1 * Vec3f(p[2], p[3], p[1]), ps)
# Calculate the length (norm) of each direction vector
lengths = norm.(ns)
# Create a quiver plot with the calculated points and vectors, turn on anti-aliasing,color the arrows based on their length
# Specify the line width and arrow size, align the arrows at the center, and create a 3D axis 
arrows(
    ps, ns, fxaa=true, # turn on anti-aliasing
    color=lengths,
    linewidth = 0.1, arrowsize = Vec3f(0.3, 0.3, 0.4),
    align = :center, axis=(type=Axis3,)
)
```

## Streamplot
A streamplot is a type of plot used in fluid dynamics to visualize the flow of a fluid. It shows the direction and magnitude of the flow at different points in space. In a streamplot, the flow is represented by a series of lines that follow the direction of the flow. The density of the lines indicates the speed of the flow, with denser lines indicating faster flow.

```@example makie
using CairoMakie

# Define a struct to represent the Fitzhugh-Nagumo model, with parameters ϵ, s, γ, and β
struct FitzhughNagumo{T}
    ϵ::T
    s::T
    γ::T
    β::T
end
# Create an instance of the FitzhughNagumo struct with specific parameter values
P = FitzhughNagumo(0.1, 0.0, 1.5, 0.8)
# Define a function to represent the Fitzhugh-Nagumo model
f(x, P::FitzhughNagumo) = Point2f(
    (x[1]-x[2]-x[1]^3+P.s)/P.ϵ,
    P.γ*x[1]-x[2] + P.β
)
# Define a function to represent the Fitzhugh-Nagumo model with the specific parameter values
f(x) = f(x, P)
# Create a streamplot of the Fitzhugh-Nagumo model in both x and y directions, with the magma colormap
fig, ax, pl = streamplot(f, -1.5..1.5, -1.5..1.5, colormap = :magma)
# Add another streamplot to the figure, with the color set to a function that returns an RGBA color with the alpha channel set to 1
streamplot(fig[1,2], f, -1.5 .. 1.5, -1.5 .. 1.5, color=(p)-> RGBAf(p..., 0.0, 1))
fig
```

## Animation
In Makie.jl, animation is a feature that allows you to create a sequence of frames, each of which is a different plot, and then combine them into a single animated file. This is useful for visualizing changes in data over time or the progression of an algorithm.
```@example makie
using CairoMakie
using CairoMakie.Colors

fig, ax, lineplot = lines(0..10, sin; linewidth=10)

# animation settings
nframes = 30
framerate = 30
# Create an iterator for the hue values that will be used to change the color of the line
hue_iterator = range(0, 360, length=nframes)
# Start recording the animation
record(fig, "color_animation.mp4", hue_iterator;
        framerate = framerate) do hue
    lineplot.color = HSV(hue, 1, 0.75)
end
```
![](../assets/images/color_animation.gif)

### Animation using `Observables`
Often, you want to animate a complex plot over time, and all the data that is displayed should be determined by the current time stamp. Such a dependency is really easy to express with `Observables`.

We can save a lot of work if we create our data depending on a single time `Observable`, so we don't have to change every plot's data manually as the animation progresses.

Here is an example that plots two different functions. The y-values of each depend on time and therefore we only have to change the time for both plots to change. We use the convenient `@lift` macro which denotes that the `lifted` expression depends on each Observable marked with a `$`sign.
```@example makie
using CairoMakie
time = Observable(0.0)

xs = range(0, 7, length=40)

ys_1 = @lift(sin.(xs .- $time))
ys_2 = @lift(cos.(xs .- $time) .+ 3)
# Create a line plot for the sine wave with a dynamic title
fig = lines(xs, ys_1, color = :blue, linewidth = 4,
    axis = (title = @lift("t = $(round($time, digits = 1))"),))
# Add a scatter plot for the cosine wave to the same figure
scatter!(xs, ys_2, color = :red, markersize = 15)
# Set the framerate and the timestamps for the animation
framerate = 10
timestamps = range(0, 2, step=1/framerate)
# Start recording the animation
record(fig, "time_animation.gif", timestamps;
        framerate = framerate) do t
    time[] = t
end
```
![](../assets/images/time_animation.gif)



## More
For more information on plotting with Makie, please refer to the [official documentation](https://docs.makie.org/stable/).