using ScientificComputingForPhysicists
using Documenter

DocMeta.setdocmeta!(ScientificComputingForPhysicists, :DocTestSetup, :(using ScientificComputingForPhysicists); recursive=true)

makedocs(;
    modules=[ScientificComputingForPhysicists],
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
                "chap2/release.md",
                "chap2/performance.md",
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

deploydocs(;
    repo="github.com/GiggleLiu/ScientificComputingForPhysicists.jl",
    devbranch="main",
    devurl="",
)