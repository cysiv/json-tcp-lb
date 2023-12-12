#!/bin/bash

set -e

BRANCH_TAG=$(echo "${BRANCH_NAME}" | tr "/" "_")

tags=""
build_args=""
docker_file_arg=""

for project in $PROJECTS; do
  for image in $IMAGES; do
    tags="$tags -t gcr.io/${project}/${image}:${SHORT_SHA} -t gcr.io/${project}/${image}:${BRANCH_TAG} \
      -t us-docker.pkg.dev/${project}/gcr.io/${image}:${BRANCH_TAG} -t  us-docker.pkg.dev/${project}/gcr.io/${image}:${SHORT_SHA}"
  done
done  

if [ ! -z "$ARGUMENTS" ]; then
  build_args="--build-arg $ARGUMENTS"
fi

if [ ! -z "$DOCKER_FILE" ]; then
  docker_file_arg="--file=$DOCKER_FILE"
fi

docker build $tags $build_args $DOCKER_DIR $docker_file_arg

exit $?
