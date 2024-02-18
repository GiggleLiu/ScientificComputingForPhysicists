using Makie: RGBA
using Makie, GLMakie

# Set up the visualization with Makie:
lb = lattice_boltzmann()
vorticity = Observable(curl(velocity.(Ref(lb.config), lb.grid))')
fig, ax, plot = image(vorticity, colormap = :jet, colorrange = (-0.1, 0.1))

# Add barrier visualization:
barrier_img = map(x -> x ? RGBA(0, 0, 0, 1) : RGBA(0, 0, 0, 0), lb.barrier)
image!(ax, barrier_img')

record(fig, "lattice_boltzmann_simulation.mp4", 1:100; framerate = 10) do i
    for i=1:20
        step!(lb)
    end
    vorticity[] = curl(velocity.(Ref(lb.config), lb.grid))'
end