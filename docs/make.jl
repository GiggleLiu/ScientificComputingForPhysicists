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
        ]
    ],
)

deploydocs(;
    repo="github.com/GiggleLiu/ScientificComputingForPhysicists.jl",
    devbranch="main",
    devurl="https://book.jinguo-group.science",
)
