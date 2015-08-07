DISTRIBUTION=rhel7
IMAGE=ori/reposyncer-${DISTRIBUTION}
DOCKERFILE=Dockerfile.${DISTRIBUTION}
ENVFILE=envfile.${DISTRIBUTION}
CONTAINER_NAME=reposyncer-${DISTRIBUTION}
TOPDIR=/repowork
ORIGINAL_REPO=${TOPDIR}/${CONTAINER_NAME}/repos/redhat.repo

build:
	@echo "=> sudo ./build.sh ${DOCKERFILE} ${IMAGE}"
	@sudo ./build.sh ${DOCKERFILE} ${IMAGE}

prepare:
	@echo "=> ./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} prepare"
	@./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} prepare

envfile:
	test -f ${ENVFILE} && mv ${ENVFILE} ${ENVFILE}.$(shell date '+%Y%m%d-%H%M%S')
	./setup_envfile.sh --distribution ${DISTRIBUTION} --topdir ${TOPDIR} --repo ${ORIGINAL_REPO} -o ${ENVFILE}
	chmod 600 ${ENVFILE}

run:
	@echo "=> ./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} reposync"
	@./run.sh --image ${IMAGE} --name ${CONTAINER_NAME} --envfile ${ENVFILE} reposync
