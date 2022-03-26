#!/bin/sh

prefix=/usr/local
srcdir=.
vpath=.
debug=0

if [ build = `basename $PWD` ] ; then
	echo ; echo "ERROR: cd .. ; [sh] ./configure.sh [OPTIONS]" ;
	echo ; exit 1 ;
fi

for opt in "$@" ; do
	case $opt in
	--prefix=) ;;
	--srcdir=) ;;
	--prefix=*) prefix=`echo $opt | sed 's|--prefix=||'` ;;
	--srcdir=*) srcdir=`echo $opt | sed 's|--srcdir=||'` ; vpath=${srcdir} ;;
	--enable-debug) debug=1 ;;
	--disable-debug) debug=0 ;;
	--help)
		echo "Usage: [sh] ./configure.sh [OPTIONS]" ;
		echo "options:" ;
		echo "  --prefix=[${prefix}]: installation prefix" ;
		echo "  --srcdir=[${srcdir}]: source code directory" ;
		echo "  --enable-debug: include debug symbols during compile" ;
		echo "  --disable-debug: exclude debug symbols during compile" ;
		exit 0 ;;
	esac
done

echo "configuring Makefile ..."
cat << EOF > Makefile
.POSIX:
.SUFFIXES:
PREFIX = $prefix
VPATH = $vpath

EOF
if [ 1 = $debug ] ; then
	cat << EOF >> Makefile ;
DEBUG = $debug

EOF
fi
cat Makefile.new >> Makefile

echo "Finished configuring, for help: make help"
