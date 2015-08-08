#!/bin/bash

OPT=`getopt -o i:r:o:d:u:p:a:O:P:n: --long topdir:,rpm:,srpm:,debuginfo:,repofile:,input:,output:,distribution:,user:,password:,activationkey:,org:,organization:,pool:,name: --long test -- "$@"`
if [ $? != 0 ] ; then
    exit 1
fi
eval set -- "$OPT"

while true
do
	case "$1" in
	-r | --repofile)
		repofile=$2
		shift 2
		;;
	-i | --input)
		input=$2
		shift 2
		;;
	-o | --output)
		output=$2
		shift 2
		;;
	-d | --distribution)
		distribution=${2:-rhel7}
		shift 2
		;;
	-u | --user)
		user=${2:-"who@example.com"}
		shift 2
		;;
	-p | --password)
		password=${2:-"mypassword"}
		shift 2
		;;
	-a | --activationkey)
		activationkey=${2:-"yyyyyyyyyyyyyyyyyyyyyyy"}
		shift 2
		;;
	-O | --org | --organization)
		org=${2:-"zzzzzzz"}
		shift 2
		;;
	-P | --pool)
		pool=${2:-"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}
		shift 2
		;;
	-n | --name)
		name=$2
		shift 2
		;;
	--topdir)
		topdir=${2:-"."}
		shift 2
		;;
	--rpm)
		rpm=${2:-"1"}
		shift 2
		;;
	--srpm)
		srpm=${2:-"1"}
		shift 2
		;;
	--debuginfo)
		debuginfo=${2:-"1"}
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

if [ x"${distribution}" = x"" ]; then
	distribution=rhel7
fi
base_repo=$(echo ${distribution} | sed -e 's/\([^0-9]\+\)\([0-9]\+\)/\1-\2-server-rpms/')

if [ x"${input}" != x"" ]; then
	source ${input}
fi

echo "* repofile: ${repofile}"
echo "* input: ${input}"
echo "* output: ${output}"
echo "* distribution: ${distribution}"
echo "* user: ${user}"
echo "* password: ${password}"
echo "* activationkey: ${activationkey}"
echo "* org: ${org}"
echo "* pool: ${pool}"
echo "* name: ${name}"
echo "* topdir: ${topdir}"
echo "* rpm: ${rpm}"
echo "* srpm: ${srpm}"
echo "* debuginfo: ${debuginfo}"
echo "* test: ${test}"

echo "* RHN_USER: ${RHN_USER}"
echo "* RHN_PASSWORD: ${RHN_PASSWORD}"
echo "* RHN_ACTIVATION_KEY: ${RHN_ACTIVATION_KEY}"
echo "* RHN_ORG: ${RHN_ORG}"
echo "* RHN_SUBSCRIPTION_POOL: ${RHN_SUBSCRIPTION_POOL}"
echo "* RHN_NAME: ${RHN_NAME}"
echo "* TOPDIR: ${TOPDIR}"
echo "* RPM: ${RPM}"
echo "* SRPM: ${SRPM}"
echo "* DEBUGINFO: ${DEBUGINFO}"

echo "* base_repo: ${base_repo}"
#exit

if [ x"${output}" != x"" ]; then
	exec 3>&1
	exec > ${output}
fi

cat <<END
RHN_USER=${RHN_USER:-${user}}
RHN_PASSWORD=${RHN_PASSWORD:-${password}}
#RHN_ACTIVATION_KEY=${RHN_ACTIVATION_KEY:-${activationkey}}
#RHN_ORG=${RHN_ORG:-${org}}
RHN_SUBSCRIPTION_POOL=${RHN_SUBSCRIPTION_POOL:-${pool}}
RHN_NAME=docker-reposyncer-${distribution}

TOPDIR=${TOPDIR:-${topdir}}

RPM=${RPM:-${rpm}}
SRPM=${SRPM:-${srpm}}
DEBUGINFO=${DEBUGINFO:-${debuginfo}}

BASE_REPOS="
${base_repo} \\
"

REPOS="
END

grep '^\[' ${repofile} | sed -e 's/^\[//' -e 's/\]$/ \\/' | grep -Ev -- '-(debug|source|eus|htb|aus|beta|fastrack)-' | sort

cat <<END
"

EXCLUDE_REPOS="
"
END
