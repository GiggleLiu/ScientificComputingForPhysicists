using Makie: RGBA
using Makie, CairoMakie
using PhysicsSimulation

spring = spring_chain(0.2 * randn(20), 3.0, 1.0)
cached_system = LeapFrogSystem(spring)
states = [deepcopy(cached_system)]
for i=1:100
    cached_system = step!(cached_system, 0.2)
    push!(states, deepcopy(cached_system))
end

# visualize the system
p2(x::PhysicsSimulation.Point{1}) = Point2f(x.data[1], 0.0)
getcoos(b::LeapFrogSystem) = p2.(coordinate(b.nbd))
getendpoints(b::LeapFrogSystem) = p2.(coordinate(b.nbd) .+ b.a)
coos = Observable(getcoos(states[1]))
endpoints = Observable(getendpoints(states[1]))
fig, ax, plot = scatter(coos, markersize = 10, color = :blue, limits = (-1, 20, -1, 1))
arrows!(ax, coos, endpoints; color = :red)

record(fig, joinpath(@__DIR__, "springs.mp4"), 2:length(states); framerate = 24) do i
    coos[] = getcoos(states[i])
    endpoints[] = [p2(p * 0.5) for p in states[i].a]
end