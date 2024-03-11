# Fast Fourier transform


### Case study: Image processing

1. Download an image from the internet:
```julia
url = "https://avatars.githubusercontent.com/u/8445510?v=4"
target_path = tempname() * ".png"
download(url, target_path)
```

2. Load the image with [`Images.jl`](https://github.com/JuliaImages/Images.jl):
```@juliaexample image
using Images
img = load(target_path)
```

*Quiz*:
- How to invert the color of the image?
