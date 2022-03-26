# Targets Makefile script.
#----------------------------------------
# Common automatic variables legend (GNU make: make (Linux) gmake (FreeBSD)):
# $* - basename (cur target)  $^ - name(s) (all depns)  $< - name (1st depn)
# $@ - name (cur target)      $% - archive member name  $? - changed depns

FMTS ?= tar.gz,zip
distdir = $(proj)-$(version)

build/$(distdir) : 
	-@mkdir -p build/$(distdir) ; cp -f exclude.lst build/
#	#-zip -9 -q --exclude @exclude.lst -r - . | unzip -od build/$(distdir) -
	-tar --format=posix --dereference --exclude-from=exclude.lst -cf - . | tar -xpf - -C build/$(distdir)

src/$(parent)/$(proj).cma :
	-$(MLBUILD) $(ML_LFLAGS) $(ML_CFLAGS) $(ML_CCLib) $(ML_DllLib) $(ML_DllPath) $(mllibs_main) $@
src/$(parent)/$(proj).cmxa src/$(parent)/$(proj).cmxs :
	-$(MLBUILD) $(ML_LFLAGS) $(ML_CFLAGS) $(ML_CCLib) $(mllibs_main) $@

.PHONY: help clean test uninstall install dist doc report report-html
help: ## help
	@echo "##### subproject: $(proj) #####"
	@echo "Usage: $(MAKE) [target] -- some valid targets:"
#	-@for fileX in $(MAKEFILE_LIST) `if [ -z "$(MAKEFILE_LIST)" ] ; then echo Makefile Makefile-targets.mk ; fi` ; do \
#		grep -ve '^[A-Z]' $$fileX | awk '/^[^.%][-A-Za-z0-9_]+[ ]*:.*$$/ { print "...", substr($$1, 1, length($$1)) }' | sort ; \
#	done
	-@for fileX in $(MAKEFILE_LIST) `if [ -z "$(MAKEFILE_LIST)" ] ; then echo Makefile Makefile-targets.mk ; fi` ; do \
		grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $$fileX | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "%-25s%s\n", $$1, $$2}' ; \
	done
test: tests/ts_main.byte ## run test [TOPTS=""]
#	export [DY]LD_LIBRARY_PATH=. # ([da|ba|z]sh Linux)
#	setenv [DY]LD_LIBRARY_PATH . # (tcsh FreeBSD)
	-BISECT_FILE=_build/bisect_test _build/tests/ts_main.byte $(TOPTS)
clean: ## clean build artifacts
	-$(MLBUILD) -clean
uninstall install: ## [un]install artifacts
	-mkdir -p `opam config var lib`/$(parent)
	-if [ "uninstall" = "$@" ] ; then \
		ocamlfind remove -destdir `opam config var lib`/$(parent) $(pkg) ; \
	else \
		ocamlfind install -destdir `opam config var lib`/$(parent) $(pkg) \
			$(install_files) -optional $(optional_files) -ldconf ignore ; \
	fi
	-cat `opam config var lib`/$(parent)/*/META \
		> `opam config var lib`/$(parent)/META
	-opam list $(proj) ; sleep 3
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
doc: ## generate documentation
	-$(MLBUILD) $(proj).docdir/index.html
report report-html: ## report code coverage
	-@if [ "report-html" = "$@" ] ; then \
		mkdir -p _build/cov ; \
		bisect-report -I _build -html _build/cov/report_main `ls -t _build/bisect_main*.out | head -1` ; \
		bisect-report -I _build -html _build/cov/report_test `ls -t _build/bisect_test*.out | head -1` ; \
	fi
	-bisect-report -I _build -text - `ls -t _build/bisect_main*.out | head -1`
	-bisect-report -I _build -text - `ls -t _build/bisect_test*.out | head -1`
