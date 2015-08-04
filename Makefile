DISTRIBUTION=rhel7
IMAGE=ori/reposyncer-${DISTRIBUTION}
DOCKERFILE=Dockerfile.${DISTRIBUTION}
ENVFILE=envfile.${DISTRIBUTION}
CONTAINER=reposyncer-${DISTRIBUTION}

permission:
	chmod 600 envfile*

build:
	@echo "=> sudo ./build.sh ${DOCKERFILE} ${IMAGE}"
	@sudo ./build.sh ${DOCKERFILE} ${IMAGE}

run:
	@echo "=> time sudo ./run.sh ${IMAGE} ${CONTAINER} ${ENVFILE}"
	@sudo ./run.sh ${IMAGE} ${CONTAINER} ${ENVFILE}
