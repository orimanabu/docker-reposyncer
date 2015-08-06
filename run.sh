#!/bin/bash

## default values
#test=echo
#distribution=rhel7
#image=ori/reposyncer-${distribution}
#envfile=envfile.${distribution}
#name=reposyncer-${distribution}

function setup_env {
	local env=$1; shift
	local val="$(eval echo '$'${env})"
	export ${env}="${val}"
	val=$(echo ${val} | sed -e 's/ /,/g')
	envopts="${envopts} -e ${env}=${val}"
}

OPT=`getopt -o i:n:e:t: --long image:,name:,env:,envfile: --long test -- "$@"`
if [ $? != 0 ] ; then
    exit 1
fi
eval set -- "$OPT"

while true
do
    case "$1" in
    -i | --image)
	image=$2
        shift 2
        ;;
    -n | --name)
	name=$2
        shift 2
        ;;
    -e | --env | --envfile)
	envfile=$2
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

if [ x"$#" != x"1" ]; then
	echo "$0 [--test] [--image IMAGE] [--name CONTAINER_NAME] [--envfile ENVFILE] mode"
	echo "mode: prepare, run"
	exit 1
fi
MODE=$1; shift

if [ x"$image" = x"" -o x"$name" = x"" -o x"$envfile" = x"" ]; then
	echo "needs mandatory options: --image, --name, --envfile"
	exit 1
fi
if [ ! -f "$envfile" ]; then
	echo "no such file: ${envfile}"
	exit 1
fi
source ${envfile}

echo "* test: ${test}"
echo "* image: ${image}"
echo "* name: ${name}"
echo "* envfile: ${envfile}"
echo "* op: ${op}"
echo "* TOPDIR: ${TOPDIR}"
echo "* RPM: ${RPM}"
echo "* SRPM: ${SRPM}"
echo "* DEBUGINFO: ${DEBUGINFO}"
echo "* REPOS: ${REPOS}"
echo "* EXCLUDE_REPOS: ${EXCLUDE_REPOS}"

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
setup_env TOPDIR
setup_env REPOS
setup_env EXCLUDE_REPOS
setup_env RPM
setup_env SRPM
setup_env DEBUGINFO

repodir=${TOPDIR}/${name}/repos
metadir=${TOPDIR}/${name}/metadata
yumcache=${TOPDIR}/${name}/yumcache
mkdir -p ${repodir}
mkdir -p ${metadir}
if [ ! -d ${yumcache} ]; then
	mkdir -p ${yumcache}
	./copy_from_image.sh ${image} var/cache/yum ${yumcache}
fi

export MODE=${MODE}
envopts="${envopts} -e MODE=${MODE}"
${test} docker run --name ${name} ${envopts} -v ${yumcache}:/var/cache/yum -v ${repodir}:/repos -v ${metadir}:/metadata -i ${image}
${test} docker stop ${name}
${test} docker rm ${name}

#docker run --name mytmp -v /repowork/mytmp/yumcache:/var/cache/yum -v /repowork/mytmp/repos:/repos -v /repowork/mytmp/metadata:/metadata -it registry.access.redhat.com/rhel7 /bin/bash
