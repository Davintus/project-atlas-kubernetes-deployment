#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE_NAME="${MIFOS_IMAGE_NAME:-mifos-web}"
IMAGE_TAG="${MIFOS_IMAGE_TAG:-local}"
IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

bash scripts/validate-mifos-frontend.sh frontend
sh -n nginx/docker-entrypoint.sh

docker build --pull -f Dockerfile.mifos -t "$IMAGE" .
docker image inspect "$IMAGE" >/dev/null

echo "SUCCESS: built $IMAGE"
