module PhysicsSimulation

using LinearAlgebra, Graphs

export nsite, connections, EigenSystem, eigensystem, EigenModes, eigenmodes
export Body, NewtonSystem, LeapFrogSystem, step!, solar_system
export spring_chain, SpringSystem, coordinate, velocity

include("point.jl")
include("planet.jl")
include("chain.jl")

end
