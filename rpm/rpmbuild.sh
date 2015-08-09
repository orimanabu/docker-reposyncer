#!/bin/bash

OPT=`getopt -o d: --long distribution: --long test -- "$@"`
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

package_prefix=reposyncer-gps-nrt
spec_template=${package_prefix}-template.spec
specfile=${package_prefix}-${distribution}.spec
repofile=${package_prefix}-${distribution}.repo
rpmbuild_dir=${HOME}/rpmbuild
repotop=/repowork/reposyncer-${distribution}/repos

sed -e "s/__DISTRIBUTION__/${distribution}/" ${spec_template} > ${specfile}
spec_version=$(awk '/^Version:/ {print $2}' ${specfile})
spec_release=$(awk '/^Release:/ {print $2}' ${specfile})
version="${spec_version}-${spec_release}"
mockconf=$(echo ${distribution} | sed -e 's/\([^0-9]\+\)\([0-9]\+\)/\1-\2-x86_64/')

echo "* distribution: ${distribution}"
echo "* package_prefix: ${package_prefix}"
echo "* rpmbuild_dir: ${rpmbuild_dir}"
echo "* repotop: ${repotop}"
echo "* mockconf: ${mockconf}"
echo "* version: ${version}"
echo "* specfile: ${specfile}"
echo "* repofile: ${repofile}"

if [ x"$#" != x"1" ]; then
	echo "$0 op"
	exit 1
fi
op=$1; shift

case ${op} in
build)
	cp ${repofile} ${rpmbuild_dir}/SOURCES
	cp ${specfile} ${rpmbuild_dir}/SPECS
	rpmbuild -bs ${rpmbuild_dir}/SPECS/${specfile}
	#mock -r rhel-7-x86_64 --init
	mock -r ${mockconf} rebuild ${rpmbuild_dir}/SRPMS/${package_prefix}-${distribution}-${version}.src.rpm
	#mock -r rhel-7-x86_64 --clean
	;;
deploy)
	mkdir -p ${repotop}/bootstrap/Packages/
	cp /var/lib/mock/${mockconf}/result/${package_prefix}-${distribution}-${version}.{noarch,src}.rpm ${repotop}/bootstrap/Packages/
	createrepo -s sha256 --checkts --update ${repotop}/bootstrap/
	;;
*)
	echo "${op}: unknown op."
	exit 1
	;;
esac
