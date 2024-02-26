using Documenter

makedocs(;
    modules=Module[],
    authors="GiggleLiu",
    sitename="Scientific Computing For Physicists",
    format=Documenter.HTML(;
        canonical="https://book.jinguo-group.science",
        edit_link="main",
        assets=String[],
        size_threshold=2000000,
    ),
    pages=[
        "Home" => "index.md",
        "Become an Open-source Developer" => [
                "chap1/terminal.md",
                "chap1/git.md",
                "chap1/ci.md",
        ],
        "Julia Programming Language" => [
                "chap2/julia-setup.md",
                "chap2/julia-why.md",
                "chap2/julia-type.md",
                "chap2/julia-release.md",
                "chap2/julia-performance.md",
                "chap2/julia-fluid.md",
        ],
        "Tensors (×)" => [
            "chap3/array.md",
            "chap3/linalg.md",
            "chap3/factorization.md",
            "chap3/fft.md",
            "chap3/tensors.md",
            "chap3/cuda.md",
        ],
        "Optimization (×)" => [
            "chap4/combinatorial.md",
            "chap4/optimization.md",
            "chap4/ad.md",
        ],
        "Randomness (×)" => [
            "chap5/montecarlo.md",
        ],
        "Sparsity (×)" => [
            "chap6/sparse.md",
            "chap6/compressedsensing.md",
        ],
        "High Performance Computing (×)" => [
            "chap7/hpc.md",
            "chap7/cuda.md",
        ],
    ],
)

# set site url
open(joinpath(@__DIR__, "build", "CNAME"), "w") do io
    println(io, "book.jinguo-group.science")
end

deploydocs(;
    repo="github.com/GiggleLiu/ScientificComputingForPhysicists.jl",
    devbranch="main",
    devurl="dev",
    versions=["stable"=>"dev", "dev"=>"dev"]
)
