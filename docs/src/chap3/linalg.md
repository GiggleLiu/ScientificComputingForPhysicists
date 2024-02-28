# Basic Linear Algebra

## Matrix multiplication
Matrix multiplication is a fundamental operation in linear algebra. Given two matrices $A\in \mathbb{R}^{m\times n}$ and $B\in \mathbb{R}^{n\times p}$, the product $C = AB$ is defined as
```math
C_{ij} = \sum_{k=1}^n A_{ik}B_{kj}.
```
The time complexity of matrix multiplication is $O(mnp)$.

In Julia, we can implement the matrix multiplication as follows.

```@repl linalg
function mymatmul_rowmajor(A::AbstractMatrix, B::AbstractMatrix)
    m, n = size(A)
    n, p = size(B)
    @assert size(A, 2) == size(B, 1) "size mismatch"
    C = zeros(promote_type(eltype(A), eltype(B)), m, p)
    @inbounds for i = 1:m
        for k = 1:n
            for j = 1:p
                C[i, j] += A[i, k] * B[k, j]
            end
        end
    end
    return C
end
```

```@repl linalg
A, B = randn(1000, 1000), randn(1000, 1000);
using BenchmarkTools
```

```julia-repl
julia> @benchmark mymatmul_rowmajor($A, $B)
BenchmarkTools.Trial: 9 samples with 1 evaluation.
 Range (min … max):  616.256 ms … 621.271 ms  ┊ GC (min … max): 0.00% … 0.19%
 Time  (median):     618.576 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   618.502 ms ±   1.597 ms  ┊ GC (mean ± σ):  0.02% ± 0.06%

  ▁        ▁    █             ▁       ▁    █                  ▁  
  █▁▁▁▁▁▁▁▁█▁▁▁▁█▁▁▁▁▁▁▁▁▁▁▁▁▁█▁▁▁▁▁▁▁█▁▁▁▁█▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█ ▁
  616 ms           Histogram: frequency by time          621 ms <

 Memory estimate: 7.63 MiB, allocs estimate: 2.
```
 
Alternatively, we can iterate over the columns of the matrices first.
```@repl linalg
function mymatmul_colmajor(A::AbstractMatrix, B::AbstractMatrix)
    m, n = size(A)
    n, p = size(B)
    @assert size(A, 2) == size(B, 1) "size mismatch"
    C = zeros(promote_type(eltype(A), eltype(B)), m, p)
    @inbounds for j = 1:p
        for k = 1:n
            for i = 1:m
                C[i, j] += A[i, k] * B[k, j]
            end
        end
    end
    return C
end
```

```julia-repl
julia> @benchmark mymatmul_colmajor($A, $B)
BenchmarkTools.Trial: 34 samples with 1 evaluation.
 Range (min … max):  146.371 ms … 149.116 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     146.895 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   147.138 ms ± 680.122 μs  ┊ GC (mean ± σ):  0.08% ± 0.27%

        ▁█▄ ▄█▄▁ ▁                                               
  ▆▁▁▁▁▁███▆████▆█▆▆▁▁▁▁▁▁▁▁▁▁▁▆▁▁▁▁▁▆▁▁▁▁▁▁▁▁▁▁▁▁▁▁▆▆▆▁▁▁▁▁▁▁▆ ▁
  146 ms           Histogram: frequency by time          149 ms <

 Memory estimate: 7.63 MiB, allocs estimate: 2.
```
    
```julia-repl
julia> @benchmark $A * $B
BenchmarkTools.Trial: 383 samples with 1 evaluation.
 Range (min … max):  12.089 ms … 38.311 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     12.873 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   13.052 ms ±  1.418 ms  ┊ GC (mean ± σ):  1.20% ± 3.41%

       ▄▆▅ ▂▄▇█▇▅▅▄                                            
  ▆▁▁▁▁████████████▆▆▁▄▁▁▄▁▄▁▆▆▇▄▇▄▇█▇▇▁▁▇▁▆▁▆▄▁▄▁▁▁▁▁▁▁▁▁▁▁▄ ▇
  12.1 ms      Histogram: log(frequency) by time      15.8 ms <

 Memory estimate: 7.63 MiB, allocs estimate: 2.
```

The performance of a CPU is measured by the number of **floating point operations per second** (FLOPS) it can perform. The floating point operations include addition, subtraction, multiplication and division. The FLOPS can be related to multiple factors, such as the clock frequency, the number of cores, the number of instructions per cycle, and the number of floating point units. A simple way to measure the FLOPS is to benchmarking the speed of matrix multiplication.
The number of FLOPS in a $n\times n\times n$ matrix multiplication is $2n^3$. The FLOPS can be calculated as: $2 \times 1000^3 / (12.089 \times 10^{-3}) \approx 165~{\rm GFLOPS}$.

## System of Linear Equations
Let $A\in \mathbb{R}^{n\times n}$ be a invertible square matrix and $b \in \mathbb{R}^n$ be a vector. Solving a linear equation means finding a vector $x\in\mathbb{R}^n$ such that
```math
A x = b
```

One can solve a linear equation by following these steps:

1. Decompose the matrix $A \in \mathbb{R}^{n\times n}$ into $L \in \mathbb{R}^{n\times n}$ and $U \in \mathbb{R}^{n\times n}$ matrices using a method such as [Gaussian elimination](@ref) or Crout's method.

2. Rewrite the equation $Ax = b$ as $LUx = b$.

3. Solve for y in $Ly = b$ by [Forward-substitution](@ref). This involves substituting the values of $y$ into the equation one at a time, starting with the first row and working downwards.

4. Solve for $x$ in $Ux = y$ by [Back-substitution](@ref) (link TBA). This involves substituting the values of $x$ into the equation one at a time, starting with the last row and working upwards.

In Julia, we can solve a linear equation using the backslash operator `\` or the `lu` function.

```@repl linalg
A = [1 2; 3 4]
b = [2, 3.0]
```