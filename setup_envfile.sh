#!/bin/bash

OPT=`getopt -o r:o:d:u:p:a:O:P:n: --long topdir:,rpm:,srpm:,debuginfo:,repo:,output:,distribution:,user:,password:,activationkey:,org:,organization:,pool:,name: --long test -- "$@"`
if [ $? != 0 ] ; then
    exit 1
fi
eval set -- "$OPT"

while true
do
	case "$1" in
	-r | --repo)
		repo=$2
		shift 2
		;;
	-o | --output)
		output=$2
		shift 2
		;;
	-d | --distribution)
		distribution=$2
		shift 2
		;;
	-u | --user)
		user=$2
		shift 2
		;;
	-p | --password)
		password=$2
		shift 2
		;;
	-a | --activationkey)
		activationkey=$2
		shift 2
		;;
	-O | --org | --organization)
		org=$2
		shift 2
		;;
	-P | --pool)
		pool=$2
		shift 2
		;;
	-n | --name)
		name=$2
		shift 2
		;;
	--topdir)
		topdir=$2
		shift 2
		;;
	--rpm)
		rpm=$2
		shift 2
		;;
	--srpm)
		srpm=$2
		shift 2
		;;
	--debuginfo)
		debuginfo=$2
		shift 2
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
if [ x"${output}" != x"" ]; then
	exec 3>&1
	exec > ${output}
fi

if [ x"${distribution}" = x"" ]; then
	distribution=rhel7
fi
base_repo=$(echo ${distribution} | sed -e 's/\([^0-9]\+\)\([0-9]\+\)/\1-\2-server-rpms/')

cat <<END
RHN_USER=${user:-"who@example.com"}
RHN_PASSWORD=${password:-"mypassword"}
#RHN_ACTIVATION_KEY=${activationkey:-"yyyyyyyyyyyyyyyyyyyyyyy"}
#RHN_ORG=${org:-"zzzzzzz"}
RHN_SUBSCRIPTION_POOL=${pool:-"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}
RHN_NAME=docker-reposyncer-${distribution}

TOPDIR=${topdir:-"/repowork"}

RPM=${rpm:-"1"}
SRPM=${srpm:-"1"}
DEBUGINFO=${debuginfo:-"1"}

BASE_REPOS="
${base_repo} \\
"

REPOS="
END

grep '^\[' /repowork/reposyncer-rhel7/repos/redhat.repo | sed -e 's/^\[//' -e 's/\]$/ \\/' | grep -Ev -- '-(debug|source|eus|htb|aus|beta|fastrack)-' | sort

cat <<END
"

EXCLUDE_REPOS="
"
END
