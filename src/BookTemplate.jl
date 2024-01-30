module BookTemplate

using Reexport: @reexport
@reexport using Books:
    build_all,
    gen
@reexport using DataFrames:
    DataFrame,
    filter!,
    filter,
    select!,
    select

export M, example_dataframe

export do_the_fucking_print
include("data.jl")
include("callc.jl")

"""
    build()

This function is called during CI.
"""
function build()
    println("Building your awesome book!")
    # To avoid publishing broken websites.
    fail_on_error = true
    gen(; fail_on_error)
    build_all(; fail_on_error)
end

end # module
