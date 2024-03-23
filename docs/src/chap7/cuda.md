# CUDA programming

using Test
using CUDA; CUDA.allowscalar(false)
using BenchmarkTools

TableOfContents()

function highlight(str)
	HTML(<span style="background-color:yellow">$(str)</span>)
end;

# Simulting lattice gas cellular automata"


## Cellular automata
* A descretized space and time,
* A state defined on the space,
* A simple set of rules (local & finite) to describe the evolution of the state.



Reference:
* Hardy J, Pomeau Y, De Pazzis O. Time evolution of a two‐dimensional model system. I. Invariant states and time correlation functions[J]. Journal of Mathematical Physics, 1973, 14(12): 1746-1759.



![](https://upload.wikimedia.org/wikipedia/commons/e/ef/HppModelExamples.jpg)



* Particles exist only on the grid points, never on the edges or surface of the lattice.
* Each particle has an associated direction (from one grid point to another immediately adjacent grid point).
* Each lattice grid cell can only contain a maximum of one particle for each direction, i.e., contain a total of between zero and four particles.

The following rules also govern the model:

* A single particle moves in a fixed direction until it experiences a collision.
* Two particles experiencing a head-on collision are deflected perpendicularly.
* Two particles experience a collision which isn't head-on simply pass through each other and continue in the same direction.
* Optionally, when a particles collides with the edges of a lattice it can rebound.



# CUDA programming with Julia
CUDA programming is a $(highlight("parallel computing platform and programming model")) developed by NVIDIA for performing general-purpose computations on its GPUs (Graphics Processing Units). CUDA stands for Compute Unified Device Architecture.

References:
1. [JuliaComputing/Training](https://github.com/JuliaComputing/Training)
2. [arXiv: 1712.03112](https://arxiv.org/abs/1712.03112)



## Goal
1. Run a CUDA program
3. Write your own CUDA kernel
4. Create a CUDA project


## Run a CUDA program"


1. Make sure you have a NVIDIA GPU device and its driver is properly installed.


run(`nvidia-smi`)

2. Install the [CUDA.jl](https://github.com/JuliaGPU/CUDA.jl) package, and disable scalar indexing of CUDA arrays.

CUDA.jl provides wrappers for several CUDA libraries that are part of the CUDA toolkit:

* Driver library: manage the device, $(highlight("launch kernels")), etc.
* CUBLAS: linear algebra
* CURAND: random number generation
* CUFFT: fast fourier transform
* CUSPARSE: sparse arrays
* CUSOLVER: decompositions & linear systems

There's also support for a couple of libraries that aren't part of the CUDA toolkit, but are commonly used:

* CUDNN: deep neural networks
* CUTENSOR: linear algebra with tensors


CUDA.versioninfo()


3. Choose a device (if multiple devices are available).


devices()

dev = CuDevice(0)

grid > block > thread"

attribute(dev, CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK)

attribute(dev, CUDA.CU_DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_X)

attribute(dev, CUDA.CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X)

4. Create a CUDA Array"

CUDA.zeros(10)

cuarray1 = CUDA.randn(10)

@test_throws ErrorException cuarray1[3]

CUDA.@allowscalar cuarray1[3] += 10

Upload a CPU Array to GPU"

CuArray(randn(10))

5. Compute"


Computing a function on GPU Arrays
1. Launch a CUDA job - a few micro seconds
2. Launch more CUDA jobs...
3. Synchronize threads - a few micro seconds


Computing matrix multiplication."

@elapsed rand(2000,2000) * rand(2000,2000)

@elapsed CUDA.@sync CUDA.rand(2000,2000) * CUDA.rand(2000,2000)

Broadcasting a native Julia function
Julia -> LLVM (optimized for CUDA) -> CUDA
"

factorial(n) = n == 1 ? 1 : factorial(n-1)*n

# this function is copied from lecture 9
function poor_besselj(ν::Int, z::T; atol=eps(T)) where T
    k = 0
    s = (z/2)^ν / factorial(ν)
    out = s::T
    while abs(s) > atol
        k += 1
        s *= -(k+ν) * (z/2)^2 / k
        out += s
    end
    out
end

x = CUDA.CuArray(0.0:0.01:10)

poor_besselj.(1, x)

6. manage your GPU devices"

nvml_dev = NVML.Device(parent_uuid(device()))

NVML.power_usage(nvml_dev)

NVML.utilization_rates(nvml_dev)

NVML.compute_processes(nvml_dev)

## CUDA libraries and Kernel Programming"

Please check [lib/CUDATutorial](../lib/CUDATutorial/kernel.jl)"

# Appendix: The Navier-Stokes equation
Reference: [https://youtu.be/Ra7aQlenTb8](https://youtu.be/Ra7aQlenTb8)


html
<iframe width="560" height="315" src="https://www.youtube.com/embed/Ra7aQlenTb8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>



The navier stokes equation describes the fluid dynamics, which contains the following two parts.

The first one describes the conservation of volume
```math
\nabla \underbrace{u}_{\text{velocity } u \in \mathbb{R}^d} = 0
```

The second one describes the dynamics
```math
\underbrace{\rho}_{\text{density}} \frac{du}{dt} = \underbrace{-\nabla p}_{\text{pressure}} + \underbrace{\mu \nabla^2 u}_{\text{viscosity (or friction)}} + \underbrace{f}_{\text{external force}}.
```


