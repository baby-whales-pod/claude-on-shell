#!/bin/bash
: <<'COMMENT'
# Build script for sbx-bill sandbox
> Usage:
1. Update the version in config.env
2. Run this script: ./build.sh
COMMENT

set -o allexport; source config.env; set +o allexport

#docker buildx build --platform linux/amd64,linux/arm64 -t ${DOCKER_HANDLE}/${NAME}:${TAG} --push .
docker buildx build --platform linux/arm64 -t ${DOCKER_HANDLE}/${NAME}:${TAG} --push .
