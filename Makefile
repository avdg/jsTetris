# Put coffeescript files here from bottom to top

INPUT=
INPUT+= src/keyHandler.coffee
INPUT+= src/draw.coffee
INPUT+= src/state.coffee
INPUT+= src/achievements.coffee
INPUT+= src/cache.coffee
INPUT+= src/settings.coffee

.PHONY: all debug compile concat html tokens publish minify

all: compile
publish: compile minify html

debug:
	mkdir -p build/
	coffee -co build/ src/
	@coffee coffeescript-concat.coffee -i src/tetris.coffee -i \
		${INPUT} > build/output.coffee

compile:
	@echo "> Compiling - Use make debug if compilation fails"
	@coffee coffeescript-concat.coffee -i src/tetris.coffee -i \
		${INPUT} | coffee -sc > build/output.js

minify:
	@echo "> Minifying..."
	@uglifyjs build/output.js --stats --lint -m \
		-p 1 --source-map build/output.min.js.map --source-map-url output.min.js.map \
		-o build/output.min.js

html:
	@echo "> Writing html file"
	@cat src/output1.html build/output.min.js src/output2.html > build/output.html

concat:
	@echo "> Concatenating coffeescript files..."
	@coffee coffeescript-concat.coffee -i src/tetris.coffee -i \
		${INPUT} > build/output.coffee

tokens:
	@echo "> Use make debug if compilation fails"
	@coffee coffeescript-concat.coffee -i src/tetris.coffee -i \
		${INPUT} | coffee -st > build/tokens
