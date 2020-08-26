#!/bin/bash
for ARGUMENT in "$@"
do
  KEY=$(echo $ARGUMENT | cut -f1 -d=)
  VALUE=$(echo $ARGUMENT | cut -f2 -d=)

  case "$KEY" in
    DOCKER_TAG)         DOCKER_TAG=${VALUE} ;;
    VERSION_HELM)       VERSION_HELM=${VALUE} ;;
    VERSION_KUBECTL)    VERSION_KUBECTL=${VALUE} ;;
    VERSION_TERRAFORM)  VERSION_TERRAFORM=${VALUE} ;;
    VERSION_CIRCLECICLI)  VERSION_CIRCLECICLI=${VALUE} ;;
    *)
  esac
done

if [[ -z $DOCKER_TAG ]] || [[ -z $VERSION_KUBECTL ]] || [[ -z $VERSION_TERRAFORM ]] || [[ -z $VERSION_HELM ]] || [[ -z $VERSION_CIRCLECICLI ]]
then
  echo "Error: Build missing version arguments!"
  exit 2
else
  docker pull alpine:latest
  docker pull google/cloud-sdk:alpine

  docker build . \
    --tag docker.pkg.github.com/bulderbank/cloud-cli-tools/cli-tools:latest \
    --tag docker.pkg.github.com/bulderbank/cloud-cli-tools/cli-tools:$DOCKER_TAG \
    --build-arg VERSION_GCLOUD=google/cloud-sdk:alpine \
    --build-arg VERSION_ALPINE=alpine:latest \
    --build-arg VERSION_HELM=$VERSION_HELM \
    --build-arg VERSION_KUBECTL=$VERSION_KUBECTL \
    --build-arg VERSION_TERRAFORM=$VERSION_TERRAFORM \
    --build-arg VERSION_CIRCLECICLI=$VERSION_CIRCLECICLI
fi
