JL = julia --project

init:
	$(JL) -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

update:
	$(JL) -e 'using Pkg; Pkg.update(); Pkg.precompile()'

fig%:
	$(JL) -e 'include("plots.jl"); fig$*()'

.PHONY: init update fig%
