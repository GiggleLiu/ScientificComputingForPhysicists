# Compressed sensing

using DataStructures
using Plots
using StatsBase
using Interpolations
using JuMP, SCS
using LinearAlgebra

using Images

using NLSolversBase

using Optim

using FiniteDifferences

# Sparsity Detection

Beyond sparse matrices and Principle Component Analysis (PCA)!"


# Information

A measure of randomness, usually measured by the entropy
```math
S = -\sum_k p_k\log p_k.
```

Quiz: Which knowledge bellow removes more information?
1. When I toss a coin, its head side will be up,
1. Tomorrow will rain,
2. Today's lecture will be a successful one.



# Huffman coding
In computer science and information theory, a Huffman code is a particular type of optimal prefix code that is commonly used for lossless data compression. The process of finding or using such a code proceeds by means of Huffman coding.


Ref: [https://www.programiz.com/dsa/huffman-coding](https://www.programiz.com/dsa/huffman-coding)"

**Task**: describe the following image in computer."

Mondrian - Trafalgar Square, 1939-43 - a picture having little information from various perspective."

LocalResource("images/trafalgar-square.jpg", :width=>300)


## The naive approach
* R: 000
* Y: 001
* B: 010
* K: 011
* W: 100


We need $3mn$ bits to store this image. Can we do better?"


## Observation
Calculate the frequency of each color in the image.
* R: 3%
* Y: 7%
* B: 1%
* K: 10%
* W: 79%



## Formalized description
**Input**

Alphabet ``A=(a_{1},a_{2},\dots ,a_{n})``, which is the symbol alphabet of size ``n``.
Tuple ``{\displaystyle W=(w_{1},w_{2},\dots ,w_{n})}``, which is the tuple of the (positive) symbol weights (usually proportional to probabilities), i.e. ``{\displaystyle w_{i}=\operatorname {weight} \left(a_{i}\right),\,i\in \{1,2,\dots ,n\}}``.

**Output**

Code 
``{\displaystyle C\left(W\right)=(c_{1},c_{2},\dots ,c_{n})}``, which is the tuple of (binary) codewords, where ``c_{i}`` is the codeword for ``{\displaystyle a_{i},\,i\in \{1,2,\dots ,n\}}``.

**Goal**

Let ``{\textstyle L\left(C\left(W\right)\right)=\sum _{i=1}^{n}{w_{i}\operatorname {length} \left(c_{i}\right)}}`` be the weighted path length of code ``C``. Condition: ``{\displaystyle L\left(C\left(W\right)\right)\leq L\left(T\left(W\right)\right)}`` for any code ``{\displaystyle T\left(W\right)}``.



## Algorithm



The simplest construction algorithm uses a priority queue where the node with lowest probability is given highest priority:

1. Create a leaf node for each symbol and add it to the priority queue.
2. While there is more than one node in the queue:
    1. Remove the two nodes of highest priority (lowest probability) from the queue
    2. Create a new internal node with these two nodes as children and with probability equal to the sum of the two nodes' probabilities.
    3. Add the new node to the queue.
3. The remaining node is the root node and the tree is complete.

Since efficient priority queue data structures require $O(\log n)$ time per insertion, and a tree with n leaves has $2n−1$ nodes, this algorithm operates in $O(n \log n)$ time, where $n$ is the number of symbols.


## Implementation"


Build a huffman tree


struct Node{VT, PT}
    value::Union{VT,Nothing}
	prob::PT
    left::Union{Node{VT,PT}, Nothing}
    right::Union{Node{VT,PT}, Nothing}
end

function huffman_tree(symbols, probs)
	isempty(symbols) && error("empty input!")
	# priority queue can keep the items ordered with log(# of items) effort.
	nodes = PriorityQueue(Base.Order.Forward,
		[Node(c, f, nothing, nothing)=>f for (c, f) in zip(symbols, probs)])
    while length(nodes) > 1
        left = dequeue!(nodes)
        right = dequeue!(nodes)
        parent = Node(nothing, left.prob + right.prob, left, right)
        enqueue!(nodes, parent=>left.prob + right.prob)
    end
	return dequeue!(nodes)
end

ht = huffman_tree("RYBKW", [0.03, 0.07, 0.01, 0.1, 0.79])

From the tree, we generate the binary code."

function decent!(tree::Node{VT}, prefix::String="", d::Dict = Dict{VT,String}()) where VT
	if tree.left === nothing # leaft
		d[tree.value] = prefix
	else   # non-leaf
		decent!(tree.left, prefix*"0", d)
		decent!(tree.right, prefix*"1", d)
	end
	return d
end

code_dict = decent!(ht)

mean_code_length = let
	code_length = 0.0
	for (symbol, prob) in zip("RYBKW", [0.03, 0.07, 0.01, 0.1, 0.79])
		code_length += length(code_dict[symbol]) * prob
	end
	code_length
end


We only need $1.36mn$ bits to represent the Mondrian's Trafalgar Square!


## The optimality"

*Lemma*: Huffman Encoding produces an optimal tree.



The compressed text has a minimum size of $Sn$, where
```math
S = -\sum_k p_k\log p_k.
```
It is reached when all non-leaf nodes in the tree are ballanced, i.e. having the same weight for left and right children.


S_trafalgar = StatsBase.entropy([0.03, 0.07, 0.01, 0.1, 0.79], 2)


# Matrix Product State/Tensor Train

Calculate the compression ratio.



# Compressed Sensing



Reference: [https://www.pyrunner.com/weblog/B/index.html](https://www.pyrunner.com/weblog/B/index.html)


## Example 1: Two sinusoids"

import FFTW

Let us define a function of adding two sinusoids."

# sum of two sinusoids
n = 5000

# time sequence
t = LinRange(0, 1/8, n)

# the function
y = sin.(1394π .* t) + sin.(3266π .* t)

plot(t, y; label="the original function")

# the function in the spectrum domain
yt = FFTW.dct(y)

plot(t, yt; label="the function in frequency domain")


Let us extract 10% samples from it.


m = 500

# not allowing repeated indices
samples = sort!(StatsBase.sample(1:n, m, replace=false))

t2 = t[samples]

y2 = y[samples]

let
	plt = plot(t, y; label="the samples")
	scatter!(plt, t2, y2; label="the generated samples", markersize=2)
end

If we plot it directly, it looks not so good"

interp_linear = linear_interpolation(t2, y2; extrapolation_bc=Line())

plot(t, interp_linear.(t))

Why? Because we haven't used a prior that it is sparse in the frequency domain."

plot(t, FFTW.dct(interp_linear.(t)))

Instead, we rephrase the problem as the following convex optimization problem
```math
\begin{align}
&\min\sum_i |x_i|\\
&s.t. A x = b
\end{align}
```


model = Model(SCS.Optimizer)

A = FFTW.idct(Matrix{Float64}(I, n, n), 1)[samples, :]

# do L1 optimization
@variable model x[1:n];

@variable(model, norm1);

@constraint model A * x .== y2;

We use ``l_1`` norm because ``l_0`` is very hard to optimize."

@constraint(model, [norm1; x] in MOI.NormOneCone(1 + length(x)));

@objective(model, Min, norm1);

@bind run_optimize CheckBox()

if run_optimize
	optimize!(model)
	plot([JuMP.value.(x), FFTW.idct(JuMP.value.(x))]; layout=(2, 1), xlim=(0, 1000), labels=["spectrum", "recovered"])
end

# A*JuMP.value.(x) - y2

A * FFTW.dct(interp_linear.(t)) - y2

# norm(JuMP.value.(x), 1)

norm(FFTW.dct(interp_linear.(t)), 1)

## Example 2: Recovering an image"


![](https://www.pyrunner.com/media/uploads/zinnia/2016/05/26/compressed_sensing_slide_2.png)



## Creating a Julia Package
1. Go to the folder for package development,
```bash
cd path/to/julia/dev/folder
```
2. Type the following command
```julia
julia> using PkgTemplates

julia> tpl = Template(; user="GiggleLiu", plugins=[
           GitHubActions(; extra_versions=["nightly"]),
           Git(),
           Codecov()
	], dir=pwd())

julia> tpl("CompressedSensingTutorial")
```
!!! note
    Please replace `GiggleLiu` with your own user name, the `CompressedSensingTutorial` with your own package name! Please check the [document of PkgTemplates](https://juliaci.github.io/PkgTemplates.jl/stable/user/). Now you should see a new package in your current folder.

3. develop your project with, e.g., [VSCode](https://www.julia-vscode.org/).
```bash
cd CompressedSensingTutorial

code .
```
In the VSCode, please use your project environment as your julia project environment, check [here](https://www.julia-vscode.org/docs/dev/userguide/env/).
4. Please configure your project dependency by typing in the `pkg>` mode.
```julia
(CompressedSensingTutorial) pkg> add FFTW FiniteDifferences Images Optim ...
```


https://github.com/timholy/Revise.jl"

source_img = Gray.(Images.load(joinpath(@__DIR__, "images/waterfall.jpeg")))

img = Float64.(source_img);

size(img)

Gray.(FFTW.dct(img))

# We have to use the Pluto ingredients for loading a local project
# Please check the issue: https://github.com/fonsp/Pluto.jl/issues/115#issuecomment-661722426
CT = mod.CompressedSensingTutorial

Let us check the project!"

pixels = CT.sample_image_pixels(img, 0.1)

The objective function."

Gray.(CT.zero_padded(pixels, pixels.values))

@bind do_compressed_sensing CheckBox()

@doc CT.sensing_image

newimg = if do_compressed_sensing
	CT.sensing_image(pixels; C=0.005, optimizer=:LBFGS, show_trace=false, linesearch=Optim.HagerZhang())
else
	rand(size(img)...)
end;

Gray.(newimg)

FFTW.dct(newimg)

newimg[pixels.indices] .- pixels.values


## Related research works
* [Quantum State Tomography via Compressed Sensing.](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.105.150401) David Gross, Yi-Kai Liu, Steven T. Flammia, Stephen Becker, and Jens Eisert. Phys. Rev. Lett. 105, 150401 – Published 4 October 2010



# Kernel PCA



## References:
* [Universal Kernels](https://www.jmlr.org/papers/v7/micchelli06a.html), Charles A. Micchelli, Yuesheng Xu, Haizhang Zhang; 2006.
* [Kernel Principal Component Analysis](https://link.springer.com/chapter/10.1007/BFb0020217), Bernhard Scholkopf, Alexander Smola, Klaus Robert Muller, 1997
* [Universality, Characteristic Kernels and RKHS Embedding of Measures](https://jmlr.org/papers/v12/sriperumbudur11a.html) Sriperumbudur, B. K., Fukumizu, K. & Lanckriet, G. R. G. Journal of Machine Learning Research 12, 2389–2410 (2011).



## Kernel Method



### From dot product to distance
Let $x, y \in R^n$ be two vectors, their distance is defined by
```math
{\rm dist}(x, y) = \|x - y\|^2 = x^T x + y^T y - 2y^T x
```

If we can defined an inner product between two vectors, we can defined a measure of distance.



### Kernel functions
By extending the dot product by an arbitrary symmetric positive definite kernel funciton.
```math
x^T y \rightarrow \kappa(x, y)
```

We have a new measure of distance as
```math
{\rm dist}_\kappa(x, y) = \kappa(x, x) + \kappa(y, y) - 2\kappa(x, y)
```



Given a kernel function, there is a mapping from the original vector space to reproducing kernel Hilbert space (RKHS) associated with it. The kernel function of two vectors can be defined as an inner product of their images in the RKHS.
```math
\kappa(x, y) = \phi(x)^T\phi(y)
```


It is important to note that $\kappa(\cdot, x)$ is nolonger a linear function under this definition of inner product."


### Example
Let $x, y\in \mathbb{R}^2$, a polynomial kernel of order 2 can be defined as
```math
\kappa(x, y) = (x^T y)^2
```

Then we can express the mapping from a vector to RKHS as
```math
\phi(x) = \left(\begin{matrix}x_1^2\\x_2^2\\x_1x_2\\x_2x_1\end{matrix}\right)
```



### Universality of a kernel



A kernel $\kappa$ is universal if and only if the following equation is a universal function approximator.



```math
f = \sum_{j=1}^n c_j \kappa(\cdot, x_j),
```

where $c_j \in \mathbb{R}$ and $x_j$ can be either a number of a vector.



As noted in Micchelli et al. (2006), one can ask whether the function, ``f`` in the above euqation approximates any real-valued target function arbitrarily well as the number of summands increases without bound. This is an important question to consider because if the answer is affirmative, then the kernel-based learning algorithm can be consistent in the sense that for any target function, ``f^⋆``, the discrepancy between ``f`` (which is learned from the training data) and ``f^⋆`` goes to zero (in some appropriate sense) as the sample size goes to infinity.



## Kernel Principle Component Analysis (PCA)

The linear PCA starts from computing a convariance matrix of the data $x_k \in \mathbb{R}^N$, for $k=1,\ldots, l$. We assume the data is centralized, i.e. $\sum_{k} x_k=0$. Then the covariance matrix is defined as
```math
C = \frac{1}{l}\sum_{k=1}^l x_k x_k^T
```

The new coordinates in the eigenvector basis of $C$ are called principle components.



The kernel PCA is defined as the PCA in the RKHS, i.e. 
```math
\overline{C} = \frac{1}{l}\sum_{k=1}^l \phi(x_k)\phi(x_k)^T
```


The eigenvalue problem to solve is
```math
\lambda V = \overline{C} V
```
where $V=\sum_{k=1}^l \alpha_k \phi(x_k)$


By projecting this eigenvalue problem into this subspace, we obtain the following equivalent form
```math
l\lambda \alpha = K \alpha
```
where $K_{ij} = K(x_i, x_j)$.


let
	video = html<iframe width="560" height="315" src="https://www.youtube.com/embed/hmBTACBGWJs" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
	
# Homework

### 1. Autodiff
Given ``A\in \mathbb{R}^{n\times n}`` and ``x, b\in \mathbb{R}^n``. Please derive the backward rule of ``\mathcal{L} = \|Ax - b\|_2`` either using the chain rules or the perturbative approach (from the last lecture).

### 2. Sparsity detection
Choose one.
##### (a). Text compression
Given a text to be compressed:
```
Compressed sensing (also known as compressive sensing, compressive sampling, or sparse sampling) is a signal processing technique for efficiently acquiring and reconstructing a signal, by finding solutions to underdetermined linear systems. This is based on the principle that, through optimization, the sparsity of a signal can be exploited to recover it from far fewer samples than required by the Nyquist–Shannon sampling theorem. There are two conditions under which recovery is possible. The first one is sparsity, which requires the signal to be sparse in some domain. The second one is incoherence, which is applied through the isometric property, which is sufficient for sparse signals.
```
Please
1. Analyse the frequency of each char
2. Create an optimal Huffman coding for each char
3. Encode the text and count the length of total coding (not including the deliminators).

##### (b). Compressed Sensing
Go through the video clip [Compressed Sensing: When It Works](https://youtu.be/hmBTACBGWJs)

$(video)

Please summarize this video clip, and explain when does compressed sensing work and when not.

!!! note
    If you are interested in knowing more about compressed sensing, please do not miss this youtube video paylist: [https://youtube.com/playlist?list=PLMrJAkhIeNNRHP5UA-gIimsXLQyHXxRty](https://youtube.com/playlist?list=PLMrJAkhIeNNRHP5UA-gIimsXLQyHXxRty)

end
