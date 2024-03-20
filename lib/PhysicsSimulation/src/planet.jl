module Bodies
import LinearAlgebra
using ..PhysicsSimulation: Point3D, Point
const mass_solar = 1.988544e30 # in kg
const mass_mercury = 3.302e23
const mass_venus = 48.685e23
const mass_earth = 5.97219e24
const mass_mars = 6.4185e23
const mass_jupyter = 1898.13e24
const mass_saturn = 5.68319e26
const mass_neptune = 102.41e24
const mass_uranus = 86.8103e24
const mass_pluto = 1.307e22

const mass_planetX = 3.2e24 # Planet refers to an additional planet I can add to the solar
# system to test if it is maximally packed. (The solar system is not
# maximally packed. There is room to add another planet and preserve the 
# stable orbit of all planets.)

# NOTE:
# unit of time -> year
# unit of space -> AU
const year = 3.154e7 #year in seconds
const AU = 1.496e11 #in m

const G_standard = 6.67259e-11 # in m^3/(kg-s^2)
const G_year_AU = G_standard * (1 / AU)^3 / (1 / mass_solar * (1 / year)^2)
const dayToYear = 365.25

struct Body{D, T}
    r::Point{D, T}
    v::Point{D, T}
    m::T
end

const mercury = Body(
    Point(8.887985138765460E-02, -4.426150338141062E-01, -4.475716356484761E-02),
    # velocity in AU/day
    Point(2.190877912081542E-02, 7.161568136528000E-03, -1.425929443086507E-03) * dayToYear,
    mass_mercury / mass_solar
)

const venus = Body(
    Point(4.043738093622098E-02, -7.239789211502183E-01, -1.241560658530024E-02),
    Point(2.005742309538389E-02, 1.141448268256643E-03, -1.142174441569258E-03) * dayToYear,
    mass_venus / mass_solar
)

const earth = Body(
    Point(-2.020844529756663E-02, -1.014332737790859E+00, -1.358267619371298E-05),
    Point(1.692836723212859E-02, -3.484006532982474E-04, 6.028542314557626E-07) * dayToYear,
    mass_earth / mass_solar
)

# target 1998
#  -3.466334931755365E-02 -1.013773181327570E+00  2.111689861662178E-04
#   1.692129864984556E-02 -5.252811129268817E-04  3.987686870581435E-07


const mars = Body(
    Point(7.462481663749645E-01, -1.181663652521456E+00, -4.321921404013512E-02),
    Point(1.235610918162121E-02, 8.680869489377649E-03, -1.220500608452554E-04) * dayToYear,
    mass_mars / mass_solar
)

# const planetX = Body(
#     Point(0.0, 2.06, 0.0),
#     Point(1.235610918162121E-02, 0.0, 0.0),
#     mass_planetX / mass_solar
# )

const jupyter = Body(
    Point(3.384805319103406E+00, 3.658805636759595E+00, -9.100441946210819E-02),
    Point(-5.634671617093230E-03, 5.479180979634376E-03, 1.034981407898108E-04) * dayToYear,
    mass_jupyter / mass_solar
)

const saturn = Body(
    Point(-1.083899692644216E-01, -1.003995196286016E+01, 1.793391553155583E-01),
    Point(5.278410787728323E-03, -7.712342079566598E-05, -2.084447335785041E-04) * dayToYear,
    mass_saturn / mass_solar
)

const neptune = Body(
    Point(4.675566709791660E+00, -2.985428200863175E+01, 5.070034142531887E-01),
    Point(3.080716380724798E-03, 5.030733458293977E-04, -8.101711269674541E-05) * dayToYear,
    mass_neptune / mass_solar
)

const uranus = Body(
    Point(-2.693448460292631E-01, -1.927606446869220E+01, -6.808868692550485E-02),
    Point(3.903100242621723E-03, -2.380111092360100E-04, -5.164025224695875E-05) * dayToYear,
    mass_uranus / mass_solar
)

const pluto = Body(
    Point(-2.129074273328636E+01, -1.896633337434039E+01, 8.187955378677129E+00),
    Point(2.276295756013608E-03, -2.670481848836963E-03, -3.669545371032554E-04) * dayToYear,
    mass_pluto / mass_solar
)


# target  -1.156541154581570E+01 -2.704864218000164E+01  6.239749761161465E+00
#   2.964408290188142E-03 -1.722224413824548E-03 -6.839434010481107E-04

const sun = Body(
    Point(-3.430031536367300E-03, 1.761881027012596E-03, 1.246691303879918E-05),
    Point(3.433119412673547E-06, -5.231300927361546E-06, -2.972974735550750E-08) * dayToYear,
    1.0
)

abstract type AbstractHamiltonianSystem{D} end
struct NewtonSystem{D, T} <: AbstractHamiltonianSystem{D}
    bodies::Vector{Body{D, T}}
end
coordinate(b::NewtonSystem) = [b.bodies[i].r for i in 1:length(b.bodies)]
coordinate(b::NewtonSystem, i::Int) = b.bodies[i].r
function offset_coordinate!(b::NewtonSystem, i::Int, val)
    b.bodies[i] = Body(b.bodies[i].r + val, b.bodies[i].v, b.bodies[i].m)
end
function offset_velocity!(b::NewtonSystem, i::Int, val)
    b.bodies[i] = Body(b.bodies[i].r, b.bodies[i].v + val, b.bodies[i].m)
end
velocity(b::NewtonSystem) = [b.bodies[i].v for i in 1:length(b.bodies)]
velocity(b::NewtonSystem, i::Int) = b.bodies[i].v
mass(b::NewtonSystem) = [b.bodies[i].m for i in 1:length(b.bodies)]
mass(b::NewtonSystem, i::Int) = b.bodies[i].m
Base.length(bds::NewtonSystem) = length(bds.bodies)
solar_system() = NewtonSystem([sun, mercury, venus, earth, mars, jupyter, saturn, uranus, neptune, pluto])


end


using .Bodies: G_year_AU, Body, solar_system, NewtonSystem, AbstractHamiltonianSystem
import .Bodies: coordinate, velocity, offset_coordinate!, offset_velocity!, mass

function energy(bds::NewtonSystem{T}) where T
    eng = zero(T)
    # kinetic energy
    for p in bds.bodies
        eng += p.m * norm2(p.v) / 2
    end
    # potential energy
    for j in 1:length(bds)
        pj = bds.planets[j]
        for k in j+1:bds.nplanets
            pk = bds.planets[k]
            eng -= G_year_AU * pj.m * pk.m / sqdist(pj.r, pk.r)
        end
    end
    eng
end

function barycenter(m, mTot, coo::Point3D) # Find Barycenter
    #    m : mass of planet
    # mTot : total mass of system
    #  coo : coordinates of planet
    #
    return (m * coo) / mTot
end

function momentum(body::Body)
    return m * cross(body.r, body.v)
end

@inline function acceleration(ra, rb, mb)
    d = distance(ra, rb)
    (G_year_AU * mb / d^3) * (rb - ra)
end

function update_acceleration!(a::AbstractVector{Point{D, T}}, bds::NewtonSystem) where {D, T}
    @assert length(a) == length(bds)
    @inbounds for j = 1:length(bds)
        a[j] = zero(Point{D, T})
        for k = 1:length(bds)
            j != k && (a[j] += acceleration(coordinate(bds, j), coordinate(bds, k), mass(bds, k)))
        end
    end
    return a
end

struct LeapFrogSystem{T, D, SYS<:AbstractHamiltonianSystem{D}}
    sys::SYS
    a::Vector{Point{D, T}}
    function LeapFrogSystem(bds::AbstractHamiltonianSystem, a::Vector{Point{D, T}}) where {T, D}
        @assert length(bds) == length(a)
        new{T, D, typeof(bds)}(bds, a)
    end
end
function LeapFrogSystem(bds::AbstractHamiltonianSystem)
    LeapFrogSystem(bds, zero(coordinate(bds)))
end

function step!(bdsc::LeapFrogSystem{T}, dt) where T
    sys, a = bdsc.sys, bdsc.a
    @inbounds for j = 1:length(sys)
        drj = dt / 2 * velocity(sys, j)
        offset_coordinate!(sys, j, drj)
    end
    update_acceleration!(a, sys)
    @inbounds for j = 1:length(sys)
        dvj = dt * a[j]
        offset_velocity!(sys, j, dvj)
        drj = dt / 2 * velocity(sys, j)
        offset_coordinate!(sys, j, drj)
    end
    return bdsc
end

function leapfrog_simulation(sys::AbstractHamiltonianSystem; dt, nsteps)
    cached_system = LeapFrogSystem(deepcopy(sys))
    states = [deepcopy(cached_system)]
    for i=1:nsteps
        cached_system = step!(cached_system, dt)
        push!(states, deepcopy(cached_system))
    end
    return states
end