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
                "chap2/julia-array.md",
                "chap2/julia-release.md",
                "chap2/julia-fluid.md",
        ],
        "Linear Algebra" => [
            "chap3/linalg.md",
            "chap3/linalg-impl.md",
            "chap3/fft.md",
            "chap3/sensitivity.md",
        ],
        "Sparse Matrices" => [
            "chap4/sparse.md",
            # "chap4/compressedsensing.md",
        ],
        "Tensors and Tensor Networks" => [
            "chap5/tensors.md",
        ],
        "Optimization" => [
            "chap6/optimization.md",
            "chap6/ad.md",
            "chap6/complexity.md",
        ],
        "Randomness" => [
            "chap7/montecarlo.md",
        ],
        # "High Performance Computing" => [
        #     "chap7/hpc.md",
        #     "chap7/cuda.md",
        # ],
        "Appendix" => [
            "append/plotting.md"
        ]
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
