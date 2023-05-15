changequote(`[[[', `]]]')

# NOTE: This file is generated by m4! Make sure you're editing the .m4 version,
# not the generated version!

LIBAVJS_VERSION=3.11.5.1.2
EMCC=emcc
MINIFIER=node_modules/.bin/uglifyjs -m
CFLAGS=-Oz
EFLAGS=\
	--memory-init-file 0 --post-js build/post.js --extern-post-js extern-post.js \
	-s "EXPORT_NAME='LibAVFactory'" \
	-s "EXPORTED_FUNCTIONS=@build/exports.json" \
	-s "EXPORTED_RUNTIME_METHODS=['cwrap']" \
	-s MODULARIZE=1 \
	-s ASYNCIFY \
	-s "ASYNCIFY_IMPORTS=['libavjs_wait_reader']" \
	-s ALLOW_MEMORY_GROWTH=1

all: build-default

include mk/*.mk


build-%: dist/libav-$(LIBAVJS_VERSION)-%.js
	true

dist/libav-$(LIBAVJS_VERSION)-%.js: build/libav-$(LIBAVJS_VERSION).js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.js \
	dist/libav-$(LIBAVJS_VERSION)-%.asm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.asm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.wasm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.simd.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.simd.js \
	node_modules/.bin/uglifyjs
	mkdir -p dist
	sed "s/@CONFIG/$*/g ; s/@DBG//g" < $< | $(MINIFIER) > $@
	-chmod a-x dist/*.wasm

dist/libav-$(LIBAVJS_VERSION)-%.dbg.js: build/libav-$(LIBAVJS_VERSION).js
	mkdir -p dist
	sed "s/@CONFIG/$*/g ; s/@DBG/.dbg/g" < $< > $@

# General build rule for any target
# Use: buildrule(target file name, target inst name, CFLAGS, 
define([[[buildrule]]], [[[
dist/libav-$(LIBAVJS_VERSION)-%.$1: build/ffmpeg-$(FFMPEG_VERSION)/build-$2-%/libavformat/libavformat.a \
	build/exports.json build/post.js extern-post.js bindings.c
	mkdir -p dist
	$(EMCC) $(CFLAGS) $(EFLAGS) $3 \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*) \
		`test ! -e configs/$(*)/link-flags.txt || cat configs/$(*)/link-flags.txt` \
		bindings.c \
                `grep LIBAVJS_WITH_CLI configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/fftools/ffmpeg.o \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/fftools/ffmpeg_filter.o \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/fftools/ffmpeg_hw.o \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/fftools/ffmpeg_mux.o \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/fftools/ffmpeg_opt.o \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/fftools/ffprobe.o \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/fftools/cmdutils.o \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/fftools/opt_common.o \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/libavdevice/libavdevice.a \
		'` \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/libavformat/libavformat.a \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/libavfilter/libavfilter.a \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/libavcodec/libavcodec.a \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/libswresample/libswresample.a \
		build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/libavutil/libavutil.a \
		`grep LIBAVJS_WITH_SWSCALE configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo 'build/ffmpeg-$(FFMPEG_VERSION)/build-$2-$(*)/libswscale/libswscale.a'` \
		`test ! -e configs/$(*)/libs.txt || sed 's/@TARGET/$2/' configs/$(*)/libs.txt` -o $(@)
	cat configs/$(*)/license.js $(@) > $(@).tmp
	mv $(@).tmp $(@)
]]])

# asm.js version
buildrule(asm.js, base, [[[-s WASM=0]]])
buildrule(dbg.asm.js, base, [[[-g2 -s WASM=0]]])
# wasm version with no added features
buildrule(wasm.js, base, [[[]]])
buildrule(dbg.wasm.js, base, [[[-g2]]])
# wasm + threads
buildrule(thr.js, thr, [[[-pthread -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency]]])
buildrule(dbg.thr.js, thr, [[[-g2 -pthread -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency]]])
# wasm + simd
buildrule(simd.js, simd, [[[-msimd128]]])
buildrule(dbg.simd.js, simd, [[[-g2 -msimd128]]])
# wasm + threads + simd
buildrule(thrsimd.js, thrsimd, [[[-pthread -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency -msimd128]]])
buildrule(dbg.thrsimd.js, thrsimd, [[[-g2 -pthread -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency -msimd128]]])

build/exports.json: libav.in.js post.in.js funcs.json apply-funcs.js
	mkdir -p build dist
	./apply-funcs.js $(LIBAVJS_VERSION)

build/libav-$(LIBAVJS_VERSION).js build/post.js: build/exports.json
	touch $@

node_modules/.bin/uglifyjs:
	npm install

# Targets
build/inst/base/cflags.txt:
	mkdir -p build/inst/base
	touch $@

build/inst/thr/cflags.txt:
	mkdir -p build/inst/thr
	echo '-pthread' > $@

build/inst/simd/cflags.txt:
	mkdir -p build/inst/simd
	echo '-msimd128' > $@

build/inst/thrsimd/cflags.txt:
	mkdir -p build/inst/thrsimd
	echo '-pthread -msimd128' > $@

release: build-default build-lite build-fat build-obsolete build-opus build-flac \
        build-opus-flac build-webm build-webm-opus-flac \
	build-mediarecorder-transcoder build-open-media
	mkdir libav.js-$(LIBAVJS_VERSION)
	cp -a dist/ libav.js-$(LIBAVJS_VERSION)/
	mkdir libav.js-$(LIBAVJS_VERSION)/sources
	for t in ffmpeg lame libaom libogg libvorbis libvpx opus; \
	do \
		$(MAKE) $$t-release; \
	done
	git archive HEAD -o libav.js-$(LIBAVJS_VERSION)/sources/libav.js.tar
	xz libav.js-$(LIBAVJS_VERSION)/sources/libav.js.tar
	zip -r libav.js-$(LIBAVJS_VERSION).zip libav.js-$(LIBAVJS_VERSION)
	rm -rf libav.js-$(LIBAVJS_VERSION)

publish:
	unzip libav.js-$(LIBAVJS_VERSION).zip
	( cd libav.js-$(LIBAVJS_VERSION) && \
	  cp -a ../package.json ../README.md ../docs . && \
	  npm publish )
	rm -rf libav.js-$(LIBAVJS_VERSION)

halfclean:
	-rm -rf dist/
	-rm -f build/exports.json build/libav-$(LIBAVJS_VERSION).js build/post.js

clean: halfclean
	-rm -rf build/inst
	-rm -rf build/opus-$(OPUS_VERSION)
	-rm -rf build/libaom-$(LIBAOM_VERSION)
	-rm -rf build/libvorbis-$(LIBVORBIS_VERSION)
	-rm -rf build/libogg-$(LIBOGG_VERSION)
	-rm -rf build/libvpx-$(LIBVPX_VERSION)
	-rm -rf build/lame-$(LAME_VERSION)
	-rm -rf build/openh264-$(OPENH264_VERSION)
	-rm -rf build/ffmpeg-$(FFMPEG_VERSION)
	-rm -rf build/x265_$(X265_VERSION)

distclean: clean
	-rm -rf build/

.PRECIOUS: \
	build/ffmpeg-$(FFMPEG_VERSION)/build-%/libavformat/libavformat.a \
	dist/libav-$(LIBAVJS_VERSION)-%.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.js \
	dist/libav-$(LIBAVJS_VERSION)-%.asm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.asm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.wasm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.thr.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.thr.js \
	dist/libav-$(LIBAVJS_VERSION)-%.simd.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.simd.js \
	dist/libav-$(LIBAVJS_VERSION)-%.thrsimd.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.thrsimd.js
