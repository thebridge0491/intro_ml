Intro_ml.Practice
===========================================
.. .rst to .html: rst2html5 foo.rst > foo.html
..                pandoc -s -f rst -t html5 -o foo.html foo.rst

Practice sub-package for OCaml Intro examples project.

Installation
------------
source code tarball download:
    
        # [aria2c --check-certificate=false | wget --no-check-certificate | curl -kOL]
        
        FETCHCMD='aria2c --check-certificate=false'
        
        $FETCHCMD https://bitbucket.org/thebridge0491/intro_ml/[get | archive]/master.zip

version control repository clone:
        
        git clone https://bitbucket.org/thebridge0491/intro_ml.git

build example with [ocamlbuild | make]:
cd <path> ; [sh] ./configure.sh [--prefix=$PREFIX] [--help]

make build [test]

[sudo] make install

build example with oasis:
cd <path> [; oasis setup -setup-update none]

ocaml setup.ml -configure --enable-tests [--prefix $PREFIX]

opam pin add . ; opam install . [; ocaml setup.ml [-info] -install]

build example with dune:
cd <path> ; opam pin add [--with-test] .

dune build [runtest -f]

dune install

Usage
-----
        // PKG_CONFIG='pkg-config --with-path=$PREFIX/lib/pkgconfig'
        
        // $PKG_CONFIG --cflags --libs <ffi-lib>

        [LD_LIBRARY_PATH=$PREFIX/lib] ocaml
        
        # #use "topfind" ;;
        
        # #require "intro_ml.practice" ;;
        
        # open Practice ;;
        
        # Classic.fact_i 5L ;;

Author/Copyright
----------------
Copyright (c) 2014 by thebridge0491 <thebridge0491-codelab@yahoo.com>

License
-------
Licensed under the Apache-2.0 License. See LICENSE for details.
