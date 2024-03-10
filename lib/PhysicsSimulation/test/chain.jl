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
    modes = eigenmodes(sys)

    ks_expected = [n * 2π / L for n in 0:L-1]
    omega_expected = sqrt(4C / M) .* sin.(abs.(ks_expected) ./ 2)
    @test isapprox(modes.frequency, sort(omega_expected), atol=1e-5)

    # wave function
    ut(omega::Real, t::Real, A0::AbstractVector; phi0=0.0) = real(exp(-im * omega * t + phi0) * A0)
    wave(idx::Int, t; phi0=0.0) = ut(modes.frequency[idx], t, modes.modes[:,idx]; phi0)
    t = 5.0
    # method 1: solve with leapfrog method
    idx = 2
    c = spring_chain(wave(idx, 0.0), C, M; periodic=true)
    lf = LeapFrogSystem(c)
    for i=1:500
        step!(lf, 0.01)
    end
    ut_lf = first.(coordinate(c))

    # method 2: solve with eigenmodes
    ut_expected = (0:L-1) .+ wave(idx, t)

    @test isapprox(ut_lf, ut_expected; rtol=1e-4)
end