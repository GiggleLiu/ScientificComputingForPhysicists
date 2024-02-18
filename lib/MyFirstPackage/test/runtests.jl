using Test
using MyFirstPackage

@testset "MyFirstPackage" begin
    @test greet("Julia") == "Hello, Julia!"
end

@testset "fluid" begin
    include("fluid.jl")
end