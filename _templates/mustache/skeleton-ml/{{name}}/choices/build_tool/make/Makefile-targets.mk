# Targets Makefile script.
#----------------------------------------
# Common automatic variables legend (GNU make: make (Linux) gmake (FreeBSD)):
# $* - basename (cur target)  $^ - name(s) (all depns)  $< - name (1st depn)
# $@ - name (cur target)      $% - archive member name  $? - changed depns

FMTS ?= tar.gz
distdir = $(proj)-$(version)
MLDOC = ocamlfind ocamldoc

LINK.cmo = $(MLC) $(ML_LFLAGS) $(ML_CFLAGS)
LINK.cmx = $(MLOPT) $(ML_LFLAGS) $(ML_CFLAGS)

#.ml.mli : 
#	-cd build ; $(MLC) $(ML_CFLAGS) -i ../$< > $@
.mli.cmi : 
	-cd build ; $(MLC) $(ML_CFLAGS) -c -o $@ ../$<
.ml.cmi : 
	-cd build ; $(MLC) $(ML_CFLAGS) -c -o $@ ../$<
.ml.cmo :
	-cd build ; $(MLC) $(ML_CFLAGS) -c -o $@ ../$<
.ml.cmx :
	-cd build ; $(MLOPT) $(ML_CFLAGS) -c -o $@ ../$<

%.cma : 
	-cd build ; $(LINK.cmo) $(ML_CCLib) $(ML_DllLib) $(ML_DllPath) $^ -o $@ -a
%.cmxa : 
	-cd build ; $(LINK.cmx) $(ML_CCLib) $^ -o $@ -a
%.cmxs : 
	-cd build ; $(LINK.cmx) $(ML_CCLib) $^ -o $@ -shared
%.odoc : 
	-cd build ; $(MLDOC) -verbose $(ML_CFLAGS) -dump $@ $^

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
	-cd build ; BISECT_FILE=bisect_test tests/ts_main.byte $(TOPTS)
clean: ## clean build artifacts
	-rm -rf build/* build/.??*
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
	-ocamlfind list | grep $(parent) ; sleep 2
dist: ## [FMTS="tar.gz"] archive source code
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
doc: src/$(parent)/$(proj).odoc ## generate documentation
	-rm -rf build/$(proj).docdir ; mkdir -p build/$(proj).docdir
	-cd build ; $(MLDOC) -verbose -html -d $(proj).docdir -load $< \
		$(mllibs_main_cma)
report report-html: ## report code coverage
	-@if [ "report-html" = "$@" ] ; then \
		mkdir -p build/cov ; \
		bisect-report -I build -html cov/report_main `ls -t build/bisect_main*.out | head -1` ; \
		bisect-report -I build -html cov/report_test `ls -t build/bisect_test*.out | head -1` ; \
	fi
	-bisect-report -I build -text - `ls -t build/bisect_main*.out | head -1`
	-bisect-report -I build -text - `ls -t build/bisect_test*.out | head -1`
