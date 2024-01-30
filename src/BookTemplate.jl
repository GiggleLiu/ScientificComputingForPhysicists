module BookTemplate

using Reexport: @reexport
@reexport using Books:
	build_all,
	gen,
	sco, #show code and output
	@sco,
	sc, #show code 
	@sc
@reexport using DataFrames:
	DataFrame,
	filter!,
	filter,
	select!,
	select

export M, do_the_fucking_print, show_c_file
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
