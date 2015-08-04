#!/bin/bash

if [ x"$#" != x"2" ]; then
	echo "$0 Dockerfile new_image"
	exit 1
fi
dockerfile=$1; shift
image=$1; shift

docker build -f ${dockerfile} -t ${image} .
