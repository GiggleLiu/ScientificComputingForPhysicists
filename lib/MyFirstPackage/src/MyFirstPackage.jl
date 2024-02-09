module MyFirstPackage
# import the OMEinsum package
using OMEinsum

# export `greet` as a public function
export greet

"""
    greet(name::String)
    
Return a greeting message to the input `name`.
"""
function greet(name::String)
    # `$` is used to interpolate the variable `name` into the string
    return "Hello, $(name)!"
end


# this function is not exported
function private_sum(v::AbstractVector{<:Real})
    # we implement the sum function by using the `@ein_str` macro
    # from the OMEinsum package
    return ein"i->"(v)[]
end

end
