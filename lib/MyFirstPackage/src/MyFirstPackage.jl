module MyFirstPackage
# import the OMEinsum package
using LinearAlgebra

# export `greet` as a public function
export greet
export lorenz, rk4, Lorenz, rk4_step
export Point, Point2D, Point3D
export D2Q9, LatticeBoltzmann, step!, lb_sample, equilibrium_density, velocity, curl

"""
    greet(name::String)
    
Return a greeting message to the input `name`.
"""
function greet(name::String)
    # `$` is used to interpolate the variable `name` into the string
    return "Hello, $(name)!"
end


include("lorenz.jl")
include("fluid.jl")

end
