# Fluid dynamics simulation with Julia

## Fluid Dynamics Simulation

|  | micro | meso | macro |
| --- | --- | --- | --- |
| **Scale** | $10^{-9}$m | $10^{-9} -10^{-6}$m | $>10^{6}$m |
| **Physics** | molecular | probabilistic | continuous |
| **Gov. equations** | Newton | Boltzmann | Navier-Stokes equations |
| **Method** | Molecular Dynamics | Lattice Boltzmann | Computational Fluid Dynamics |


### If you want to systematically understand LBM

- [Fluid Dynamics Simulation (in Python, Java and Javascript)](https://physics.weber.edu/schroeder/fluids/)

- [YouTube - Introduction to Lattice Boltzmann Method] (https://www.youtube.com/watch?v=jfk4feD7rFQ)


### Lattice Boltzmann Method (LBM)

```@raw html
<img src="/assets/images/lattice.png" alt="image" width="auto" height="auto">
```

For each cell, we define a density distribution function $\rho_{ij}(\mathbf{v})$.

A box of particles collide frequently, they will reach a state of equilibrium.

Question: What defines the equilibrium state, i.e. what is the distribution of particle energy?

### Boltzmann Distribution $p(E) = e^{-\lambda E}$

```@raw html
<img src="/assets/images/Boltzman.png" alt="image" width="auto" height="auto">
```


where $\lambda \sim 1/T$ and $E = \frac{1}{2}mv^2$.

### Define a cell

```julia
# density moving to direction
density(cell, direction)
# total density
density(cell)
```

### D2Q9 model - discrete velocities

```@raw html
<img src="/assets/images/D2Q9.png" alt="image" width="auto" height="auto">
```


```julia
directions = [(0,0), (1,0), (0,1), (-1,0), (0,-1),
    (1,1), (-1,1), (-1,-1), (1,-1)]
```

### An algorithm to approximate the fluid dynamics

Lattice Boltzmann Method (LBM), which contains two steps:
1. Streaming - particles move to neighboring cells
2. Collision - particles collide and exchange momentum


### Streaming

```@raw html
<img src="/assets/images/stream.png" alt="image" width="auto" height="auto">
```

### Collision - Bhatnagar-Gross-Krook (BGK) model.

$\rho\leftarrow(1-\omega)\rho_0+\omega\rho_\mathrm{eq}$


where
$\rho$ is the updated density
$\rho_0$ is the density before collision, and
$\rho_{\text{eq}}$ is the equilibrium density
$\omega = \Delta t/\tau$, where $\tau$ is the (relative) relaxation time

### Equilibrium density

```@raw html
<img src="/assets/images/Equilibrium density.png" alt="image" width="auto" height="auto">
```

- total density $\rho$ is conserved
- momentum $\rho\mathbf{u}$ is conserved


### Live coding

Reference: https://physics.weber.edu/schroeder/fluids/


### Abstract type for lattice Boltzmann configurations

*File*: `src/fluid.jl`

```julia
"""
    AbstractLBConfig{D, N}

An abstract type for lattice Boltzmann configurations.
"""
abstract type AbstractLBConfig{D, N} end
```

### D2Q9

```julia
"""
    D2Q9

A lattice Boltzmann configuration for 2D, 9-velocity model.
"""
struct D2Q9 <: AbstractLBConfig{2, 9} end
directions(::D2Q9) = (
        Point(1, 1), Point(-1, 1),
        Point(1, 0), Point(0, -1),
        Point(0, 0), Point(0, 1),
        Point(-1, 0), Point(1, -1),
        Point(-1, -1),
    )
```

### Utility functions for D2Q9

```julia
# directions[k] is the opposite of directions[flip_direction_index(k)
function flip_direction_index(::D2Q9, i::Int)
    return 10 - i
end
```


### (Grid) Cell

```julia
# the density of the fluid, each component is the density of a velocity
struct Cell{N, T <: Real}
    density::NTuple{N, T}
end
# the total desnity of the fluid
density(cell::Cell) = sum(cell.density)
# the density of the fluid in a specific direction,
# where the direction is an integer
density(cell::Cell, direction::Int) = cell.density[direction]
```

### Total momentum

```julia
"""
    velocity(lb::AbstractLBConfig, rho::Cell)

Compute the velocity of the fluid from the density of the fluid.
"""
function velocity(lb::AbstractLBConfig, rho::Cell)
    return mapreduce((r, d) -> r * d, +, rho.density, directions(lb)) / density(rho)
end
```


### Linear combination of densities
```julia
Base.:+(x::Cell, y::Cell) = Cell(x.density .+ y.density)
Base.:*(x::Real, y::Cell) = Cell(x .* y.density)
```

### Equilibrium density

```julia
"""
    equilibrium_density(lb::AbstractLBConfig, ρ, u)

Compute the equilibrium density of the fluid from the total density and the velocity.
"""
function equilibrium_density(lb::AbstractLBConfig{D, N}, ρ, u) where {D, N}
    ws, ds = weights(lb), directions(lb)
    return Cell(
        ntuple(i-> ρ * ws[i] * _equilibrium_density(u, ds[i]), N)
    )
end
```

```julia
# the distribution of the 9 velocities at the equilibrium state
weights(::D2Q9) = (1/36, 1/36, 1/9, 1/9, 4/9, 1/9, 1/9, 1/36, 1/36)
function _equilibrium_density(u, ei)
    # the equilibrium density of the fluid with a specific mean velocity
    return (1 + 3 * dot(ei, u) + 9/2 * dot(ei, u)^2 - 3/2 * dot(u, u))
end
```

### Streaming step
```julia
# streaming step
function stream!(lb::AbstractLBConfig{2, N}, newgrid::AbstractMatrix{D}, grid::AbstractMatrix{D}, barrier::AbstractMatrix{Bool}) where {N, T, D<:Cell{N, T}}
    ds = directions(lb)
    @inbounds for ci in CartesianIndices(newgrid)
        i, j = ci.I
        newgrid[ci] = Cell(ntuple(N) do k
            ei = ds[k]
            m, n = size(grid)
            i2, j2 = mod1(i - ei[1], m), mod1(j - ei[2], n)
            if barrier[i2, j2]
                density(grid[i, j], flip_direction_index(lb, k))
            else
                density(grid[i2, j2], k)
            end
        end)
    end
end
```

### Collision step

```julia
# collision step, applied on a single cell
function collide(lb::AbstractLBConfig{D, N}, rho; viscosity = 0.02) where {D, N}
    omega = 1 / (3 * viscosity + 0.5)   # "relaxation" parameter
    # Recompute macroscopic quantities:
    v = velocity(lb, rho)
    return (1 - omega) * rho + omega * equilibrium_density(lb, density(rho), v)
end
```

### Curl - for visualization
~~~julia
"""
    curl(u::AbstractMatrix{Point2D{T}})

Compute the curl of the velocity field in 2D, which is defined as:
```math
∂u_y/∂x−∂u_x/∂y
```
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
~~~

### Lattice Boltzmann simulation

```julia
"""
    LatticeBoltzmann{D, N, T, CFG, MT, BT}

A lattice Boltzmann simulation with D dimensions, N velocities, and lattice configuration CFG.
"""

struct LatticeBoltzmann{D, N, T, CFG<:AbstractLBConfig{D, N}, MT<:AbstractMatrix{Cell{N, T}}, BT<:AbstractMatrix{Bool}}
    config::CFG # lattice configuration
    grid::MT    # density of the fluid
    gridcache::MT # cache for the density of the fluid
    barrier::BT # barrier configuration
end
```
```julia
function LatticeBoltzmann(config::AbstractLBConfig{D, N}, grid::AbstractMatrix{<:Cell}, barrier::AbstractMatrix{Bool}) where {D, N}
    @assert size(grid) == size(barrier)
    return LatticeBoltzmann(config, grid, similar(grid), barrier)
end
```

### Single step simulation

```julia
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
```

### The example simulation

A D2Q9 lattice Boltzmann simulation example. A simple linear barrier is added to the lattice.
```julia
function example_d2q9(;
        height = 80, width = 200,
        u0 = Point(0.0, 0.1)) # initial and in-flow speed
    # Initialize all the arrays to steady rightward flow:
    rho = equilibrium_density(D2Q9(), 1.0, u0)
    rgrid = fill(rho, height, width)

    # Initialize barriers:
    barrier = falses(height, width)  # True wherever there's a barrier
    mid = div(height, 2)
    barrier[mid-8:mid+8, div(height,2)] .= true              # simple linear barrier

    return LatticeBoltzmann(D2Q9(), rgrid, barrier)
end
```

### Using the package
*File*: `examples/barrier.jl`

```julia
using Makie: RGBA # for visualization
using Makie, GLMakie
using MyFirstPackage # our package
```

### Simulation and visualization
```julia
# Set up the visualization with Makie:
lb = example_d2q9()
vorticity = Observable(curl(velocity.(Ref(lb.config), lb.grid))')
fig, ax, plot = image(vorticity, colormap = :jet, colorrange = (-0.1, 0.1))

# Show barrier
barrier_img = map(x -> x ? RGBA(0, 0, 0, 1) : RGBA(0, 0, 0, 0), lb.barrier)
image!(ax, barrier_img')
```

### Benchmarking
```julia
using BenchmarkTools
@benchmark step!($(deepcopy(lb)))
```

### Profiling (!!!)

```julia
julia> using Profile

julia> Profile.init(n = 10^7)

julia> @profile for i in 1:100
           step!(lb)
       end
    
julia> Profile.print()
```

### Recording the simulation
```julia
record(fig, joinpath(@__DIR__, "barrier.mp4"), 1:100; framerate = 10) do i
    for i=1:20
        step!(lb)
    end
    vorticity[] = curl(velocity.(Ref(lb.config), lb.grid))'
end
```

### To run
Install dependencies
```julia-pkg
pkg> activate("examples")

pkg> dev .

pkg> add Makie GLMakie BenchmarkTools
```

Type `Backspace` to exit the package mode.

```julia
julia> include("examples/barrier.jl")
```

