# Basic Linear Algebra

## Matrix multiplication

### Measure your device performance with matrix multiplication
The performance of a CPU is measured by the number of **floating point operations per second** (FLOPS) it can perform. The floating point operations include addition, subtraction, multiplication and division. The FLOPS can be related to multiple factors, such as the clock frequency, the number of cores, the number of instructions per cycle, and the number of floating point units. A simple way to measure the FLOPS is to benchmarking the speed of matrix multiplication.
```@repl profile
A, B = rand(1000, 1000), rand(1000, 1000);
```
```julia-repl
julia> using BenchmarkTools

julia> @btime $A * $B;
  12.122 ms (2 allocations: 7.63 MiB)
```

The number of FLOPS in a $n\times n\times n$ matrix multiplication is $2n^3$. The FLOPS can be calculated as: $2 \times 1000^3 / (12.122 \times 10^{-3}) = 165~{\rm GFLOPS}$.
