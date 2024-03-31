# Markov Chain Monte Carlo

In this chapter, we will introduce the concept of Markov Chain Monte Carlo (MCMC) methods. MCMC methods are a class of algorithms that are used to sample from a probability distribution. They are particularly useful when the distribution is high-dimensional and it is difficult to sample from it directly. MCMC methods are widely used in Bayesian statistics, machine learning, and other fields.

In physics, MCMC methods are often used to sample from the Boltzmann distribution of a system. This is useful for studying the equilibrium properties of the system, such as the energy, magnetization, and other thermodynamic quantities. In this chapter, we will focus on the Ferromagnetic Ising Model, which is a simple model of a magnetic system. We will use MCMC methods to sample from the Boltzmann distribution of the Ising model and study its properties.

## Ferromagnetic Ising Model
The Ferromagnetic Ising Model is a simple model of a magnetic system. It consists of a lattice of spins, which can be in one of two states: up or down. The energy of the system is given by the Hamiltonian:
```math
H = -J \sum_{\langle i, j \rangle} s_i s_j - h \sum_i s_i
```
where the first sum is over pairs of neighboring spins, $s_i$ and $s_j$, $J$ is the coupling constant, and $h$ is the external magnetic field. The spins interact with each other through the first term, which favors alignment of neighboring spins. The second term represents the interaction of the spins with the external magnetic field.

The probability distribution of the Ising model is given by the Boltzmann distribution:
```math
P(\{s\}) = \frac{1}{Z} e^{-\beta H(\{s\})}
```
where $\{s\}$ is the configuration of spins, $Z$ is the partition function, $\beta = 1/(k_B T)$ is the inverse temperature, and $H(\{s\})$ is the Hamiltonian of the system. The partition function is given by:
```math
Z = \sum_{\{s\}} e^{-\beta H(\{s\})}
```
where the sum is over all possible configurations of spins.

## Metropolis-Hastings Algorithm
The Metropolis-Hastings algorithm is a popular MCMC method that is used to sample from a probability distribution. It works by constructing a Markov chain that has the desired distribution as its stationary distribution. The algorithm proceeds as follows:
1. Start with an initial configuration of spins $\{s\}$.
2. Propose a new configuration $\{s'\}$ by flipping the spin of a randomly chosen site.
3. Calculate the change in energy $\Delta E = H(\{s'\}) - H(\{s\})$.
4. If $\Delta E < 0$, accept the new configuration $\{s'\}$ with probability 1.
5. If $\Delta E > 0$, accept the new configuration $\{s'\}$ with probability $e^{-\beta \Delta E}$.
6. Repeat steps 2-5 for a large number of iterations to sample from the distribution.

To study the equilibrium properties from the generated samples such as the energy, magnetization, and other thermodynamic quantities, we can use the generated samples to calculate the expectation value of the observable of interest. For example, the expectation value of an operator $A$ is given by:
```math
\langle A \rangle = \sum_{\{s\}} A(\{s\}) P(\{s\}) = \frac{1}{Z} \sum_{\{s\}} A(\{s\}) e^{-\beta H(\{s\})}
```
where $P(\{s\})$ is the probability distribution of the system. In practice, we can estimate the expectation value by averaging over the generated samples:
```math
\frac{1}{M} \sum_{i=1}^M A(s_i)
```
where $M$ is the number of samples and $\{s_i\}$ is the $i$-th sample. In this model, quantities of interest include
- Energy per site: $E = \frac{1}{N} \sum_{i=1}^N H_i$, where $N$ is the number of spins.
- Energy squared per site: $E^2 = \frac{1}{N} \sum_{i=1}^N H_i^2$.
- Magnetization per site: $M = \frac{1}{N} \sum_{i=1}^N s_i$.
- Magnetization squared per site: $M^2 = \frac{1}{N} \sum_{i=1}^N s_i^2$.
- Magnetization quartic per site: $M^4 = \frac{1}{N} \sum_{i=1}^N s_i^4$, which is used to study the Binder ratio.

## Ergodicity and Detailed Balance
The Metropolis-Hastings algorithm satisfies two important properties: ergodicity and detailed balance. Ergodicity means that the Markov chain can reach any state in the state space with a non-zero probability. Detailed balance means that the transition probabilities satisfy the condition:
```math
P(\{s\} \to \{s'\}) P(\{s'\}) = P(\{s'\} \to \{s\}) P(\{s\})
```
where $P(\{s\} \to \{s'\})$ is the probability of transitioning from state $\{s\}$ to state $\{s'\}$, and $P(\{s\})$ is the probability of being in state $\{s\}$. The Metropolis-Hastings algorithm satisfies detailed balance by construction, which ensures that the stationary distribution of the Markov chain is the desired distribution.

## Implementation
Our implementation of the Metropolis-Hastings algorithm for solving the Ising model is based on Anders Sandvik's lecture note[^Sandvik]. We use a 2D square lattice with periodic boundary conditions and initialize the lattice with random spins. We then run the Metropolis-Hastings algorithm for a large number of iterations to sample from the Boltzmann distribution. The source code is also available in the [demo repository](https://github.com/GiggleLiu/ScientificComputingDemos/tree/main/IsingModel). Both simple update and Swendsen-Wang's cluster update[^Swendsen1987] are implemented.

```@example ising
# required interfaces: num_spin, energy
abstract type AbstractSpinModel end

# IsingSpinModel: a struct that represents the Ising model
struct IsingSpinModel{RT} <: AbstractSpinModel
    l::Int  # lattice size
    h::RT   # magnetic field
    beta::RT  # inverse temperature 1/T
    pflp::NTuple{10, RT}  # precomputed flip probabilities
    neigh::Matrix{Int}  # neighbors
end
function IsingSpinModel(l::Int, h::RT, beta::RT) where RT
    pflp = ([exp(-2*s*(i + h) * beta) for s=-1:2:1, i in -4:2:4]...,)
    neigh = lattice(l)
    IsingSpinModel(l, h, beta, pflp, neigh)
end

# Constructs a list neigh[1:4,1:nn] of neighbors of each site
function lattice(ll)
    lis = LinearIndices((ll, ll))
    return reshape([lis[mod1(ci.I[1]+di, ll), mod1(ci.I[2]+dj, ll)] for (di, dj) in ((1, 0), (0, 1), (-1, 0), (0, -1)), ci in CartesianIndices((ll, ll))], 4, ll*ll)
end

# Returns the number of spins in the model
num_spin(model::IsingSpinModel) = model.l^2

# Computes the energy of the system
energy(model::IsingSpinModel, spin) = ferromagnetic_energy(model.neigh, model.h, spin)
function ferromagnetic_energy(neigh::AbstractMatrix, h::Real, spin::AbstractMatrix)
    @boundscheck size(neigh) == (4, length(spin))
    sum(1:length(spin)) do i
        s = spin[i]
        - s * (spin[neigh[1, i]] + spin[neigh[2, i]] + h)
    end
end

# Computes the probability of flipping a spin
@inline function pflip(model::IsingSpinModel, s::Integer, field::Integer)
    return @inbounds model.pflp[(field + 5) + (1 + s) >> 1]
end

# Updates the spin configuration using the Metropolis-Hastings algorithm
function mcstep!(model::IsingSpinModel, spin)
    nn = num_spin(model)
    @inbounds for _ = 1:nn
        s = rand(1:nn)
        field = spin[model.neigh[1, s]] + spin[model.neigh[2, s]] + spin[model.neigh[3, s]] + spin[model.neigh[4, s]]
        if rand() < pflip(model, spin[s], field)
           spin[s] = -spin[s]
        end
    end    
end

# Simulation result
struct SimulationResult{RT}
    nbins::Int  # number of bins
    nsteps_eachbin::Int  # number of steps in each bin
    current_bin::Base.RefValue{Int}  # current bin
    energy::Vector{RT}  # energy/spin
    energy2::Vector{RT}  # (energy/spin)^2
    m::Vector{RT}  # |m|
    m2::Vector{RT}  # m^2
    m4::Vector{RT}  # m^4
end
SimulationResult(nbins, nsteps_eachbin) = SimulationResult(nbins, nsteps_eachbin, Ref(0), zeros(nbins), zeros(nbins), zeros(nbins), zeros(nbins), zeros(nbins))

# Measures the energy and magnetization of the system
function measure!(result::SimulationResult, model::AbstractSpinModel, spin)
    @boundscheck checkbounds(result.energy, result.current_bin[])
    m = sum(spin)
    e = energy(model, spin)
    n = num_spin(model)
    k = result.current_bin[]
    @inbounds result.energy[k] += e/n
    @inbounds result.energy2[k] += (e/n)^2
    @inbounds result.m[k] += abs(m/n)
    @inbounds result.m2[k] += (m/n)^2
    @inbounds result.m4[k] += (m/n)^4
end

# Simulates the Ising model and measures the energy and magnetization of the system
function simulate!(model::IsingSpinModel, spin; nsteps_heatbath, nsteps_eachbin, nbins)
    # heat bath
    for _ = 1:nsteps_heatbath
        mcstep!(model, spin)    
    end
    result = SimulationResult(nbins, nsteps_eachbin)
    for j=1:nbins
        result.current_bin[] = j
        for _ = 1:nsteps_eachbin
            mcstep!(model, spin)
            measure!(result, model, spin)
        end
    end
    return result
end
```

The following code snippet demonstrates how to use the Ising model implementation to simulate the Ising model and measure the energy and magnetization of the system.

```@example ising
using CairoMakie
# an example for testing
lattice_size = 100
temperature = 2.0
magnetic_field = 0.0
model = IsingSpinModel(lattice_size, magnetic_field, 1/temperature)

# Constructs the initial random spin configuration
spin = rand([-1,1], model.l, model.l);

nsteps_heatbath = 1000
nsteps_eachbin = 100
nbins = 100
result = simulate!(model, spin; nsteps_heatbath, nsteps_eachbin, nbins)
```

The result contains the energy and magnetization of the system for each bin. We can use this data to calculate the mean energy and magnetization of the system and study its properties. The following code visualizes the energy and magnetization of the system over time.

```@example ising
fig = Figure()
ax = Axis(fig[1, 1], xlabel="time")

for (op, legend) in zip([:energy, :energy2, :m, :m2, :m4], [L"energy/spin", L"(energy/spin)^2", L"|m|", L"m^2", L"m^4"])
    lines!(ax, getfield(result, op), label=legend)
end
axislegend(ax)
fig
```

### Phase transition
#### Simple update, temperature = 1.0
We first set the temperature to 1.0, which is below the phase transition point $T_c = 2.269$. The video below shows the evolution of the spins over update steps. The spins tend to align with each other due to the ferromagnetic interaction, resulting in large clusters of aligned spins.

```julia
temperature = 1.0
model = IsingSpinModel(lattice_size, magnetic_field, 1/temperature)
# animation
fig = Figure()
spin = rand([-1,1], model.l, model.l)
spinobs = Observable(spin)
ax1 = Axis(fig[1, 1]; aspect = DataAspect()); hidedecorations!(ax1); hidespines!(ax1)  # hides ticks, grid and lables, and frame
Makie.heatmap!(ax1, spinobs, camera=campixel!)
txt = Observable("t = 0")
Makie.text!(ax1, -30, lattice_size-10; text=txt, color=:black, fontsize=30, strokecolor=:white)
filename = joinpath(@__DIR__, "ising-spins-$temperature.mp4")
record(fig, filename, 2:1000; framerate = 24) do i
    mcstep!(model, spin)
    spinobs[] = spin
    txt[] = "t = $(i-1)"
end
```

```@raw html
<video width="320" height="240" controls style="margin-bottom:30px">
  <source src="../../assets/images/ising-spins-1.0.mp4" type="video/mp4">
</video>
```

#### Simple update, temperature = 3.0
Next, we set the temperature to 3.0, which is above the phase transition point. The video below shows the evolution of the spins over update steps. The spins are disordered and do not align with each other, resulting in small clusters of aligned spins.

```@raw html
<video width="320" height="240" controls style="margin-bottom:30px">
  <source src="../../assets/images/ising-spins-3.0.mp4" type="video/mp4">
</video>
<br>
```

#### Cluster update, temperature = 1.0
The cluster update, or the Swendsen-Wang algorithm, is a more efficient way to update the spins in the Ising model. It works by grouping the spins into clusters of aligned spins and flipping the clusters with a certain probability.
The implementation of the cluster update could be found in the [demo repository](https://github.com/GiggleLiu/ScientificComputingDemos/tree/main/IsingModel).
The video below shows the evolution of the spins using the cluster update. The spins align with each other more quickly compared to the simple update.

```@raw html
<video width="320" height="240" controls style="margin-bottom:30px">
  <source src="../../assets/images/swising-spins-1.0.mp4" type="video/mp4">
</video>
<br>
```

#### Cluster update, temperature = 3.0
Similarly, we set the temperature to 3.0 and use the cluster update. The video below shows the evolution of the spins over update steps. The spins are disordered and do not align with each other, resulting in small clusters of aligned spins.

```@raw html
<video width="320" height="240" controls>
  <source src="../../assets/images/swising-spins-3.0.mp4" type="video/mp4">
</video>
```

## References

[^Sandvik]: Lecture note: Monte Carlo simulations in classical statistical physics, Anders Sandvik ([PDF](https://physics.bu.edu/~py502/lectures5/mc.pdf))
[^Swendsen1987]: Swendsen, Robert H., and Jian-Sheng Wang. "Nonuniversal critical dynamics in Monte Carlo simulations." Physical review letters 58.2 (1987): 86.