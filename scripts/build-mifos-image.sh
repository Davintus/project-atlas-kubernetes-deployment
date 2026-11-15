#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE_NAME="\${MIFOS_IMAGE_NAME:-mifos-web}"
IMAGE_TAG="\${MIFOS_IMAGE_TAG:-local}"
IMAGE="\${IMAGE_NAME}:\${IMAGE_TAG}"

test -s frontend/index.html || {
  echo "frontend/index.html is missing. Import the reviewed Mifos web distribution into frontend/." >&2
  exit 1
}
test -s frontend/assets/env.template.js || {
  echo "frontend/assets/env.template.js is missing from the reviewed frontend distribution." >&2
  exit 1
}
if [ -f frontend/assets/env.js ]; then
  echo "Refusing to build with generated frontend/assets/env.js present. Remove it; the container entrypoint creates it at runtime." >&2
  exit 1
fi

sh -n nginx/docker-entrypoint.sh
docker build --pull -f Dockerfile.mifos -t "$IMAGE" .
docker image inspect "$IMAGE" >/dev/null

echo "SUCCESS: built $IMAGE"
