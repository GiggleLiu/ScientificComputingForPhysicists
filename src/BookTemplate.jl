module BookTemplate

# using Books: Books
# using Plots
# using Plots: Plot
# Books.is_image(plot::Plots.Plot) = true
# Books.svg(svg_path::String, p::Plot) = savefig(p, svg_path)
# Books.png(png_path::String, p::Plot) = savefig(p, png_path)



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

export M

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
