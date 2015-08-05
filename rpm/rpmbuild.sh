#!/bin/bash

package=reposyncer-gps-nrt
version=1-1
rpmbuild_dir=${HOME}/rpmbuild
mockconf=rhel-7-x86_64

if [ x"$#" != x"1" ]; then
	echo "$0 op"
	exit 1
fi
op=$1; shift

case ${op} in
build)
	cp ${package}.repo ${rpmbuild_dir}/SOURCES
	cp ${package}.spec ${rpmbuild_dir}/SPECS
	rpmbuild -bs ${rpmbuild_dir}/SPECS/${package}.spec
	#mock -r rhel-7-x86_64 --init
	mock -r ${mockconf} rebuild ${rpmbuild_dir}/SRPMS/${package}-${version}.src.rpm
	#mock -r rhel-7-x86_64 --clean
	;;
deploy)
	cp /var/lib/mock/${mockconf}/result/${package}-${version}.{noarch,src}.rpm /repowork/reposyncer-rhel7/repos/bootstrap/Packages/
	;;
*)
	echo "${op}: unknown op."
	exit 1
	;;
esac
