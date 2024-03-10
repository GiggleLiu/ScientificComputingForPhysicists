using Test, PhysicsSimulation, PhysicsSimulation.Graphs

@testset "chain dynamics" begin
    c = spring_chain(randn(10) .* 0.1, 1.0, 1.0; periodic=true)
    @test c isa SpringSystem
end

@testset "leapfrog" begin
    c = spring_chain(randn(10) .* 0.1, 1.0, 1.0; periodic=true)
    cached = LeapFrogSystem(c)
    newcache = step!(cached, 0.1)
    @test newcache isa LeapFrogSystem
end

@testset "eigenmodes" begin
    L = 10
    C = 4.0  # stiffness
    M = 2.0  # mass
    c = spring_chain(randn(L) * 0.1, C, M; periodic=true)
    sys = eigensystem(c)
    e = eigenmodes(sys)

    ks_expected = [n * 2π / L for n in 0:L-1]
    omega_expected = sqrt(4C / M) .* sin.(abs.(ks_expected) ./ 2)
    @test isapprox(e.frequency, sort(omega_expected), atol=1e-5)
end