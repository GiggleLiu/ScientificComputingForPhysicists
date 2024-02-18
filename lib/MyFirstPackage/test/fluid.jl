using Test, MyFirstPackage

@testset "Point" begin
    p1 = Point(1.0, 2.0)
    p2 = Point(3.0, 4.0)
    @test p1 + p2 ≈ Point(4.0, 6.0)
end

@testset "velocity" begin
    lb = D2Q9()
    ds = equilibrium_density(lb, 1.0, Point(0.1, 0.0))
    @test velocity(lb, ds) ≈ Point(0.1, 0.0)
end