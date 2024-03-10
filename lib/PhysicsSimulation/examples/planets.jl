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
getcoo(b::Body, i::Int) = b.r.data[i]
coos = Observable(getcoos(states[1]))
getcoos(b::LeapFrogSystem, i) = getcoo.(b.sys.bodies, i)
getarrows(b) = [Point3f(x.data) for x in b.a]
endpoints = Observable(getarrows(states[1]))
fig = Figure()
ax = Axis3(fig[1, 1]; aspect=:data, perspectiveness=0.5)
scatter!(ax, coos; markersize = 10, color = :blue, limits = (-50, 50, -50, 50, -50, 50))
arrows!(ax, coos, endpoints; color = :red)

record(fig, joinpath(@__DIR__, "planet.mp4"), 2:length(states); framerate = 24) do i
    coos[] = getcoos(states[i])
    endpoints[] = getarrows(states[i])
end