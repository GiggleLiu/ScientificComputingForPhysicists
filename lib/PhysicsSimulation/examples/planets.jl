using Makie: RGBA
using Makie, CairoMakie
using PhysicsSimulation

cached_system = LeapFrogSystem(solar_system())
states = [deepcopy(cached_system)]
for i=1:500
    cached_system = step!(cached_system, 0.1)
    push!(states, deepcopy(cached_system))
end

# visualize the system
getcoo(b::Body) = Point3f(b.r.data)
getcoos(b::LeapFrogSystem) = getcoo.(b.sys.bodies)
coos = Observable(getcoos(states[1]))
getarrows(b) = [Point3f(x.data) for x in b.a]
endpoints = Observable(getarrows(states[1]))
fig, ax, plot = scatter(coos, markersize = 10, color = :blue, limits = (-50, 50, -50, 50, -50, 50))
arrows!(ax, coos, endpoints; color = :red)

record(fig, joinpath(@__DIR__, "planet.mp4"), 2:length(states); framerate = 24) do i
    coos[] = getcoos(states[i])
    endpoints[] = getarrows(states[i])
end