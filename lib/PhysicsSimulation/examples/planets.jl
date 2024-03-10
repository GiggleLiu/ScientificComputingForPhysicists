using Makie: RGBA
using Makie, CairoMakie
using PhysicsSimulation

cached_system = LeapFrogSystem(solar_system)
states = [deepcopy(cached_system)]
for i=1:1000
    cached_system = step!(cached_system, 0.1)
    push!(states, deepcopy(cached_system))
end

# visualize the system
getcoo(b::Body) = Point3f(b.r.data)
getcoos(b::LeapFrogSystem) = getcoo.(b.nbd.bodies)
coos = Observable(getcoos(states[1]))
accs = Observable([Point3f(p.data) for p in states[1].a])
fig, ax, plot = scatter(coos, markersize = 10, color = :blue)
arrows!(ax, coos, coos[] + accs[]; color = :red)

record(fig, joinpath(@__DIR__, "planet.mp4"), 2:length(states); framerate = 10) do i
    coos[] = getcoos(states[i])
    accs[] = [Point3f(p.data) for p in states[i].a]
end