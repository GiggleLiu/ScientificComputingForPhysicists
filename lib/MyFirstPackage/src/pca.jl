module Bodies
    import LinearAlgebra
    using NBodyLeapFrog: V3

    const mass_solar = 1.988544e30 # in kg
    const mass_mercury = 3.302e23
    const mass_venus = 48.685e23
    const mass_earth = 5.97219e24
    const mass_mars = 6.4185e23
    const mass_jupyter = 1898.13e24
    const mass_saturn = 5.68319e26
    const mass_neptune = 102.41e24
    const mass_uranus = 86.8103e24
    const mass_pluto= 1.307e22

    const mass_planetX = 3.2e24 # Planet refers to an additional planet I can add to the solar
    # system to test if it is maximally packed. (The solar system is not
    # maximally packed. There is room to add another planet and preserve the 
    # stable orbit of all planets.)

    #  unit of time -> year, unit of space -> AU
    const year = 3.154e7 #year in seconds
    const AU = 1.496e11 #in m

    const G_standard = 6.67259e-11 # in m^3/(kg-s^2)
    const G_year_AU = G_standard*(1/AU)^3/(1/mass_solar*(1/year)^2)

    struct Body{T}
        r::V3{T}
        v::V3{T}
        m::T
    end
    
    const mercury = Body(
        V3(8.887985138765460E-02, -4.426150338141062E-01, -4.475716356484761E-02),
        # velocity in AU/day
        V3(2.190877912081542E-02, 7.161568136528000E-03, -1.425929443086507E-03),
        mass_mercury / mass_solar
    )

    const venus = Body(
        V3(4.043738093622098E-02, -7.239789211502183E-01, -1.241560658530024E-02),
        V3(2.005742309538389E-02, 1.141448268256643E-03, -1.142174441569258E-03),
        mass_venus/mass_solar
    )
    
    const earth =  Body(
        V3(-2.020844529756663E-02, -1.014332737790859E+00, -1.358267619371298E-05),
        V3(1.692836723212859E-02, -3.484006532982474E-04, 6.028542314557626E-07),
        mass_earth/mass_solar
    )

    # target 1998
    #  -3.466334931755365E-02 -1.013773181327570E+00  2.111689861662178E-04
    #   1.692129864984556E-02 -5.252811129268817E-04  3.987686870581435E-07


    const mars = Body(
        V3(7.462481663749645E-01, -1.181663652521456E+00, -4.321921404013512E-02),
        V3(1.235610918162121E-02, 8.680869489377649E-03 , -1.220500608452554E-04),
        mass_mars/mass_solar
    )

    const planetX = Body(
        V3(0.0, 2.06, 0.0),
        V3(1.235610918162121E-02, 0.0, 0.0),
        mass_planetX / mass_solar
    )

    const jupyter = Body(
        V3(3.384805319103406E+00, 3.658805636759595E+00, -9.100441946210819E-02),
        V3(-5.634671617093230E-03, 5.479180979634376E-03, 1.034981407898108E-04),
        mass_jupyter/mass_solar
    )

    const saturn = Body(
        V3(-1.083899692644216E-01, -1.003995196286016E+01, 1.793391553155583E-01),
        V3(5.278410787728323E-03, -7.712342079566598E-05, -2.084447335785041E-04),
        mass_saturn / mass_solar
    )

    const neptune = Body(
        V3(4.675566709791660E+00, -2.985428200863175E+01, 5.070034142531887E-01),
        V3(3.080716380724798E-03, 5.030733458293977E-04, -8.101711269674541E-05),
        mass_neptune / mass_solar
    )

    const uranus = Body(
        V3(-2.693448460292631E-01, -1.927606446869220E+01, -6.808868692550485E-02),
        V3(3.903100242621723E-03, -2.380111092360100E-04, -5.164025224695875E-05),
        mass_uranus / mass_solar
    )

    const pluto = Body(
        V3(-2.129074273328636E+01, -1.896633337434039E+01, 8.187955378677129E+00),
        V3(2.276295756013608E-03, -2.670481848836963E-03, -3.669545371032554E-04),
        mass_pluto / mass_solar
    )


    # target  -1.156541154581570E+01 -2.704864218000164E+01  6.239749761161465E+00
    #   2.964408290188142E-03 -1.722224413824548E-03 -6.839434010481107E-04

    const sun = Body(
        V3(-3.430031536367300E-03, 1.761881027012596E-03, 1.246691303879918E-05),
        V3(3.433119412673547E-06, -5.231300927361546E-06, -2.972974735550750E-08),
        1.0
    )

    # Arrays for modeling the solar system
    const set = [sun, mercury, venus, earth, mars, jupyter, saturn, uranus, neptune, pluto]
    const set_packed = [sun, mercury, venus, earth, mars, planetX, jupyter, saturn, uranus, neptune, pluto]

    const dayToYear = 365.25

    function chunit_day2year(body::Body)
        Body(body.r, body.v * dayToYear, body.m)
    end
end