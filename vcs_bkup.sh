#!/bin/sh

# usage: sh vcs_bkup.sh bundle_revsets [revsets]
#        sh vcs_bkup.sh archive_rev [namePrefix [revID [opts]]]
#        sh vcs_bkup.sh fix_template [opts]
#        sh vcs_bkup.sh changed_files_archive [namePrefix [revID]]

project=${project:-intro}
lang_suf=${lang_suf:-_ml}

bundle_revsets() {
	revsets=${@:-'--all'}
	echo revsets: ${revsets}
	
	if [ -e ".hg" ] ; then
		hg bundle --type v1 ${revsets} ${project}${lang_suf}.hg ;
	elif [ -e ".git" ] ; then
		git bundle create ${project}${lang_suf}.git ${revsets} ;
	fi
}

archive_rev() {
	namePrefix=${1:-${project}} #; revID=${2:-master}
	opts=${3:-}
	
	if [ -e ".hg" ] ; then
		hg archive --rev ${2:-default} ${opts} ${namePrefix}${lang_suf}.zip ;
	elif [ -e ".git" ] ; then
		git archive --output ${namePrefix}${lang_suf}.zip \
			--prefix ${namePrefix}${lang_suf}/ ${2:-master} ${opts} ;
	fi
}

fix_template() {
	opts=$@
	
	if [ -e ".hg" ] ; then
		hg archive --rev fix_template -I _templates $opts \
			template${lang_suf}.zip ;
	elif [ -e ".git" ] ; then
		git archive --output template${lang_suf}.zip \
			--prefix template${lang_suf}/ fix_template _templates $opts ;
	fi
}

# list all revision hashes (ascending order):
#  hg log -r : -T '{node|short}'
#  git log --all --reverse --format="%h"
#  git rev-list --all --reverse --abbrev-commit HEAD

changed_files_archive() {
	namePrefix=${1:-changedFiles} #; revID=${2:-HEAD}
	
	if [ -e ".hg" ] ; then
		#filesX=$(hg status --change ${2:-tip} --no-status | sed 's|^| -I |') ;
		filesX=$(hg log -r ${2:-tip} -T '{join(files, " -I ")}') ;
		hg archive --rev ${2:-tip} -I ${filesX} ${namePrefix}.zip ;
	elif [ -e ".git" ] ; then
		##nullHash=$(echo -n '' | git hash-object -t tree --stdin) ;
		revXtoY=${2:-HEAD}~1..${2:-HEAD} ;
		#filesX=$(git diff-tree -r --diff-filter=ACMRTUXB --no-commit-id --name-only ${revXtoY}) ;
		filesX=$(git diff -r --diff-filter=ACMRTUXB --name-only ${revXtoY}) ;
		git archive --output ${namePrefix}.zip --prefix ${namePrefix}/ \
			${2:-HEAD} ${filesX} ;
	fi
}

func=$1 ; shift ;
${func} $@ ;

#--------------------------------------------------------------------
