# Fast Fourier transform

## Definition

Given a function $f(x)$ defined on $x \in \mathbb{C}$, the Fourier transformation is defined as

```math
g(u) = \int_{-\infty}^{\infty} e^{-2\pi iux} f(x) dx.
```
The space of $u$ is called the momentum space, and the space of $x$ is called the position space. Its inverse process, or the inverse Fourier transformation is defined as

```math
f(x) = \int_{-\infty}^{\infty} e^{2\pi iux} g(u) dk
```


The two-dimensional Fourier transformation and its inverse transformation are defined as
```math
\begin{align*}
&g(u, v) = \int_{-\infty}^{\infty}dy\int_{-\infty}^\infty e^{-2\pi i(ux+vy)} f(x, y) dx,\\
&f(x, y) = \int_{-\infty}^{\infty}du\int_{-\infty}^\infty e^{2\pi i(ux+vy)} g(u, v) dv.
\end{align*}
```

Fourier transformation is widely used in many fields, including
- Image and audio processing: [YouTube: Image Compression and the FFT, Steve Brunton](https://www.youtube.com/watch?v=gGEBUdM0PVc)
- Solid state physics: Kittel, Charles, and Paul McEuen. Introduction to solid state physics. John Wiley & Sons, 2018.
- Quantum computing: Nielsen, Michael A., and Isaac L. Chuang. Quantum computation and quantum information. Cambridge university press, 2010.
- Fourier optics: Goodman, Joseph W. Introduction to Fourier optics. Roberts and Company publishers, 2005.

## Discrete Fourier Transformation (DFT)

Let $x$ be a vector of length $n$, the DFT of $x$ is defined as
```math
y_{i}=\sum_{n=0}^{n-1}x_{j}\cdot e^{-{\frac {i2\pi }{n}}ij}
```

Since this transformation is linear, we can represent it as a matrix multiplication. Let $F_n$ be the matrix of size $n \times n$ defined as

```math
F_n = \left(
\begin{matrix}
1 & 1 & 1 & \ldots & 1\\
1 & \omega & \omega^2 & \ldots & \omega^{n-1}\\
1 & \omega^2 & \omega^4 & \ldots & \omega^{2n-2}\\
\vdots & \vdots & \vdots & \ddots & \vdots\\
1 & \omega^{n-1} & \omega^{2n-2} & \ldots & \omega^{(n-1)^2}\\
\end{matrix}
\right)
```
where $\omega = e^{-2\pi i/n}$.  This matrix is called the DFT matrix, and the DFT of $x$ is represented as $F_n x$. The inverse transformation is defined as $F_n^\dagger x/n$, i.e. $F_n F_n^\dagger = I$.

```@example fft
using Test, LinearAlgebra

function dft_matrix(n::Int)
    ω = exp(-2π*im/n)
    return [ω^((i-1)*(j-1)) for i=1:n, j=1:n]
end
```

```@repl fft
n = 3
Fn = dft_matrix(n)
dft_matrix(n) * dft_matrix(n)' ./ n
```

## The Cooley–Tukey's Fast Fourier transformation (FFT)

We have a recursive algorithm to compute the DFT.

```math
F_n x = \left(\begin{matrix}I_{n/2} & D_{n/2}\\I_{n/2} & -D_{n/2} \end{matrix}\right)\left(\begin{matrix} F_{n/2} & 0 \\ 0 & F_{n/2}\end{matrix}\right)\left(\begin{matrix}x_{\rm odd}\\x_{\rm even}\end{matrix}\right)
```
where $D_n = {\rm diag}(1, \omega, \omega^2, \ldots, \omega^{n-1})$.

!!! note "Quiz"
    What is the computational complexity of evaluating $F_n x$? Hint: $T(n) = 2 T(n/2) + O(n)$.

```@repl fft
using SparseArrays

@testset "fft decomposition" begin
    n = 4
    Fn = dft_matrix(n)
    F2n = dft_matrix(2n)

    # the permutation matrix to permute elements at 1:2:n (odd) to 1:n÷2 (top half)
    pm = sparse([iseven(j) ? (j÷2+n) : (j+1)÷2 for j=1:2n], 1:2n, ones(2n), 2n, 2n)

    # construct the D matrix
    ω = exp(-π*im/n)
    d1 = Diagonal([ω^(i-1) for i=1:n])

    # construct F_{2n} from F_n
    F2n_ = [Fn d1 * Fn; Fn -d1 * Fn]
    @test F2n * pm' ≈ F2n_
end
```

We implement the $O(n\log(n))$ time Cooley-Tukey FFT algorithm.

```@example fft
function fft!(x::AbstractVector{T}) where T
    N = length(x)
    @inbounds if N <= 1
        return x
    end
 
    # divide
    odd  = x[1:2:N]
    even = x[2:2:N]
 
    # conquer
    fft!(odd)
    fft!(even)
 
    # combine
    @inbounds for i=1:N÷2
       t = exp(T(-2im*π*(i-1)/N)) * even[i]
       oi = odd[i]
       x[i]     = oi + t
       x[i+N÷2] = oi - t
    end
    return x
end
```

```@repl fft
@testset "fft" begin
    x = randn(ComplexF64, 8)
    @test fft!(copy(x)) ≈ dft_matrix(8) * x
end
```

The Julia package `FFTW.jl` contains a superfast FFT implementation.

```@repl fft
using FFTW

@testset "fft" begin
    x = randn(ComplexF64, 8)
    @test FFTW.fft(copy(x)) ≈ dft_matrix(8) * x
end
```

## Application 1: Fast polynomial multiplication

Given two polynomials $p(x)$ and $q(x)$

```math
\begin{align*}
&p(x) = \sum_{k=0}^{n-1} a_k x^k\\
&q(x) = \sum_{k=0}^{n-1} b_k x^k
\end{align*}
```

The multiplication of them is defined as
```math
p(x)q(x) = \sum_{k=0}^{2n-2} c_k x^{k}
```

Fourier transformation can be used to compute the product of two polynomials in $O(n \log n)$ time, which is much faster than the naive algorithm that takes $O(n^2)$ time.

!!! note "Algorithm: Fast polynomial multiplication"
    1. Evaluate $p(x)$ and $q(x)$ at $2n$ points $ω^0, \ldots , ω^{2n−1}$ using DFT. This step takes time $O(n \log n)$.

    2. Obtain the values of $p(x)q(x)$ at these 2n points through pointwise multiplication
    ```math
    \begin{align*}
    (p \circ q)(ω^0) &= p(ω^0) q(ω^0), \\
    (p \circ q)(ω^1) &= p(ω^1) q(ω^1),\\
    &\vdots\\
    (p \circ q)(ω^{2n−1}) &= p(ω^{2n−1}) q(ω^{2n−1}).
    \end{align*}
    ```
    This step takes time $O(n)$.

    3. Interpolate the polynomial $p \circ q$ at the product values using inverse DFT to obtain coefficients $c_0, c_1, \ldots, c_{2n−2}$. This last step requires time $O(n \log n)$.
    We can also use FFT to compute the convolution of two vectors $a = (a_0,\ldots , a_{n−1})$ and $b = (b_0, \ldots , b_{n−1})$, which is defined as a vector $c = (c_0, \ldots , c_{n−1})$ where
    ```math
    c_j = \sum^j_{k=0} a_kb_{j−k}, ~~~~~~ j = 0,\ldots, n − 1.
    ```
    The running time is again $O(n \log n)$.

In the following example, we use the `Polynomials` package to define the polynomial and use the FFT algorithm to compute the product of two polynomials.

```@repl fft
using Polynomials
p = Polynomial([1, 3, 2, 5, 6])
q = Polynomial([3, 1, 6, 2, 2])
```

Step 1: evaluate $p(x)$ at $2n-1$ different points.

```@repl fft
pvals = fft(vcat(p.coeffs, zeros(4)))
```

which is equivalent to computing:

```@repl fft
n = 5
ω = exp(-2π*im/(2n-1))
map(k->p(ω^k), 0:(2n-1))
```

The same for $q(x)$.

```@repl fft
qvals = fft(vcat(q.coeffs, zeros(4)))
```

Step 2: Compute $p(x) q(x)$ at $2n-1$ points.

```@repl fft
pqvals = pvals .* qvals
ifft(pqvals)
```

Summarize:

```@example fft
function fast_polymul(p::AbstractVector, q::AbstractVector)
    pvals = fft(vcat(p, zeros(length(q)-1)))
    qvals = fft(vcat(q, zeros(length(p)-1)))
    pqvals = pvals .* qvals
    return real.(ifft(pqvals))
end

function fast_polymul(p::Polynomial, q::Polynomial)
    Polynomial(fast_polymul(p.coeffs, q.coeffs))
end
```

A similar algorithm has already been implemented in package `Polynomials`. One can easily verify the correctness.

```@repl fft
p * q
fast_polymul(p, q)
```

## Application 2: Image compression


If you google the logo of the Hong Kong University of Science and Technology, you will probably find the following png of size ``2000 \times 3000``.

```@example fft
using Images
img = Images.load("../assets/images/hkust-gz.png")
```

It is too large! We can compress it with the Fourier transformation algorithm.
To simplify the discussion, let us using the gray scale image.

```@example fft
gray_image = Gray.(img)
```

The gray scale image uses 8-bit fixed point numbers as the pixel storage type.
```@repl fft
typeof(gray_image)
img_data = Float32.(gray_image)
img_data_k = fftshift(fft(img_data))
```

it is sparse!
```@example fft
Gray.(abs2.(img_data_k) ./ length(img_data_k))
```

We can store it in the sparse matrix format.

```@example fft
# let us discard all variables smaller than 1e-5
img_data_k[abs.(img_data_k) .< 1e-5] .= 0
sparse_img = sparse(img_data_k)
compression_ratio = nnz(sparse_img) / (2000 * 3000)
recovered_img = ifft(fftshift(Matrix(sparse_img)))
Gray.(abs.(recovered_img))
```