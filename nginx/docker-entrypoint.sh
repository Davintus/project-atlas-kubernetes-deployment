#!/bin/sh
set -eu
TEMPLATE="/usr/share/nginx/html/assets/env.template.js"
OUTPUT="/usr/share/nginx/html/assets/env.js"
if [ -f "$TEMPLATE" ]; then
  : "\${FINERACT_API_URL:=https://fineract.example.invalid}"
  : "\${FINERACT_API_URLS:=$FINERACT_API_URL}"
  : "\${FINERACT_API_PROVIDER:=/fineract-provider/api}"
  : "\${FINERACT_API_VERSION:=/v1}"
  : "\${FINERACT_API_ACTUATOR:=/fineract-provider}"
  : "\${FINERACT_DEFAULT_TENANT:=default}"
  export FINERACT_API_URL FINERACT_API_URLS FINERACT_API_PROVIDER
  export FINERACT_API_VERSION FINERACT_API_ACTUATOR FINERACT_DEFAULT_TENANT
  envsubst '\${FINERACT_API_URL} \${FINERACT_API_URLS} \${FINERACT_API_PROVIDER} \${FINERACT_API_VERSION} \${FINERACT_API_ACTUATOR} \${FINERACT_DEFAULT_TENANT}' \
    < "$TEMPLATE" > "$OUTPUT"
fi
