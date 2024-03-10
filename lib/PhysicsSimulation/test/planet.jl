using Test, PhysicsSimulation

@testset "planets" begin
    @test length(solar_system) == 10
    acc = zeros(Point3D{Float64}, length(solar_system))
    @test length(MyFirstPackage.update_acceleration!(acc, solar_system)) == 10
end

@testset "leapfrog" begin
    cached = MyFirstPackage.DynamicSystem(solar_system)
    newcache = leapfrog_step!(cached, 0.1)
    @test newcache isa DynamicSystem
end