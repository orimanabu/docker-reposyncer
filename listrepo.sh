#!/bin/bash

function usage {
	echo "$0 [-d|--distribution DISTRIBUTION] [--already-downloaded|--from-repo-file]"
	exit 1
}

OPT=`getopt -o d: --long help,distribution:,already-downloaded,from-repo-file: --long test -- "$@"`
if [ $? != 0 ] ; then
    exit 1
fi
eval set -- "$OPT"

distribution=rhel7

while true
do
	case "$1" in
	-d | --distribution)
		distribution=$2
		shift 2
		;;
	--already-downloaded)
		mode="already_downloaded"
		shift 1
		;;
	--from-repo-file)
		mode="from_repo_file"
		repofile=$2
		shift 2
		;;
	--help)
		usage
		;;
	--test)
		test=echo
		shift 1
		;;
	--)
		shift
		break
		;;
	*)
		echo "unknown option: $1"
		exit 1
		;;
	esac
done

case ${mode} in
already_downloaded)
	ls -1 /repowork/reposyncer-${distribution}/repos | grep -v redhat.repo | grep -v bootstrap | sort
	;;
from_repo_file)
	grep '^\[' ${repofile} | sed -e 's/^\[//' -e 's/\]$//' | grep -Ev -- '-(debug|source|eus|htb|aus|beta|fastrack)-' | sort
	;;
*)
	echo "unknown mode: ${mode}"
	exit 1
	;;
esac
