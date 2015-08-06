DISTRIBUTION=rhel7
IMAGE=ori/reposyncer-${DISTRIBUTION}
DOCKERFILE=Dockerfile.${DISTRIBUTION}
ENVFILE=envfile.${DISTRIBUTION}
CONTAINER_NAME=reposyncer-${DISTRIBUTION}

permission:
	chmod 600 envfile*

build:
	@echo "=> sudo ./build.sh ${DOCKERFILE} ${IMAGE}"
	@sudo ./build.sh ${DOCKERFILE} ${IMAGE}

prepare:
	@echo "=> ./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} prepare"
	@./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} prepare
run:
	@echo "=> ./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} reposync"
	@./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} reposync
