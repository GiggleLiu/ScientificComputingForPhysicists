JL = julia --project=docs

default: init build serve

init:
	$(JL) -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

update:
	$(JL) -e 'using Pkg; Pkg.update(); Pkg.precompile()'

serve:
	$(JL) -e 'using LiveServer; servedocs()'

clean:
	rm -rf docs/build

.PHONY: init build serve
