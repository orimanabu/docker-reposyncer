#!/bin/bash

for file in envfile.rhel7 envfile.rhel6; do
	test -f ${file} && sed \
	-e 's/\(RHN_SUBSCRIPTION_POOL=\).*/\1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/' \
	-e 's/\(RHN_USER=\).*/\1who@example.com/' \
	-e 's/\(RHN_PASSWORD=\).*/\1mypassword/' \
	-e 's/\(RHN_ACTIVATION_KEY=\).*/\1yyyyyyyyyyyyyyyyyyyyyyy/' \
	-e 's/\(RHN_ORG=\).*/\1zzzzzzz/' \
	-e 's/\(RHN_NAME=\).*/\1docker-image-reposyncer/' \
	${file} > ${file}.filtered
done
