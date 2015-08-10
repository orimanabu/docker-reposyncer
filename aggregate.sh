#!/bin/bash

#topdir=/repowork/wip7-aggr/repos
#test=echo

function usage {
	echo "$0 [-t|--topdir] [-r|--with-rpm] [-s|--with-srpm] [-d|--with-debuginfo] repo"
	exit 1
}

function aggregate_repo {
	local _repo=$1; shift
	local subdir=$1; shift
	
	repopath=${topdir}/${_repo}
	if [ ! -d ${repopath}/Packages ]; then
		echo "==> ${_repo} : Packages not found, skip"
		exit
	fi

	echo "==> ${_repo}"
	for rpmpath in ${repopath}/Packages/*.rpm; do
		_rpm=$(basename ${rpmpath})
		echo "===> ${rpmpath}"

		# If rpmpath is already symlink, skip to next rpm.
		result=$(readlink ${rpmpath})
		if [ x"$?" = x"0" ]; then
			echo "${result}: already symlinked, skip"
			continue
		fi

		# Create index directory.
		index=$(echo ${_rpm} | sed -e 's/^\(.\).*$/\1/' | tr '[A-Z]' '[a-z]')
		rpmdir=${topdir}/ALL/${subdir}
		${test} mkdir -p ${rpmdir}/${index}

		# Check if rpmpath is already aggregated.
		if [ -f ${rpmdir}/${index}/${_rpm} ]; then
			echo "${rpmdir}/${index}/${_rpm}: already aggregated, reuse"
			${test} rm -f ${rpmpath}
		else
			echo "${_repo}/${_rpm}: first aggregation"
			${test} mv ${rpmpath} ${rpmdir}/${index}/${_rpm}
		fi

		# Create symlink.
		(cd ${repopath}/Packages && ln -s ../../ALL/${subdir}/${index}/${_rpm} .)
#		${test} "(cd ${repo}/Packages && ln -s ../../ALL/${subdir}/${index}/${_rpm} .)"
	done
}

OPT=`getopt -o ht:rsd --long help,topdir:,with-rpm,with-srpm,with-debuginfo --long test -- "$@"`
if [ $? != 0 ] ; then
    exit 1
fi
eval set -- "$OPT"

while true
do
	case "$1" in
	-t | --topdir)
		topdir=$2
		shift 2
		;;
	-r | --with-rpm)
		rpm=1
		shift 1
		;;
	-s | --with-srpm)
		srpm=1
		shift 1
		;;
	-d | --with-debuginfo)
		debuginfo=1
		shift 1
		;;
	-h | --help)
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

if [ x"${topdir}" = x"" ]; then
	echo "needs topdir"
	usage
fi
if [ x"$#" != x"1" ]; then
	usage
fi
repo=$1; shift

subdir=rpms
echo ${repo} | grep -- '-source-rpms$' > /dev/null 2>&1
if [ x"$?" = x"0" ]; then
	subdir=sources
fi
echo ${repo} | grep -- '-debug-rpms$' > /dev/null 2>&1
if [ x"$?" = x"0" ]; then
	subdir=debuginfo
fi

aggregate_repo ${repo} ${subdir}
