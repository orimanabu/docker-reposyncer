#!/bin/bash

#test=echo
topdir=/repowork

function setup_env {
	local env=$1; shift
	local val="$(eval echo '$'${env})"
	export ${env}="${val}"
	val=$(echo ${val} | sed -e 's/ /,/g')
	envopts="${envopts} -e ${env}=${val}"
}

if [ x"$#" != x"3" ]; then
	echo "$0 image name envfile"
	exit 1
fi
image=$1; shift
name=$1; shift
envfile=$1; shift
source ${envfile}

envopts=""
setup_env RHN_SUBSCRIPTION_POOL
if [ x"$RHN_ACTIVATION_KEY" != x"" ]; then
	setup_env RHN_ACTIVATION_KEY
	setup_env RHN_ORG
elif [ x"$RHN_USER" != x"" ]; then
	setup_env RHN_USER
	setup_env RHN_PASSWORD
fi
setup_env RHN_NAME
setup_env BASE_REPOS
setup_env REPOS
setup_env EXCLUDE_REPOS
setup_env RPM
setup_env SRPM
setup_env DEBUGINFO

repodir=${topdir}/${name}/repos
metadir=${topdir}/${name}/metadata
yumcache=${topdir}/${name}/yumcache
mkdir -p ${repodir}
mkdir -p ${metadir}
if [ ! -d ${yumcache} ]; then
	mkdir -p ${yumcache}
	./copy_from_image.sh ${image} var/cache/yum ${yumcache}
fi

#docker run --name mytmp -v /repowork/mytmp/yumcache:/var/cache/yum -v /repowork/mytmp/repos:/repos -v /repowork/mytmp/metadata:/metadata -it registry.access.redhat.com/rhel7 /bin/bash
${test} docker run --name ${name} ${envopts} -v ${yumcache}:/var/cache/yum -v ${repodir}:/repos -v ${metadir}:/metadata -i ${image}
${test} docker stop ${name}
${test} docker rm ${name}
