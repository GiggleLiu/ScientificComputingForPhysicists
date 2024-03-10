# source: https://lampz.tugraz.at/~hadley/ss1/phonons/1d/1dphonons.php
struct SpringSystem{T, D} <: AbstractHamiltonianSystem{D}
    r0::Vector{Point{D, T}}   # the position of the atoms
    dr::Vector{Point{D, T}}   # the offset of the atoms
    v::Vector{Point{D, T}}   # the velocity of the atoms
    topology::SimpleGraph{Int}   # the topology of the spring system
    stiffness::Vector{T}  # stiffness of the springs defined on the edges
    mass::Vector{T}       # defined on the atoms
    function SpringSystem(r0::Vector{Point{D, T}}, dr::Vector{Point{D,T}}, v::Vector{Point{D, T}}, topology::SimpleGraph{Int}, stiffness::Vector{T}, mass::Vector{T}) where {T, D}
        @assert length(r0) == length(dr) == length(v) == length(stiffness) == length(mass)
        new{T, D}(r0, dr, v, topology, stiffness, mass)
    end
end
coordinate(sys::SpringSystem) = sys.r0 .+ sys.dr
coordinate(sys::SpringSystem, i::Int) = sys.r0[i] + sys.dr[i]
offset(sys::SpringSystem) = sys.dr
offset(sys::SpringSystem, i::Int) = sys.dr[i]
velocity(sys::SpringSystem) = sys.v
velocity(sys::SpringSystem, i::Int) = sys.v[i]
mass(sys::SpringSystem) = sys.mass
mass(sys::SpringSystem, i::Int) = sys.mass[i]
function offset_coordinate!(sys::SpringSystem, i::Int, val)
    sys.dr[i] += val
end
function offset_velocity!(sys::SpringSystem, i::Int, val)
    sys.v[i] += val
end
Base.length(sys::SpringSystem) = length(sys.r0)
function update_acceleration!(a::AbstractVector{Point{D, T}}, bds::SpringSystem) where {D, T}
    @assert length(a) == length(bds)
    fill!(a, zero(Point{D, T}))
    @inbounds for (k, e) in zip(bds.stiffness, edges(bds.topology))
        i, j = src(e), dst(e)
        f = k * (offset(bds, i) - offset(bds, j))
        a[j] += f / mass(bds, j)
        a[i] -= f / mass(bds, i)
    end
    return a
end

# create a spring chain with n atoms
function spring_chain(offsets::Vector{<:Real}, stiffness::Real, mass::Real; periodic::Bool)
    n = length(offsets)
    r = Point.(0.0:n-1)
    dr = Point.(Float64.(offsets))
    v = fill(Point(0.0), n)
    topology = path_graph(n)
    periodic && add_edge!(topology, n, 1)
    return SpringSystem(r, dr, v, topology, fill(stiffness, n), fill(mass, n))
end

# the eigensystem of the chain: (K - ω^2 M) v = 0, where K is the stiffness matrix, M is the mass matrix
struct EigenSystem{T}
    K::Matrix{T}
    ms::Vector{T}
end
coordinate(e::EigenSystem, i::Int) = e.K[i, i]

# stiffness and mass can be either a scalar or a vector
function eigensystem(spr::SpringSystem{T}) where T
    eigensystem(T, spr.topology, spr.stiffness, spr.mass)
end
function eigensystem(::Type{T}, g::SimpleGraph, stiffness, mass) where T
    n = nv(g)
    M = zeros(T, n)
    M .= mass
    K = zeros(T, n, n)
    for (s, edg) in zip(stiffness, edges(g))
        i, j = src(edg), dst(edg)
        # site i feels a force: stiffness * (x_i - x_j)
        K[i, i] += s
        K[i, j] -= s
        # site j feels a force: -stiffness * (x_i - x_j)
        K[j, j] += s
        K[j, i] -= s
    end
    return EigenSystem(K, M)
end

struct EigenModes{T}
    frequency::Vector{T}
    modes::Matrix{T}
end

function eigenmodes(e::EigenSystem{T}) where T
    vals, vecs = eigen(e.K)
    frequency = sqrt.(vals ./ e.ms)
    return EigenModes(frequency, vecs)
end