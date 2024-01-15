JL = julia

build:
	$(JL) -e 'using BookTemplate; BookTemplate.build()'
