#!/bin/bash

if [ x"$#" != x"3" ]; then
	echo "$0 image src dest"
	echo "E.g. $0 registry.access.redhat.com/rhel7 var/cache/yum /repowork/mytmp/yumcache"
	exit 1
fi
image=$1; shift
srcdir=$1; shift
destdir=$1; shift

vol=docker_tmpvol
mount_point=/mnt/docker_tmp
mkdir -p /mnt/docker_tmp

image_id=$(cat /var/lib/docker/repositories-devicemapper | jq -r '.Repositories | .["'${image}'"] | .latest')
device_id=$(cat /var/lib/docker/devicemapper/metadata/${image_id} | jq '.device_id')
size=$(cat /var/lib/docker/devicemapper/metadata/${image_id} | jq '.size')
pool=$(docker info | awk '/Pool Name:/ {print $3}')

echo "* image_id=${image_id}"
echo "* device_id=${device_id}"
echo "* size=${size}"
echo "* pool=${pool}"

if [ x"$image_id" = x"null" -o x"$image_id" = x"" -o x"$device_id" = x"" -o x"$size" = x"" -o x"$pool" = x"" ]; then
	echo "invalid values."
	exit 1
fi

dmsetup create ${vol} --table "0 $((${size} / 512)) thin /dev/mapper/${pool} ${device_id}"
mount /dev/mapper/${vol} ${mount_point}

echo "* backup from image: src=${srcdir}, dst=${destdir}"
ls ${mount_point}/rootfs/${srcdir}
(cd ${mount_point}/rootfs/${srcdir} && tar cf - .) | (cd ${destdir} && tar xpvf -)

umount ${mount_point}
dmsetup remove ${vol}
