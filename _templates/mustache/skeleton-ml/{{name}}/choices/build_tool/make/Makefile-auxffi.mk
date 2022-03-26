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


ML_CCLib := $(ML_CCLib) -cclib -rpath -cclib '$$ORIGIN/:$(ffi_libdir)' -cclib -L$(ffi_libdir) -cclib -lintro_c-practice -cclib -Lsrc/$(parent) # -cclib -l$(proj)_stubs
ML_CCOpt := $(ML_CCOpt) -ccopt -Wall -ccopt -pedantic -ccopt -fPIC -ccopt -std=c99 -ccopt -I$(ffi_incdir)
LDFLAGS := $(LDFLAGS) -L$(ffi_libdir)
LDLIBS := $(LDLIBS) -lintro_c-practice

ML_DllLib := $(ML_DllLib) # -custom -dllib -l$(proj)_stubs
ML_DllPath := $(ML_DllPath) -dllpath $(ffi_libdir)

src/$(parent)/classic_c_wrap.o : src/$(parent)/classic_c_wrap.c # src/swig/swig.cma src/swig/swig.cmxs
	-cd build ; $(MLC) $(ML_CFLAGS) $(ML_CCOpt) -c ../$< ; \
		mv classic_c_wrap.o src/$(parent)/
src/$(parent)/$(proj)_stubs : src/$(parent)/classic_c_wrap.o
	-cd build ; $(MLMKLIB) -v -Wl,-rpath,'\$$ORIGIN/' $(LDFLAGS) $(LDLIBS) -o $@ $^

.PHONY: auxffi
auxffi: src/$(parent)/$(proj)_stubs ## compile FFI auxiliary products

ML_LFLAGS := $(ML_LFLAGS) -I src/swig
ML_CFLAGS := $(ML_CFLAGS) -I src/swig

swig_mli = $(shell $(MLDEP) -sort src/swig/*.mli)
swig_ml = $(shell $(MLDEP) -sort src/swig/*.ml)

src/swig/swig.cma : $(swig_ml:.ml=.cmo)
	-cd build ; $(LINK.cmo) -a -o $@ $^
src/swig/swig.cmxa : $(swig_ml:.ml=.cmx)
	-cd build ; $(LINK.cmx) -a -o $@ $^
src/swig/swig.cmxs : src/swig/swig.cmxa
	-cd build ; $(LINK.cmx) -shared -o $@ $^
