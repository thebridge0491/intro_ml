# FFI auxiliary makefile script

ffi_libdir = $(shell $(PKG_CONFIG) --variable=libdir intro_c-practice || echo .)
ffi_incdir = $(shell $(PKG_CONFIG) --variable=includedir intro_c-practice || echo .)
LD_LIBRARY_PATH := $(LD_LIBRARY_PATH):$(ffi_libdir)
export LD_LIBRARY_PATH

install_files := $(install_files) # _build/src/$(parent)/*$(proj)_stubs.* # _build/src/swig/*.cmi _build/src/swig/*.cmo _build/src/swig/*.cma
optional_files := $(optional_files) # _build/src/swig/*.cmi _build/src/swig/*.cmo _build/src/swig/*.cma

.PHONY: prep_swig clean_swig
prep_swig src/$(parent)/classic_c_wrap.c: ## prepare Swig files
	-mkdir -p _build src/swig
	-(cd _build ; swig -ocaml -co carray.i)
	-(cd src/swig ; swig -ocaml -co swig.mli ; swig -ocaml -co swig.ml)
	-swig -ocaml -I$(ffi_incdir) -outdir src/$(parent) -o src/$(parent)/classic_c_wrap.c src/$(parent)/classic_c.i
clean_swig:  ## clean swig file(s)
	-rm -fr src/swig/swig.ml src/swig/swig.mli src/$(parent)/classic_c_wrap.c src/$(parent)/classic_c.ml*
