using Makie, GLMakie, MyFirstPackage
set_theme!(theme_black())

lz = Lorenz(10, 28, 8/3)
y = MyFirstPackage.Point(1.0, 1.0, 1.0)

points = Observable(Point3f[]) # Signal that can be used to update plots efficiently
colors = Observable(Int[])

fig = Figure(size=(300, 300))
ax = Axis3(fig[1,1]; protrusions = (0, 0, 0, 0), 
              viewmode = :fit,
              limits = (-30, 30, -30, 30, 0, 50))

l = lines!(ax, points; color = colors,
    colormap = :inferno, transparency = true)

# fig, ax, l = lines(points; color = colors,
#     colormap = :inferno, transparency = true, 
#     axis = (; type = Axis3, protrusions = (0, 0, 0, 0), 
#               viewmode = :fit, limits = (-30, 30, -30, 30, 0, 50)))

record(fig, "lorenz.gif", 1:12, framerate=12) do frame
    global y
    for i in 1:200
        # update arrays inplace
        y = integrate_step(lz, RungeKutta{4}(), y, 0.01)
        push!(points[], Point3f(y...))
        push!(colors[], frame)
    end
    ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame / 120) # set the view angle of the axis
    notify(points); notify(colors) # tell points and colors that their value has been updated
    l.colorrange = (0, frame) # update plot attribute directly
end
