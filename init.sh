#!/bin/bash

VG=datavg
POOL=repo-pool
MNT=/mnt/tmp

## Create Thin Pool
DATALV=${POOL}
METALV=${POOL}meta
CHUNK_SIZE=512K
MAX_META=16G

echo "=> create lv for metadata"
lvcreate -L ${MAX_META} -n ${METALV} ${VG}
echo "=> create lv for data"
lvcreate -l 90%FREE -n ${DATALV} ${VG}
echo "=> build thin pool"
lvconvert -y --zero n -c ${CHUNK_SIZE} --thinpool ${VG}/${DATALV} --poolmetadata ${VG}/${METALV}

## Create filesystem on the thinpool
echo "=> mkfs"
mkfs.xfs /dev/${VG}/${POOL}

#mount /dev/${VG}/${POOL} ${MNT}
#chcon -Rt svirt_sandbox_file_t ${MNT}
