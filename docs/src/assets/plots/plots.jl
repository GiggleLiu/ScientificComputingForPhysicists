using Luxor, LuxorGraphPlot, Random

function shrink(n1::Node, n2::Node, d)
    v = n2.loc .- n1.loc
    n = v ./ distance(n1, n2)
    return offset(n1, d .* n), offset(n2, -d .* n)
end

function LuxorGraphPlot.midpoint(n1::Node, n2::Node, ratio::Real)
    return dotnode(n1.loc .* (1-ratio) .+ n2.loc .* ratio)
end

function moveto(n1::Node, n2::Node, d::Real)
    return offset(n1, d .* (n2.loc .- n1.loc) ./ distance(n1, n2))
end

# lattice boltzmann model - lattice of particles with arrows
function fig1(; format=:svg, seed=2)
    filename = joinpath(@__DIR__, "generated", "fig1.$format")
    Random.seed!(seed)
    D = 100
    nodestore() do ns
        boxes = []
        particles = []
        for i=1:4, j=1:4
            push!(boxes, box!(ns, (i*D, j*D), D, D))
            for k = 1:9  # each box contains 9 particles
                x = i*D + (rand() - 0.5) * D
                y = j*D + (rand() - 0.5) * D
                push!(particles, circle!(ns, (x, y), 5))
            end
        end
        with_nodes(ns; filename) do
            stroke.(boxes)
            sethue("darkblue")
            for p in particles
                fill(p)
                finish = p.loc + (randn(), randn()) .* 20
                arrow(p.loc, finish)
                strokepath()
            end
        end
    end
end

# lattice vectors
function fig2(; format=:svg)
    filename = joinpath(@__DIR__, "generated", "fig2.$format")
    directions = [
        (1, 1), (-1, 1),
        (1, 0), (0, -1),
        (0, 0), (0, 1),
        (-1, 0), (1, -1),
        (-1, -1),
    ]
    nodestore() do ns
        D = 100
        PAD = 30
        N = 3
        rows = []
        cols = []
        for i=0:N
            top = dot!(ns, (-PAD, i*D))
            down = dot!(ns, (N*D+PAD, i*D))
            left = dot!(ns, (i*D, -PAD))
            right = dot!(ns, (i*D, N*D+PAD))
            push!(cols, [top, down])
            push!(rows, [left, right])
        end
        pins = Matrix{Any}(undef, N, N)
        for i=1:N, j=1:N
            x = (i-0.5)*D
            y = (j-0.5)*D
            pins[i, j] = dot!(ns, (x, y))
        end
        with_nodes(ns; filename) do
            for c in cols
                line(c[1], c[2])
            end
            for r in rows
                line(r[1], r[2])
            end
            center = (2, 2)
            @layer for i=1:N, j=1:N
                sethue("gray")
                circle(pins[i, j].loc, 5, :fill)
            end
            fontsize(20)
            for i=1:N, j=1:N
                ((i, j) == center) && continue
                idx = findfirst(==((i, j) .- center), directions)
                arrow(shrink(pins[center...], pins[i, j], 5)...; linewidth=2)
                mid = midpoint(pins[center...], pins[i, j], 0.65)
                @layer begin
                    sethue("white")
                    n = circlenode(mid, 13)
                    fill(n)
                end
                text("e"*string('₀' + idx), mid)
            end
        end
    end
end

function arrow_with_text(start, stop, str)
    arrow(start, stop; linewidth=2)
    t = moveto(stop, start, -15)
    @layer begin
        sethue("white")
        n = circlenode(t, 13)
        fill(n)
    end
    text(str, t)
end


# streaming
function fig3(; format=:svg, seed=2)
    Random.seed!(seed)
    filename = joinpath(@__DIR__, "generated", "fig3.$format")
    directions = [
        (1, 1), (-1, 1),
        (1, 0), (0, -1),
        (0, 0), (0, 1),
        (-1, 0), (1, -1),
        (-1, -1),
    ]
    densities = 0.3 .+ rand(9)
    densities ./= 3
    nodestore() do ns
        D = 100
        PAD = 30
        N = 3
        DX = 450
        rows = []
        cols = []
        for i=0:N
            top = dot!(ns, (-PAD, i*D))
            down = dot!(ns, (N*D+PAD, i*D))
            left = dot!(ns, (i*D, -PAD))
            right = dot!(ns, (i*D, N*D+PAD))
            push!(cols, [top, down])
            push!(rows, [left, right])
        end
        pins = Matrix{Any}(undef, N, N)
        for i=1:N, j=1:N
            x = (i-0.5)*D
            y = (j-0.5)*D
            pins[i, j] = dot!(ns, (x, y))
        end
        t1b = box!(ns, (D * N / 2, D * N + 2PAD), D, 20)
        append!(ns.nodes, offset.(ns.nodes, Ref((DX, 0))))
        with_nodes(ns; filename) do
            for c in cols
                line(c[1], c[2])
                line(offset(c[1], (DX, 0)), offset(c[2], (DX, 0)))
            end
            for r in rows
                line(r[1], r[2])
                line(offset(r[1], (DX, 0)), offset(r[2], (DX, 0)))
            end
            center = (2, 2)
            c = pins[center...]
            @layer for i=1:N, j=1:N
                sethue("gray")
                circle(pins[i, j].loc, 5, :fill)
                circle(offset(pins[i, j], (DX, 0)).loc, 5, :fill)
            end
            fontsize(20)
            #text("ρ₀", offset(c, (10, 0)))
            text("ρ₅", offset(c, (DX+15, 0)))
            for i=1:N, j=1:N
                ((i, j) == center) && continue
                idx = findfirst(==((i, j) .- center), directions)
                arrow_with_text(c, midpoint(c, pins[i, j], densities[idx]), "ρ"*string('₀' + idx))

                # shifted
                dxy = (DX, 0) .+ D .* directions[idx]
                arrow_with_text(offset(c, dxy), midpoint(offset(c, dxy), offset(pins[i, j], dxy), densities[idx]), "ρ"*string('₀' + idx))
            end
            text("t", t1b.loc)
            text("t+1", offset(t1b, (DX, 0)).loc)
        end
    end
end

function fig4(; format=:svg, seed=2)
    Random.seed!(seed)
    filename = joinpath(@__DIR__, "generated", "fig4.$format")
    densities = (0.3 .+ rand(9)) ./ 3
    directions = [
        (1, 1), (-1, 1),
        (1, 0), (0, -1),
        (0, 0), (0, 1),
        (-1, 0), (1, -1),
        (-1, -1),
    ]
    function equilibrium_density(ρ, u)
        weights = [1/36, 1/36, 1/9, 1/9, 4/9, 1/9, 1/9, 1/36, 1/36]
        return [ρ * weights[i] * _equilibrium_density(u, directions[i]) for i=1:9]
    end
    dot(x, y) = sum(x .* y)
    function _equilibrium_density(u, ei)
        # the equilibrium density of the fluid with a specific momentum
        return (1 + 3 * dot(ei, u) + 9/2 * dot(ei, u)^2 - 3/2 * dot(u, u))
    end
    r = sum(densities)
    u = mapreduce(i->densities[i] .* directions[i], (x, y) -> x .+ y, 1:9) ./ r
    densities2 = equilibrium_density(r, u)
    nodestore() do ns
        D = 100
        DX = 200
        b1 = box!(ns, (0, 0), D, D)
        b2 = box!(ns, (DX, 0), D, D)
        c1, c2 = center(b1), center(b2)
        t1b = box!(ns, (0, D/2 + 40), D, 20)
        with_nodes(ns; filename) do
            stroke(b1)
            stroke(b2)
            fontsize(20)
            for (k, d) in enumerate(directions)
                k == 5 && continue
                rho = densities[k]
                mid1 = midpoint(c1, offset(c1, D .* d), rho)
                arrow_with_text(c1, mid1, "ρ"*string('₀' + k))
                rho2 = densities2[k]
                mid2 = midpoint(c2, offset(c2, D .* d), rho2)
                arrow_with_text(c2, mid2, "ρ"*string('₀' + k))
            end
            text("initial", t1b)
            text("equilibrium", offset(t1b, (DX, 0)))
        end
    end
end
