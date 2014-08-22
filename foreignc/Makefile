# OASIS_START
# DO NOT EDIT (digest: bc04e47b332ac491b8ae5d576c98342b)

SETUP = ocaml setup.ml

build: setup.data
	$(SETUP) -build $(BUILDFLAGS)

doc: setup.data build
	$(SETUP) -doc $(DOCFLAGS)

test: setup.data build
	$(SETUP) -test $(TESTFLAGS)

all:
	$(SETUP) -all $(ALLFLAGS)

clean:
	$(SETUP) -clean $(CLEANFLAGS)

distclean:
	$(SETUP) -distclean $(DISTCLEANFLAGS)

setup.data:
	$(SETUP) -configure $(CONFIGUREFLAGS)

configure:
	$(SETUP) -configure $(CONFIGUREFLAGS)

.PHONY: build doc test all clean distclean configure

# OASIS_STOP

prefix = $(shell $(SETUP) -configure | sed -n 's|Install architecture-independent files dir: [.]* \(.*\)|\1|p')

PKG_CONFIG = pkg-config --with-path=$(prefix)/lib/pkgconfig

parent = intro_ml
pkg = foreignc
proj = $(parent)-$(pkg)
version = $(shell $(SETUP) -configure | sed -n 's|Package version: [.]* \(.*\)|\1|p')

help: 
	@echo "##### subproject: $(proj) #####"
	@echo "Usage: $(MAKE) [target] -- some valid targets:"
	-@for fileX in $(MAKEFILE_LIST) `if [ -z "$(MAKEFILE_LIST)" ] ; then echo Makefile ; fi` ; do \
		grep -ve '^[A-Z]' $$fileX | awk '/^[^.%][-A-Za-z0-9_]+[ ]*:.*$$/ { print "...", substr($$1, 1, length($$1)) }' | sort ; \
	done
#	-@for fileX in $(MAKEFILE_LIST) `if [ -z "$(MAKEFILE_LIST)" ] ; then echo Makefile ; fi` ; do \
#		grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $$fileX | \
#		awk 'BEGIN {FS = ":.*?## "}; {printf "%-25s%s\n", $$1, $$2}' ; \
#	done

FMTS ?= tar.gz
distdir = $(proj).$(version)

install_files := $(install_files) src/$(parent)/META _build/src/$(parent)/*.cmi _build/src/$(parent)/*.cmo _build/src/$(parent)/*.cma
optional_files := $(optional_files) _build/src/$(parent)/*.cmx _build/src/$(parent)/*.cmxa _build/src/$(parent)/*.cmxs

uninstall install: 
	-mkdir -p `opam config var lib`/$(parent)
	-if [ "uninstall" = "$@" ] ; then \
		ocamlfind remove -destdir `opam config var lib`/$(parent) $(pkg) ; \
	else \
		ocamlfind install -destdir `opam config var lib`/$(parent) $(pkg) \
			$(install_files) -optional $(optional_files) -ldconf ignore ; \
	fi
	-cat `opam config var lib`/$(parent)/*/META \
		> `opam config var lib`/$(parent)/META
	-ocamlfind list | grep $(parent) ; sleep 2
dist: 
	-@mkdir -p build/$(distdir) ; cp -f exclude.lst build/
#	#-zip -9 -q --exclude @exclude.lst -r - . | unzip -od build/$(distdir) -
	-tar --format=posix --dereference --exclude-from=exclude.lst -cf - . | tar -xpf - -C build/$(distdir)
	
	-@for fmt in `echo $(FMTS) | tr ',' ' '` ; do \
		case $$fmt in \
			zip) echo "### build/$(distdir).zip ###" ; \
				rm -f build/$(distdir).zip ; \
				(cd build ; zip -9 -q -r $(distdir).zip $(distdir)) ;; \
			*) tarext=`echo $$fmt | grep -e '^tar$$' -e '^tar.xz$$' -e '^tar.bz2$$' || echo tar.gz` ; \
				echo "### build/$(distdir).$$tarext ###" ; \
				rm -f build/$(distdir).$$tarext ; \
				(cd build ; tar --posix -L -caf $(distdir).$$tarext $(distdir)) ;; \
		esac \
	done
	-@rm -r build/$(distdir)
report: 
	-mkdir -p _build/cov
	-bisect-report -I _build -html _build/cov/report_main `ls -t _build/bisect_main*.out | head -n1`
	-bisect-report -I _build -html _build/cov/report_test `ls -t _build/bisect_test*.out | head -n1`


#-include Makefile-auxffi.mk
