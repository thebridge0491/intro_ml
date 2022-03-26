build:
	dune build
clean:
	dune clean
uninstall:
	dune uninstall
install:
	dune install ; opam list $(proj) ; sleep 3
doc:
	dune build @doc
test:
	dune runtest -f

prefix ?= /usr/local

PKG_CONFIG = pkg-config --with-path=$(prefix)/lib/pkgconfig

parent = intro_ml
pkg = foreignc
proj = $(parent)-$(pkg)
version ?= 0.1.0

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

FMTS ?= tar.gz,zip
distdir = $(proj).$(version)

build/$(distdir) : 
	-@mkdir -p build/$(distdir) ; cp -f exclude.lst build/
#	#-zip -9 -q --exclude @exclude.lst -r - . | unzip -od build/$(distdir) -
	-tar --format=posix --dereference --exclude-from=exclude.lst -cf - . | tar -xpf - -C build/$(distdir)

dist: | build/$(distdir) ## [FMTS="tar.gz,zip"] archive source code
	-@for fmt in `echo $(FMTS) | tr ',' ' '` ; do \
		case $$fmt in \
			7z) echo "### build/$(distdir).7z ###" ; \
				rm -f build/$(distdir).7z ; \
				(cd build ; 7za a -t7z -mx=9 $(distdir).7z $(distdir)) ;; \
			zip) echo "### build/$(distdir).zip ###" ; \
				rm -f build/$(distdir).zip ; \
				(cd build ; zip -9 -q -r $(distdir).zip $(distdir)) ;; \
			*) tarext=`echo $$fmt | grep -e '^tar$$' -e '^tar.xz$$' -e '^tar.zst$$' -e '^tar.bz2$$' || echo tar.gz` ; \
				echo "### build/$(distdir).$$tarext ###" ; \
				rm -f build/$(distdir).$$tarext ; \
				(cd build ; tar --posix -h -caf $(distdir).$$tarext $(distdir)) ;; \
		esac \
	done
	-@rm -r build/$(distdir)
report:
	-mkdir -p _build/cov
	-bisect-report -I _build -html _build/cov/report_main `ls -t _build/bisect_main*.out | head -n1`
	-bisect-report -I _build -html _build/cov/report_test `ls -t _build/bisect_test*.out | head -n1`


#-include Makefile-auxffi.mk
