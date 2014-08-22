# FFI auxiliary makefile script
ffi_libdir = $(shell $(PKG_CONFIG) --variable=libdir intro_c-practice || echo .)
ffi_incdir = $(shell $(PKG_CONFIG) --variable=includedir intro_c-practice || echo .)
LD_LIBRARY_PATH := $(LD_LIBRARY_PATH):$(ffi_libdir)
export LD_LIBRARY_PATH

#MLMKLIB = ocamlfind ocamlmklib		# [ocamlfind] ocamlmklib
ML_CCLib := $(ML_CCLib) -lflags -cclib,-rpath,-cclib,'$$ORIGIN/:$(ffi_libdir)',-cclib,-L$(ffi_libdir),-cclib,-lintro_c-practice,-cclib,-Lsrc/$(parent) # -lflags -cclib,-l$(proj)_stubs
ML_CCOpt := $(ML_CCOpt) -cflags -ccopt,-Wall,-ccopt,-pedantic,-ccopt,-m64,-ccopt,-fPIC,-ccopt,-std=c99,-ccopt,-I$(ffi_incdir)
LDFLAGS := $(LDFLAGS) -L$(ffi_libdir)
LDLIBS := $(LDLIBS) -lintro_c-practice

ML_DllLib := $(ML_DllLib) # -lflags -custom,-dllib,-l$(proj)_stubs
ML_DllPath := $(ML_DllPath) -lflags -dllpath,$(ffi_libdir)

src/$(parent)/classic_c_wrap.o : src/$(parent)/classic_c_wrap.c # src/swig/swig.cma src/swig/swig.cmxa src/swig/swig.cmxs
	-$(MLBUILD) $(ML_CCLib) $(ML_CCOpt) $@
#_build/src/$(parent)/$(proj)_stubs : _build/src/$(parent)/classic_c_wrap.o
#	-$(MLMKLIB) -v -Wl,-rpath,'\$$ORIGIN/' $(LDFLAGS) $(LDLIBS) -o $@ $^
src/$(parent)/lib$(proj)_stubs.a : src/$(parent)/classic_c_wrap.o
	-$(MLBUILD) $(ML_LFLAGS) $(ML_CFLAGS) $(ML_CCOpt) -lflags "$^" -ocamlmklib "ocamlmklib -v $(LDFLAGS) $(LDLIBS)" $@

install_files := $(install_files) # _build/src/$(parent)/*$(proj)_stubs.* # _build/src/swig/*.cmi _build/src/swig/*.cmo _build/src/swig/*.cma
optional_files := $(optional_files) # _build/src/swig/*.cmi _build/src/swig/*.cmo _build/src/swig/*.cma

.PHONY: auxffi
auxffi: src/$(parent)/lib$(proj)_stubs.a ## compile FFI auxiliary products

ML_LFLAGS := $(ML_LFLAGS) -lflags -I,src/swig # -Is src/swig,_build/src/swig
ML_CFLAGS := $(ML_CFLAGS) # -Is src/swig,_build/src/swig

mllibs_tests := $(mllibs_tests) -libs swig

swig_mli = $(shell $(MLDEP) -sort src/swig/*.mli)
swig_ml = $(shell $(MLDEP) -sort src/swig/*.ml)

src/swig/swig.cma src/swig/swig.cmxa src/swig/swig.cmxs : 
	-$(MLBUILD) $(ML_LFLAGS) $(ML_CFLAGS) $@

.PHONY: prep_swig clean_swig
prep_swig src/$(parent)/classic_c_wrap.c: ## prepare Swig files
	-mkdir -p _build src/swig
#	-(cd _build ; swig -ocaml -co carray.i)
	-(cd src/swig ; swig -ocaml -co swig.mli ; swig -ocaml -co swig.ml)
	-swig -ocaml -I$(ffi_incdir) -outdir src/$(parent) -o src/$(parent)/classic_c_wrap.c src/$(parent)/classic_c.i
clean_swig: ## clean swig file(s)
	-rm -fr src/swig/swig.ml src/swig/swig.mli src/$(parent)/classic_c_wrap.c src/$(parent)/classic_c.ml*
