using CUDA
function stream!(lb::AbstractLBConfig{2, N}, newgrid::CuMatrix{D}, grid::CuMatrix{D}, barrier::CuMatrix{Bool}) where {N, T, D<:Cell{N, T}}
    ds = directions(lb)
    function kernel(newgrid, grid, barrier, ds)
        i, j = CUDA.@cartesianidx newgrid
        @inbounds newgrid[ci] = Cell(ntuple(N) do k
            ei = ds[k]
            m, n = size(grid)
            i2, j2 = mod1(i - ei[1], m), mod1(j - ei[2], n)
            if barrier[i2, j2]
                density(grid[i, j], flip_direction_index(lb, k))
            else
                density(grid[i2, j2], k)
            end
        end)
    end
    CUDA.gpu_call(kernel, newgrid, grid, barrier, ds)
end

function CUDA.cu(lb::LatticeBoltzmann{D, N}) where {D, N}
    return LatticeBoltzmann(lb.config, CuArray(lb.grid), CuArray(lb.barrier))
end