BIN_DIR := ./bin

WATMODULES := $(shell find ./wat -name '*.wat')
# for each .wat file, build path of the resulting .wasm
WASMS := $(WATMODULES:.wat=.wasm)

DAY_INPUTS := $(shell find ./inputs -type f)
# for each input define the answer path
DAY_ANSWERS := ${subst ./inputs,./answers,$(DAY_INPUTS)}

all: $(DAY_ANSWERS)

answers:
	mkdir -p answers

answers/%: wat/%.wasm inputs/% | answers
	node runwat.js $? $@:

%.wasm: %.wat
	wat2wasm $< -o $@

clean: FORCE
	rm -f $(WASMS)
	rm -f answers/*

FORCE: ;