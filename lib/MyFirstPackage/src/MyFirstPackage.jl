module MyFirstPackage
# import packages
using LinearAlgebra

# export interfaces
export Lorenz, integrate_step
export Point, Point2D, Point3D
export RungeKutta, Euclidean
export D2Q9, LatticeBoltzmann, step!, equilibrium_density, momentum, curl, example_d2q9, density
export Body, NBodySystem, NBodySystemWithCache, leapfrog_step!, solar_system

include("lorenz.jl")
include("fluid.jl")
include("cuda.jl")
include("planet.jl")

end
