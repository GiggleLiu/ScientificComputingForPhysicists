# source: https://physics.weber.edu/schroeder/fluids/
using LinearAlgebra

struct Point{D, T <: Real}
    data::NTuple{D, T}
end
const Point2D{T} = Point{2, T}
Point(x::Real...) = Point((x...,))
LinearAlgebra.dot(x::Point, y::Point) = mapreduce(*, +, x.data .* y.data)
Base.:*(x::Real, y::Point) = Point(x .* y.data)
Base.:/(y::Point, x::Real) = Point(y.data ./ x)
Base.:+(x::Point, y::Point) = Point(x.data .+ y.data)
Base.isapprox(x::Point, y::Point; kwargs...) = all(isapprox.(x.data, y.data; kwargs...))
Base.getindex(p::Point, i::Int) = p.data[i]

abstract type LatticeBoltzmannConfig{N} end
struct D2Q9 <: LatticeBoltzmannConfig{9} end
directions(::D2Q9) = (
        Point(0, 0),
        Point(1, 0),
        Point(0, 1),
        Point(-1, 0),
        Point(0, -1),
        Point(1, 1),
        Point(-1, 1),
        Point(-1, -1),
        Point(1, -1)
    )

weights(::D2Q9) = (4/9, 1/9, 1/9, 1/9, 1/9, 1/36, 1/36, 1/36, 1/36)

struct MultiComponentDensity{N, T <: Real}
    data::NTuple{N, T}
end
density(rho::MultiComponentDensity) = sum(rho.data)
function velocity(lb::LatticeBoltzmannConfig, rho::MultiComponentDensity)
    return mapreduce((r, d) -> r * d, +, rho.data, directions(lb)) / density(rho)
end

function _equilibrium_density(ρ, u, ωi, ei)
    return ρ * ωi * (1 + 3 * dot(ei, u) + 9/2 * dot(ei, u)^2 - 3/2 * dot(u, u))
end
function equilibrium_density(lb::LatticeBoltzmannConfig{N}, ρ, u) where N
    ws, ds = weights(lb), directions(lb)
    return MultiComponentDensity(
        ntuple(i->_equilibrium_density(ρ, u, ws[i], ds[i]), N)
    )
end

using Test
@testset "velocity" begin
    lb = D2Q9()
    ds = equilibrium_density(lb, 1.0, Point(0.1, 0.0))
    @test velocity(lb, ds) ≈ Point(0.1, 0.0)
end

function lattice_boltzmann(; 
        height = 80,                       # lattice dimensions
        width = 200,
        u0 = Point(0.1, 0.0)                           # initial and in-flow speed
    )
    rho = equilibrium_density(D2Q9(), 1.0, u0)
    rgrid = fill(rho, height, width)
    # Initialize all the arrays to steady rightward flow:
    ugrid = velocity.(grid)
end

function barrier_setup(height, width)
    # Initialize barriers:
    barrier = falses(height, width)                          # True wherever there's a barrier
    mid = div(height, 2)
    barrier[mid-8:mid+8, div(height,2)] .= true              # simple linear barrier
    barrierN = circshift(barrier, (1, 0))                    # sites just north of barriers
    barrierS = circshift(barrier, (-1, 0))                   # sites just south of barriers
    barrierE = circshift(barrier, (0, 1))                    # etc.
    barrierW = circshift(barrier, (0, -1))
    barrierNE = circshift(barrierN, (0, 1))
    barrierNW = circshift(barrierN, (0, -1))
    barrierSE = circshift(barrierS, (0, 1))
    barrierSW = circshift(barrierS, (0, -1))
end

function stream!(lb::D2Q9, grid::Array{MultiComponentDensity, 2})
    nN  = circshift(nN, (1, 0))
    nNE = circshift(nNE, (1, 1))
    nNW = circshift(nNW, (1, -1))
    nS  = circshift(nS, (-1, 0))
    nSE = circshift(nSE, (-1, 1))
    nSW = circshift(nSW, (-1, -1))
    nE  = circshift(nE, (0, 1))
    nW  = circshift(nW, (0, -1))

    # Use tricky boolean arrays to handle barrier collisions (bounce-back):
    nN[barrierN] = nS[barrier]
    nS[barrierS] = nN[barrier]
    nE[barrierE] = nW[barrier]
    nW[barrierW] = nE[barrier]
    nNE[barrierNE] = nSW[barrier]
    nNW[barrierNW] = nSE[barrier]
    nSE[barrierSE] = nNW[barrier]
    nSW[barrierSW] = nNE[barrier]
end

function collide(lb::LatticeBoltzmannConfig{N}, rho; viscosity = 0.02)
    omega = 1 / (3 * viscosity + 0.5)   # "relaxation" parameter
    # Recompute macroscopic quantities:
    v = velocity(lb, rho)
    return (1 - omega) * rho + omega * equilibrium_density(lb, rho, v)
end

function curl(u::Matrix{Point2D{T}}) where T
    return map(CartesianIndices(u)) do ci
        i, j = ci.I
        uy = u[i, j + 1].y - u[i, j - 1].y
        ux = u[i + 1, j].x - u[i - 1, j].x
        return uy - ux
    end
    # return circshift(uy, (0, -1)) - circshift(uy, (0, 1)) - circshift(ux, (-1, 0)) + circshift(ux, (1, 0))
end

# Set up the visualization with Makie:
vorticity = Observable(curl(ux, uy)')
fig, ax, plot = image(vorticity, colormap = :jet, colorrange = (-0.1, 0.1))

# Add barrier visualization:
using Makie: RGBA
barrier_img = map(x -> x ? RGBA(0, 0, 0, 1) : RGBA(0, 0, 0, 0), barrier)
image!(ax, barrier_img')

# Animation:
function update_scene(frame)
    for step in 1:20
        stream()
        collide()
    end
    vorticity[] = curl(ux, uy)'
end

using LinearAlgebra, Makie, GLMakie
Makie.inline!(true)

record(fig, "lattice_boltzmann_simulation.mp4", 1:100; framerate = 10) do i
    update_scene(i)
end