using LinearAlgebra, Makie, GLMakie
Makie.inline!(true)

# Define constants:
height = 80                       # lattice dimensions
width = 200
viscosity = 0.02                  # fluid viscosity
omega = 1 / (3*viscosity + 0.5)   # "relaxation" parameter
u0 = 0.1                          # initial and in-flow speed
four9ths = 4.0/9.0                # abbreviations for lattice-Boltzmann weight factors
one9th   = 1.0/9.0
one36th  = 1.0/36.0

# Initialize all the arrays to steady rightward flow:
n0 = fill(four9ths * (1.0 - 1.5*u0^2), height, width)    # particle densities along 9 directions
nN = fill(one9th * (1.0 - 1.5*u0^2), height, width)
nS = fill(one9th * (1.0 - 1.5*u0^2), height, width)
nE = fill(one9th * (1.0 + 3*u0 + 4.5*u0^2 - 1.5*u0^2), height, width)
nW = fill(one9th * (1.0 - 3*u0 + 4.5*u0^2 - 1.5*u0^2), height, width)
nNE = fill(one36th * (1.0 + 3*u0 + 4.5*u0^2 - 1.5*u0^2), height, width)
nNW = fill(one36th * (1.0 - 3*u0 + 4.5*u0^2 - 1.5*u0^2), height, width)
nSE = fill(one36th * (1.0 + 3*u0 + 4.5*u0^2 - 1.5*u0^2), height, width)
nSW = fill(one36th * (1.0 - 3*u0 + 4.5*u0^2 - 1.5*u0^2), height, width)
rho = n0 + nN + nS + nE + nW + nNE + nSE + nNW + nSW    # macroscopic density
ux = (nE + nNE + nSE - nW - nNW - nSW) ./ rho            # macroscopic x velocity
uy = (nN + nNE + nNW - nS - nSE - nSW) ./ rho            # macroscopic y velocity

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

function stream()
    global nN, nS, nE, nW, nNE, nNW, nSE, nSW
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

function collide()
    global rho, ux, uy, n0, nN, nS, nE, nW, nNE, nNW, nSE, nSW
    # Recompute macroscopic quantities:
    rho = n0 + nN + nS + nE + nW + nNE + nSE + nNW + nSW
    ux = (nE + nNE + nSE - nW - nNW - nSW) ./ rho
    uy = (nN + nNE + nNW - nS - nSE - nSW) ./ rho
    # Collision step:
    ux2 = ux.^2
    uy2 = uy.^2
    u2 = ux2 + uy2
    omu215 = 1 .- 1.5*u2
    uxuy = ux .* uy
    n0 .= (1-omega).*n0 .+ omega .* four9ths .* rho .* omu215
    nN .= (1-omega).*nN .+ omega .* one9th .* rho .* (omu215 .+ 3 .* uy .+ 4.5.*uy2)
    nS .= (1-omega).*nS .+ omega .* one9th .* rho .* (omu215 .- 3 .* uy .+ 4.5.*uy2)
    nE .= (1-omega).*nE .+ omega .* one9th .* rho .* (omu215 .+ 3 .* ux .+ 4.5.*ux2)
    nW .= (1-omega).*nW .+ omega .* one9th .* rho .* (omu215 .- 3 .* ux .+ 4.5.*ux2)
    nNE .= (1-omega).*nNE .+ omega .* one36th .* rho .* (omu215 .+ 3 .* (ux.+uy) .+ 4.5.*(u2 .+ 2 .* uxuy))
    nNW .= (1-omega).*nNW .+ omega .* one36th .* rho .* (omu215 .+ 3 .* (-ux.+uy) .+ 4.5.*(u2 .- 2 .* uxuy))
    nSE .= (1-omega).*nSE .+ omega .* one36th .* rho .* (omu215 .+ 3 .* (ux.-uy) .+ 4.5.*(u2 .- 2 .* uxuy))
    nSW .= (1-omega).*nSW .+ omega .* one36th .* rho .* (omu215 .+ 3 .* (-ux.-uy) .+ 4.5.*(u2 .+ 2 .* uxuy))
end

function curl(ux, uy)
    return circshift(uy, (0, -1)) - circshift(uy, (0, 1)) - circshift(ux, (-1, 0)) + circshift(ux, (1, 0))
end

# Set up the visualization with Makie:
vorticity = Observable(curl(ux, uy))
fig, ax, plot = image(vorticity, colormap = :jet, colorrange = (-0.1, 0.1))

# Add barrier visualization:
using Makie: RGBA
barrier_img = map(x -> x ? RGBA(0, 0, 0, 1) : RGBA(0, 0, 0, 0), barrier)
image!(ax, barrier_img)

# Animation:
function update_scene(frame)
    for step in 1:20
        stream()
        collide()
    end
    vorticity[] = curl(ux, uy)
end

record(fig, "lattice_boltzmann_simulation.mp4", 1:100; framerate = 10) do i
    update_scene(i)
end