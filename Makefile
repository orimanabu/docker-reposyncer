DISTRIBUTION=rhel7
IMAGE=ori/reposyncer-${DISTRIBUTION}
DOCKERFILE=Dockerfile.${DISTRIBUTION}
ENVFILE=envfile.${DISTRIBUTION}
CONTAINER_NAME=reposyncer-${DISTRIBUTION}
TOPDIR=/repowork
ORIGINAL_REPO=${TOPDIR}/${CONTAINER_NAME}/repos/redhat.repo
PACKAGE_PREFIX=reposyncer-gps-nrt

.PHONY: all build prepare envfile run rpm deploy

all:
	@echo "make targets:"
	@echo "  build   : buiod docker image"
	@echo "  prepare : run a image to get original repo file"
	@echo "  envfile : create envfile from original repo file"
	@echo "  run     : run reposync docker image"
	@echo "  rpm     : create bootstrap rpms"
	@echo "  deploy  : deploy bootstrap rpms"

build:
	./build.sh ${DOCKERFILE} ${IMAGE}

prepare:
	./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} prepare

envfile:
	test -f ${ENVFILE} && mv ${ENVFILE} ${ENVFILE}.$(shell date '+%Y%m%d-%H%M%S')
	./setup_envfile.sh --distribution ${DISTRIBUTION} --topdir ${TOPDIR} --repo ${ORIGINAL_REPO} -i ${ENVFILE} -o ${ENVFILE}
	chmod 600 ${ENVFILE}

run:
	./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} reposync

rpm:
ifndef HOST
	@echo "HOST not defined"
	@exit 1
endif
	./listrepo.sh -d ${DISTRIBUTION} --already-downloaded | ./rpm/parse_repo.py -s ${ORIGINAL_REPO} -u http://${HOST}/reposync/$(shell echo ${DISTRIBUTION} | tr '[a-z]' '[A-Z]')/repos > ./rpm/${PACKAGE_PREFIX}-${DISTRIBUTION}.repo
	(cd rpm && ./rpmbuild.sh -d ${DISTRIBUTION} build)

deploy:
	(cd rpm && ./rpmbuild.sh -d ${DISTRIBUTION} deploy)
