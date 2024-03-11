using Makie: RGBA
using Makie, CairoMakie
using PhysicsSimulation

spring = spring_chain(0.2 * randn(20), 3.0, 1.0; periodic=true)
states = leapfrog_simulation(spring; dt=0.1, nsteps=500)

# visualize the system
p2(x::PhysicsSimulation.Point{1}) = Point2f(x.data[1], 0.0)
getcoos(b::LeapFrogSystem) = p2.(coordinate(b.sys))
getendpoints(b::LeapFrogSystem) = p2.(b.a)

locs = getcoos.(states)
vecs = getendpoints.(states)

fig = Figure()
ax = Axis(fig[1, 1])
coos = Observable(locs[1])
endpoints = Observable(vecs[1])
scatter!(ax, coos, markersize = 10, color = :blue, limits = (-1, length(locs[1]), -1, 1))
arrows!(ax, coos, endpoints; color = :red)

record(fig, joinpath(@__DIR__, "springs-simulate.mp4"), 2:length(states); framerate = 24) do i
    coos[] = locs[i]
    endpoints[] = vecs[i]
end

# visualize eigenmodes
L = 20
C = 3.0  # stiffness
M = 1.0  # mass
c = spring_chain(zeros(L), C, M; periodic=false)
sys = eigensystem(c)
modes = eigenmodes(sys)

# wave function
locations(idx::Int, t) = Point2f.((0:L-1) .+ waveat(modes, idx, t), 0.0)

fig = Figure()
coos = Observable[]
for (k, idx) in enumerate([1, 5, 10, 15])
    ax = Axis(fig[k, 1])
    push!(coos, Observable(locations(idx, 0.0)))
    scatter!(ax, coos[end], markersize = 10, color = :blue, limits = (-1, length(locs[1]), -1, 1))
end

record(fig, joinpath(@__DIR__, "springs.mp4"), 2:length(states); framerate = 24) do i
    t = 0.1 * i
    for (k, idx) in enumerate([2, 5, 10, 15])
        coos[k][] = locations(idx, t)
    end
end