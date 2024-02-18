# Reference: https://physics.weber.edu/schroeder/fluids/
"""
    Point{D, T}

A point in D-dimensional space, with coordinates of type T.

# Examples
```jldoctest
julia> p1 = Point(1.0, 2.0)
Point{2, Float64}((1.0, 2.0))

julia> p2 = Point(3.0, 4.0)
Point{2, Float64}((3.0, 4.0))

julia> p1 + p2
Point{2, Float64}((4.0, 6.0))
```
"""
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

"""
    AbstractLBConfig{D, N}

An abstract type for lattice Boltzmann configurations.
"""
abstract type AbstractLBConfig{D, N} end
    
"""
    D2Q9

A lattice Boltzmann configuration for 2D, 9-velocity model.
"""
struct D2Q9 <: AbstractLBConfig{2, 9} end
directions(::D2Q9) = (
        Point(1, 1),
        Point(-1, 1),
        Point(1, 0),
        Point(0, -1),
        Point(0, 0),
        Point(0, 1),
        Point(-1, 0),
        Point(1, -1),
        Point(-1, -1),
    )

# directions[k] is the opposite of directions[flip_direction_index(k)
function flip_direction_index(::D2Q9, i::Int)
    return 10 - i
end
# the distribution of the 9 velocities at the equilibrium state
weights(::D2Q9) = (1/36, 1/36, 1/9, 1/9, 4/9, 1/9, 1/9, 1/36, 1/36)

# the density of the fluid, each component is the density of a velocity
struct MultiComponentDensity{N, T <: Real}
    data::NTuple{N, T}
end
# the total desnity of the fluid
density(rho::MultiComponentDensity) = sum(rho.data)

"""
    velocity(lb::AbstractLBConfig, rho::MultiComponentDensity)

Compute the velocity of the fluid from the density of the fluid.
"""
function velocity(lb::AbstractLBConfig, rho::MultiComponentDensity)
    return mapreduce((r, d) -> r * d, +, rho.data, directions(lb)) / density(rho)
end
Base.:+(x::MultiComponentDensity, y::MultiComponentDensity) = MultiComponentDensity(x.data .+ y.data)
Base.:*(x::Real, y::MultiComponentDensity) = MultiComponentDensity(x .* y.data)

"""
    equilibrium_density(lb::AbstractLBConfig, ρ, u)

Compute the equilibrium density of the fluid from the total density and the velocity.
"""
function equilibrium_density(lb::AbstractLBConfig{D, N}, ρ, u) where {D, N}
    ws, ds = weights(lb), directions(lb)
    return MultiComponentDensity(
        ntuple(i->_equilibrium_density(ρ, u, ws[i], ds[i]), N)
    )
end
function _equilibrium_density(ρ, u, ωi, ei)
    return ρ * ωi * (1 + 3 * dot(ei, u) + 9/2 * dot(ei, u)^2 - 3/2 * dot(u, u))
end

# streaming step
function stream!(lb::AbstractLBConfig{2, N}, newgrid::AbstractMatrix{D}, grid::AbstractMatrix{D}, barrier::AbstractMatrix{Bool}) where {N, T, D<:MultiComponentDensity{N, T}}
    ds = directions(lb)
    @inbounds for ci in CartesianIndices(newgrid)
        i, j = ci.I
        newgrid[ci] = MultiComponentDensity(ntuple(N) do k
            ei = ds[k]
            m, n = size(grid)
            i2, j2 = mod1(i - ei[1], m), mod1(j - ei[2], n)
            if barrier[i2, j2]
                grid[i, j].data[flip_direction_index(lb, k)]
            else
                grid[i2, j2].data[k]
            end
        end)
    end
end

# collision step, applied on a single cell
function collide(lb::AbstractLBConfig{D, N}, rho; viscosity = 0.02) where {D, N}
    omega = 1 / (3 * viscosity + 0.5)   # "relaxation" parameter
    # Recompute macroscopic quantities:
    v = velocity(lb, rho)
    return (1 - omega) * rho + omega * equilibrium_density(lb, density(rho), v)
end

# ∂uy/∂x−∂ux/∂y, the curl of the velocity field:
"""
    curl(u::AbstractMatrix{Point2D{T}})

Compute the curl of the velocity field.
"""
function curl(u::Matrix{Point2D{T}}) where T 
    return map(CartesianIndices(u)) do ci
        i, j = ci.I
        m, n = size(u)
        uy = u[mod1(i + 1, m), j][2] - u[mod1(i - 1, m), j][2]
        ux = u[i, mod1(j + 1, n)][1] - u[i, mod1(j - 1, n)][1]
        return uy - ux # a factor of 1/2 is missing here?
    end
end

"""
    LatticeBoltzmann{D, N, T, CFG, MT, BT}

A lattice Boltzmann simulation with D dimensions, N velocities, and lattice configuration CFG.

### Fields
- `config::CFG`: lattice configuration
- `grid::MT`: density of the fluid
- `gridcache::MT`: cache for the density of the fluid
- `barrier::BT`: barrier configuration
"""
struct LatticeBoltzmann{D, N, T, CFG<:AbstractLBConfig{D, N}, MT<:AbstractMatrix{MultiComponentDensity{N, T}}, BT<:AbstractMatrix{Bool}}
    config::CFG
    grid::MT
    gridcache::MT
    barrier::BT
end
function LatticeBoltzmann(config::AbstractLBConfig{D, N}, grid::AbstractMatrix{<:MultiComponentDensity}, barrier::AbstractMatrix{Bool}) where {D, N}
    @assert size(grid) == size(barrier)
    return LatticeBoltzmann(config, grid, similar(grid), barrier)
end

"""
    step!(lb::LatticeBoltzmann)

Perform a single step of the lattice Boltzmann simulation.
"""
function step!(lb::LatticeBoltzmann)
    copyto!(lb.gridcache, lb.grid)
    stream!(lb.config, lb.grid, lb.gridcache, lb.barrier)
    lb.grid .= collide.(Ref(lb.config), lb.grid)
    return lb
end

"""
    lb_sample(; height = 80, width = 200, u0 = Point(0.0, 0.1))

Create a lattice Boltzmann simulation with the given parameters.

### Arguments
- `height::Int`: height of the lattice
- `width::Int`: width of the lattice
- `u0::Point2D`: initial and in-flow speed
"""
function lb_sample(; 
        height = 80,                       # lattice dimensions
        width = 200,
        u0 = Point(0.0, 0.1)                           # initial and in-flow speed
    )
    # Initialize all the arrays to steady rightward flow:
    rho = equilibrium_density(D2Q9(), 1.0, u0)
    rgrid = fill(rho, height, width)

    # Initialize barriers:
    barrier = falses(height, width)                          # True wherever there's a barrier
    mid = div(height, 2)
    barrier[mid-8:mid+8, div(height,2)] .= true              # simple linear barrier

    return LatticeBoltzmann(D2Q9(), rgrid, barrier)
end