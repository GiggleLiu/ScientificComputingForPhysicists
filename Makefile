JL = julia

default: init build serve

init:
	$(JL) -e 'using Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'

build:
	$(JL) -e 'using BookTemplate; BookTemplate.build()'

serve:
	$(JL) -e 'using Books; serve()'

clean:
	rm -rf _build
	rm -rf _gen

.PHONY: init build serve
