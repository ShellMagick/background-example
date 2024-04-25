$(VERBOSE).SILENT:

.PHONY: generate
generate:
	@echo "Generate patterns"
	$(MAKE) --no-print-directory patterns
	@echo "Create bases"
	$(MAKE) --no-print-directory bases
	@echo "Create composites"
	$(MAKE) --no-print-directory composites
	@echo "Create masks"
	$(MAKE) --no-print-directory masks
	@echo "Mask patterns"
	$(MAKE) --no-print-directory masking
	@echo "Make masked patterns transparent"
	$(MAKE) --no-print-directory transparent-mask
	@echo "Create meta-masks"
	$(MAKE) --no-print-directory metamask
	@echo "Meta-mask bases"
	$(MAKE) --no-print-directory metamasking
	@echo "Varnish meta-masked images"
	$(MAKE) --no-print-directory varnish
	@echo "Finalize images"
	$(MAKE) --no-print-directory finalize

.PHONY: patterns
patterns: ./tmp/pattern.png ./tmp/pattern-black.png ./tmp/pattern-white.png
./tmp/pattern.png:
	echo "[⏳] Generating base pattern"
	mkdir -p ./tmp
	magick -size 960x540 \
		pattern:horizontal \
		-alpha set \
		-virtual-pixel tile \
		-resize 3840x2160\! \
		$$(cygpath -w ./tmp/pattern.png)
	echo -e "\e[1A\e[K[✅] Generated base pattern"
./tmp/pattern-black.png:
	echo "[⏳] Generating black pattern"
	magick $$(cygpath -w ./tmp/pattern.png) \
		-transparent white \
		$$(cygpath -w ./tmp/pattern-black.png)
	echo -e "\e[1A\e[K[✅] Generated black pattern"
./tmp/pattern-white.png:
	echo "[⏳] Generating white pattern"
	magick $$(cygpath -w ./tmp/pattern-black.png) \
		-negate \
		$$(cygpath -w ./tmp/pattern-white.png)
	echo -e "\e[1A\e[K[✅] Generated white pattern"


.PHONY: bases
bases: $(patsubst ./src/%.svg,./tmp/00-base/%.png,$(wildcard ./src/*.svg))
./tmp/00-base/%.png: ./src/%.svg
	echo "[⏳] Generating huge base $*"
	mkdir -p ./tmp/00-base
	inkscape $$(cygpath -w $<) \
		-w 3840 -h 2160 \
		-o $$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Generated huge base $*"


.PHONY: composites composites.dark composites.light
composites: composites.dark composites.light
composites.dark: $(patsubst ./icons/256x256/%-dark.png,./tmp/01-composite/%-dark.png,$(wildcard ./icons/256x256/*-dark.png))
composites.light: $(patsubst ./icons/256x256/%-light.png,./tmp/01-composite/%-light.png,$(wildcard ./icons/256x256/*-light.png))
./tmp/01-composite/%-dark.png: ./icons/256x256/%-dark.png
	echo "[⏳] Composing $*-dark"
	mkdir -p ./tmp/01-composite
	magick composite \
		-gravity NorthEast \
		-geometry +146+146 \
		$$(cygpath -w $<) $$(cygpath -w $$(ls ./tmp/00-base/*-dark.png)) \
		-size 3840x2160 \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Composed $*-dark"
./tmp/01-composite/%-light.png: ./icons/256x256/%-light.png
	echo "[⏳] Composing $*-light"
	mkdir -p ./tmp/01-composite
	magick composite \
		-gravity NorthEast \
		-geometry +146+146 \
		$$(cygpath -w $<) $$(cygpath -w $$(ls ./tmp/00-base/*-light.png)) \
		-size 3840x2160 \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Composed $*-light"


.PHONY: masks ./tmp/02mask/%-mask.png
masks: $(patsubst ./tmp/01-composite/%-dark.png,./tmp/02-mask/%.png,$(wildcard ./tmp/01-composite/*-dark.png))
./tmp/02-mask/%.png: ./tmp/01-composite/%-dark.png
	echo "[⏳] Creating mask $*"
	mkdir -p ./tmp/02-mask
	magick $$(cygpath -w $<) \
		-alpha extract \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Created mask $*"


.PHONY: masking masking.dark masking.light
masking: masking.dark masking.light
masking.dark: $(patsubst ./tmp/02-mask/%.png,./tmp/03-masked-pattern/%-dark.png,$(wildcard ./tmp/02-mask/*.png))
masking.light: $(patsubst ./tmp/02-mask/%.png,./tmp/03-masked-pattern/%-light.png,$(wildcard ./tmp/02-mask/*.png))
./tmp/03-masked-pattern/%-dark.png: ./tmp/02-mask/%.png
	echo "[⏳] Masking $*-dark"
	mkdir -p ./tmp/03-masked-pattern
	magick $$(cygpath -w ./tmp/pattern-white.png) $$(cygpath -w $<) \
		-alpha off \
		-compose CopyOpacity \
		-composite \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Masked $*-dark"
./tmp/03-masked-pattern/%-light.png: ./tmp/02-mask/%.png
	echo "[⏳] Masking $*-light"
	mkdir -p ./tmp/03-masked-pattern
	magick $$(cygpath -w ./tmp/pattern-black.png) $$(cygpath -w $<) \
		-alpha off \
		-compose CopyOpacity \
		-composite \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Masked $*-light"


.PHONY: transparent-mask
transparent-mask: $(patsubst ./tmp/03-masked-pattern/%-dark.png,./tmp/04-transparent-mask/%.png,$(wildcard ./tmp/03-masked-pattern/*-dark.png))
./tmp/04-transparent-mask/%.png: ./tmp/03-masked-pattern/%-dark.png
	echo "[⏳] Re-composing mask $*"
	mkdir -p ./tmp/04-transparent-mask
	magick $$(cygpath -w $<) \
		-transparent black \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Re-composed mask $*"


.PHONY: metamask
metamask: $(patsubst ./tmp/04-transparent-mask/%.png,./tmp/05-metamask/%.png,$(wildcard ./tmp/04-transparent-mask/*.png))
./tmp/05-metamask/%.png: ./tmp/04-transparent-mask/%.png
	echo "[⏳] Creating meta-mask $*"
	mkdir -p ./tmp/05-metamask
	magick $$(cygpath -w $<) \
		-alpha extract \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Created meta-mask $*"


.PHONY: metamasking
metamasking: metamasking.dark metamasking.light
metamasking.dark: $(patsubst ./tmp/05-metamask/%.png,./tmp/06-metamasked/%-dark.png,$(wildcard ./tmp/05-metamask/*.png))
metamasking.light: $(patsubst ./tmp/05-metamask/%.png,./tmp/06-metamasked/%-light.png,$(wildcard ./tmp/05-metamask/*.png))
./tmp/06-metamasked/%-dark.png: ./tmp/05-metamask/%.png
	echo "[⏳] Meta-masking $*-dark"
	mkdir -p ./tmp/06-metamasked
	magick $$(cygpath -w $$(ls ./tmp/01-composite/$*-dark.png)) $$(cygpath -w $<) \
		-compose CopyOpacity \
		-composite \
		-resize 1920x1080 \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Meta-masked $*-dark"
./tmp/06-metamasked/%-light.png: ./tmp/05-metamask/%.png
	echo "[⏳] Meta-masking $*-light"
	mkdir -p ./tmp/06-metamasked
	magick $$(cygpath -w $$(ls ./tmp/01-composite/$*-light.png)) $$(cygpath -w $<) \
		-compose CopyOpacity \
		-composite \
		-resize 1920x1080 \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Meta-masked $*-light"


.PHONY: varnish
varnish: varnish.dark varnish.light
varnish.dark: $(patsubst ./tmp/06-metamasked/%.png,./tmp/07-varnished/%.png,$(wildcard ./tmp/06-metamasked/*-dark.png))
varnish.light: $(patsubst ./tmp/06-metamasked/%.png,./tmp/07-varnished/%.png,$(wildcard ./tmp/06-metamasked/*-light.png))
./tmp/07-varnished/%-dark.png: ./tmp/06-metamasked/%-dark.png
	echo "[⏳] Varnishing $*-dark"
	mkdir -p ./tmp/07-varnished
	magick $$(cygpath -w $<) \
		\( +clone -background snow2 -shadow 73x17+0+0 -channel A -level 0,50% +channel \) +swap \
		+repage -gravity center -composite \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Varnished $*-dark"
./tmp/07-varnished/%-light.png: ./tmp/06-metamasked/%-light.png
	echo "[⏳] Varnishing $*-light"
	mkdir -p ./tmp/07-varnished
	magick $$(cygpath -w $<) \
		\( +clone -background crimson -shadow 73x17+0+0 -channel A -level 0,50% +channel \) +swap \
		+repage -gravity center -composite \
		$$(cygpath -w $@)
	echo -e "\e[1A\e[K[✅] Varnished $*-light"


.PHONY: finalize
finalize: finalize.dark finalize.light
finalize.dark: $(patsubst ./tmp/07-varnished/%-dark.png,./dst/%-light.png,$(wildcard ./tmp/07-varnished/*-dark.png))
finalize.light: $(patsubst ./tmp/07-varnished/%-light.png,./dst/%-dark.png,$(wildcard ./tmp/07-varnished/*-light.png))
./dst/%-light.png: ./tmp/07-varnished/%-dark.png
	cp $< $@
./dst/%-dark.png: ./tmp/07-varnished/%-light.png
	cp $< $@
