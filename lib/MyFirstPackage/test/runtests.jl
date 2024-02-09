using Test
using MyFirstPackage

@testset "MyFirstPackage" begin
    @test greet("Julia") == "Hello, Julia!"
end

@testset "private sum" begin
    @test MyFirstPackage.private_sum([1, 2, 3]) == 6
    @test MyFirstPackage.private_sum(Int[]) == 0
end
