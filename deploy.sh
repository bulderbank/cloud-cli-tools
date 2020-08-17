#!/bin/sh
if [ -f versions ]; then
  export $(grep -v '^#' versions | xargs)

  ./build.sh \
    DOCKER_TAG=$DOCKER_TAG \
    VERSION_HELM=$VERSION_HELM \
    VERSION_KUBECTL=$VERSION_KUBECTL \
    VERSION_TERRAFORM=$VERSION_TERRAFORM
else
  echo "Error: Could not find the versions file!"
  exit 2
fi
