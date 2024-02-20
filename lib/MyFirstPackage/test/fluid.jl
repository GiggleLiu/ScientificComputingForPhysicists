using Test, MyFirstPackage

@testset "velocity" begin
    lb = D2Q9()
    ds = equilibrium_density(lb, 1.0, Point(0.1, 0.0))
    @test velocity(lb, ds) ≈ Point(0.1, 0.0)
end