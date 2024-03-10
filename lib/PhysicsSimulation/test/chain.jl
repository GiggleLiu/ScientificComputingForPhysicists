using Test, PhysicsSimulation, PhysicsSimulation.Graphs

@testset "chain dynamics" begin
    c = spring_chain(10, 1.0, 1.0)
    @test c isa SpringSystem
end