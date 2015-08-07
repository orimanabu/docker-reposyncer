#!/bin/bash

#test=echo
#source ${ENVFILE}
repotop=/repos
metatop=/metadata

REPOS=$(echo ${REPOS} | sed -e 's/,/ /g')
EXCLUDE_REPOS=$(echo ${EXCLUDE_REPOS} | sed -e 's/,/ /g')
echo "* MODE: ${MODE}"

smopts=""
if [ x"$RHN_NAME" != x"" ]; then
	smopts="${smopts} --name ${RHN_NAME}"
fi
if [ x"$RHN_ACTIVATION_KEY" != x"" -a x"$RHN_ORG" != x"" ]; then
	smopts="${smopts} --org ${RHN_ORG} --activationkey ${RHN_ACTIVATION_KEY}"
	smmsg="with activation key"
elif [ x"$RHN_USER" != x"" -a x"$RHN_PASSWORD" != x"" ]; then
	smopts="${smopts} --username ${RHN_USER} --password ${RHN_PASSWORD}"
	smmsg="with user auth"
else
	echo "No subscription info, failed."
	exit 1
fi
echo "=> subscription-manager register ${smmsg}"
${test} subscription-manager register ${smopts}
if [ x"$?" != x"0" ]; then
	echo "subscription-manager register failed."
	exit 1
fi

echo "=> subscription-manager attach"
${test} subscription-manager attach --pool $RHN_SUBSCRIPTION_POOL
if [ x"$?" != x"0" ]; then
	echo "subscription-manager attach failed."
	exit 1
fi

case ${MODE} in
prepare)
	echo "=> entering ${MODE} mode: get redhat.repo"
	echo "=> copy redhat.repo"
	cp /etc/yum.repos.d/redhat.repo ${repotop}/redhat.repo
	echo "=> subscription-manager unregister"
	${test} subscription-manager unregister
	exit
	;;
run|reposync)
	echo "=> entering ${MODE} mode: reposync"
	;;
esac

echo "=> subscription-manager repos"
opts=""
for repo in ${BASE_REPOS} ${REPOS}; do
	opts="${opts} --enable ${repo}"
done
${test} subscription-manager repos --disable '*' ${opts}
if [ x"$?" != x"0" ]; then
	echo "subscription-manager repos failed."
	exit 1
fi

echo "=> yum install"
#${test} yum install -y iproute openssh-server openssh-clients openssh rsync yum-utils deltarpm createrepo
${test} yum install -y yum-utils deltarpm createrepo
if [ x"$?" != x"0" ]; then
	echo "yum install failed."
	exit 1
fi

suffixes=""
if [ x"$RPM" = x"1" ]; then
	suffixes="${suffixes} rpms"
fi
if [ x"$SOURCE" = x"1" -o x"$SRPM" = x"1" ]; then
	suffixes="${suffixes} source-rpms"
fi
if [ x"$DEBUG" = x"1" -o x"$DEBUGINFO" = x"1" ]; then
	suffixes="${suffixes} debug-rpms"
fi

for _repo in ${REPOS}; do
skip=0
for e_repo in ${EXCLUDE_REPOS}; do
	if [ ${_repo} = ${e_repo} ]; then
		skip=1
	fi
done
if [ x"$skip" = x"1" ]; then
	echo "=> reposync ${_repo} :: SKIP"
	continue
fi

for suffix in ${suffixes}; do
	## reposync
	repo=${_repo%-rpms}-${suffix}
	echo "=> reposync ${repo}"
	${test} reposync --repoid ${repo} --download_path ${repotop} --downloadcomps --download-metadata --cachedir ${metatop} --source

	## createrepo
	repodir=${repotop}/${repo}

	## XXX reposync bug?
	culprit_srpms=$(find ${repodir} -maxdepth 1 -name '*.rpm')
	if [ x"$culprit_srpms" != x"" ]; then
		test -d ${repodir}/Packages || mkdir -p ${repodir}/Packages
	fi
	for rpm in ${culprit_srpms}; do
		${test} mv ${rpm} ${repodir}/Packages/
	done

	cr_opts=""
	cr_msg=""
	if [ -f ${repodir}/comps.xml ]; then
		cr_opts="${cr_opts} -g ${repodir}/comps.xml"
		cr_msg="with comps.xml"
	fi
	echo "==> createrepo: ${repodir} ${cr_msg}"
	${test} createrepo -s sha256 --checkts --update ${cr_opts} ${repodir}

	## modifyrepo
	if [ -f ${repodir}/productid.gz ]; then
		echo "==> modifyrepo: productid"
		${test} gzip -dc ${repodir}/productid.gz > ${repodir}/productid
		${test} modifyrepo ${repodir}/productid ${repodir}/repodata/
		rm -f ${repodir}/productid
	fi

	ls ${repodir}/*updateinfo.xml.gz > /dev/null 2>&1
	if [ x"$?" = x"0" ]; then
		echo "==> modifyrepo: updateinfo"
		updateinfo_with_checksum=$(ls -1t ${repodir}/*updateinfo.xml.gz | head -n 1)
		#echo "===> src updateinfo: ${updateinfo_with_checksum}"
		${test} gzip -dc ${updateinfo_with_checksum} > ${repodir}/updateinfo.xml
		${test} modifyrepo ${repodir}/updateinfo.xml ${repodir}/repodata/
		#updateinfo_with_checksum2=$(ls -1t ${repodir}/repodata/*updateinfo.xml.gz | head -n 1)
		#echo "===> dst updateinfo: ${updateinfo_with_checksum2}"
		rm -f ${repodir}/updateinfo.xml
		rm -f ${updateinfo_with_checksum}
	fi
	done
done

echo "=> yum makecache"
${test} yum makecache

echo "=> subscription-manager unregister"
${test} subscription-manager unregister
