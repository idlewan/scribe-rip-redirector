all: build build/manifest.json build/assets \
	build/background.js

zip:
	(cd build && apack ../tabpocalypse.zip *)

build:
	mkdir -p $@

build/assets: assets
	cp -r -t build/ assets

source:
	mkdir scribe-rip-redirect_source
	(cd scribe-rip-redirect_source && git clone --depth=1 ../ ./)
	apack scribe-rip-redirect_source.zip scribe-rip-redirect_source/*
	rm -rfv scribe-rip-redirect_source/

build/manifest.json: manifest.yaml
	@$(call compile_yaml,$@,$<)

build/background.js: background.ts
	@$(call compile_ts,$@,$<)

dev_typescript:
	@tsc --pretty -w --preserveWatchOutput

workspace:
	@./node_modules/.bin/concurrently \
		'make --no-print-directory dev_typescript' \
		'make --no-print-directory watch' \
		-c 'red,green,yellow,blue,magenta,cyan,white,gray' \
		-n 'tsc,make'


compile_ts = echo "ts->js  " $1 && \
	esbuild $2 --bundle --outfile=$1

compile_yaml = echo "yaml->json" $1 && \
	yq . $2 > $1

watch:
	@echo `date +%T` "start watching directory for changes..."
	@inotifywait -q -r -m --exclude "build/.*" -e close_write ./  |\
		while read path events file; do \
			echo "    ---  $$file has been modified" ;\
			make --no-print-directory ; \
		done
