Books.is_image(plot::Plot) = true
Books.svg(svg_path::String, p::Plot) = savefig(p, svg_path)
Books.png(png_path::String, p::Plot) = savefig(p, png_path)
