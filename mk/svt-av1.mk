

# NOTE: This file is generated by m4! Make sure you're editing the .m4 version,
# not the generated version!

SVT_AV1_VERSION=2.1.2

build/inst/%/lib/pkgconfig/SvtAv1Enc.pc: build/SVT-AV1-v$(SVT_AV1_VERSION)/build-%/Makefile
	cd build/SVT-AV1-v$(SVT_AV1_VERSION)/build-$* && \
		$(MAKE) install
	touch $@

# General build rule for any target
# Use: buildrule(target name, cmake flags)


# Non-threaded

build/SVT-AV1-v$(SVT_AV1_VERSION)/build-base/Makefile: build/SVT-AV1-v$(SVT_AV1_VERSION)/PATCHED | build/inst/base/cflags.txt
	mkdir -p build/SVT-AV1-v$(SVT_AV1_VERSION)/build-base
	cd build/SVT-AV1-v$(SVT_AV1_VERSION)/build-base && \
		emcmake cmake ../../SVT-AV1-v$(SVT_AV1_VERSION) \
		-DCMAKE_INSTALL_PREFIX="$(PWD)/build/inst/base" \
		-DCMAKE_C_FLAGS="-Oz `cat $(PWD)/build/inst/base/cflags.txt`" \
		-DCMAKE_CXX_FLAGS="-Oz `cat $(PWD)/build/inst/base/cflags.txt`" \
		-DCMAKE_BUILD_TYPE=Release \
                
	touch $(@)

# Threaded

build/SVT-AV1-v$(SVT_AV1_VERSION)/build-thr/Makefile: build/SVT-AV1-v$(SVT_AV1_VERSION)/PATCHED | build/inst/thr/cflags.txt
	mkdir -p build/SVT-AV1-v$(SVT_AV1_VERSION)/build-thr
	cd build/SVT-AV1-v$(SVT_AV1_VERSION)/build-thr && \
		emcmake cmake ../../SVT-AV1-v$(SVT_AV1_VERSION) \
		-DCMAKE_INSTALL_PREFIX="$(PWD)/build/inst/thr" \
		-DCMAKE_C_FLAGS="-Oz `cat $(PWD)/build/inst/thr/cflags.txt`" \
		-DCMAKE_CXX_FLAGS="-Oz `cat $(PWD)/build/inst/thr/cflags.txt`" \
		-DCMAKE_BUILD_TYPE=Release \
                
	touch $(@)


#extract: build/SVT-AV1-v$(SVT_AV1_VERSION)/PATCHED

build/SVT-AV1-v$(SVT_AV1_VERSION)/PATCHED: build/SVT-AV1-v$(SVT_AV1_VERSION)/CMakeLists.txt
	cd build/SVT-AV1-v$(SVT_AV1_VERSION) && ( test -e PATCHED || patch -p1 -i ../../patches/svt-av1.diff )
	touch $@

build/SVT-AV1-v$(SVT_AV1_VERSION)/CMakeLists.txt: build/SVT-AV1-v$(SVT_AV1_VERSION).tar.bz2
	cd build && tar jxf SVT-AV1-v$(SVT_AV1_VERSION).tar.bz2
	touch $@

build/SVT-AV1-v$(SVT_AV1_VERSION).tar.bz2:
	mkdir -p build
	curl https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/v1.8.0/SVT-AV1-v$(SVT_AV1_VERSION).tar.bz2 -L -o $@

SVT-AV1-release:
	cp build/SVT-AV1-v$(SVT_AV1_VERSION).tar.bz2 dist/release/libav.js-$(LIBAVJS_VERSION)/sources/

.PRECIOUS: \
	build/inst/%/lib/pkgconfig/svt-av1.pc \
	build/SVT-AV1-v$(SVT_AV1_VERSION)/build-%/Makefile \
	build/SVT-AV1-v$(SVT_AV1_VERSION)/PATCHED \
	build/SVT-AV1-v$(SVT_AV1_VERSION)/CMakeLists.txt
