module MyFirstPackage
# import packages
using LinearAlgebra

# export interfaces
export Lorenz, integrate_step
export Point, Point2D, Point3D
export RungeKutta, Euclidean
export D2Q9, LatticeBoltzmann, step!, lb_sample, equilibrium_density, velocity, curl

include("lorenz.jl")
include("fluid.jl")

end
