#!/bin/sh
set -eu

TEMPLATE="/usr/share/nginx/html/assets/env.template.js"
OUTPUT="/usr/share/nginx/html/assets/env.js"

if [ ! -s "$TEMPLATE" ]; then
  echo "ERROR: Mifos runtime environment template is missing: $TEMPLATE" >&2
  exit 1
fi

command -v envsubst >/dev/null 2>&1 || {
  echo "ERROR: envsubst is required to generate the Mifos runtime configuration." >&2
  exit 1
}

# Export only documented runtime settings. Empty defaults are deliberate:
# optional integrations stay disabled unless explicitly configured.
set -a

: "${FINERACT_API_URL:=https://fineract.example.invalid}"
: "${FINERACT_API_URLS:=$FINERACT_API_URL}"
: "${FINERACT_API_PROVIDER:=/fineract-provider/api}"
: "${FINERACT_API_VERSION:=/v1}"
: "${FINERACT_API_ACTUATOR:=/fineract-provider}"
: "${FINERACT_PLATFORM_TENANT_IDENTIFIER:=default}"
: "${FINERACT_PLATFORM_TENANTS_IDENTIFIER:=$FINERACT_PLATFORM_TENANT_IDENTIFIER}"

: "${TENANT_LOGO_URL:=}"
: "${TENANT_LOGO_URL_DARK:=}"
: "${MIFOS_DEFAULT_LANGUAGE:=en-US}"
: "${MIFOS_SUPPORTED_LANGUAGES:=$MIFOS_DEFAULT_LANGUAGE}"
: "${MIFOS_DEFAULT_FORMAT_DATE:=}"
: "${MIFOS_DEFAULT_FORMAT_DATETIME:=}"
: "${MIFOS_PRELOAD_CLIENTS:=false}"
: "${MIFOS_DEFAULT_CHAR_DELIMITER:=,}"
: "${MIFOS_ALLOW_SERVER_SWITCH_SELECTOR:=false}"
: "${MIFOS_DISPLAY_BACKEND_INFO:=false}"
: "${MIFOS_PRODUCTION_MODE:=true}"
: "${MIFOS_DISPLAY_TENANT_SELECTOR:=false}"
: "${MIFOS_DOCUMENTATION_BASE_URL:=}"
: "${MIFOS_WAIT_TIME_FOR_NOTIFICATIONS:=60}"
: "${MIFOS_WAIT_TIME_FOR_CATCHUP:=30}"
: "${MIFOS_SESSION_IDLE_TIMEOUT:=300000}"
: "${MIFOS_OAUTH_SERVER_ENABLED:=false}"
: "${MIFOS_OAUTH_SERVER_URL:=}"
: "${MIFOS_OAUTH_SERVER_LOGOUT_URL:=}"
: "${MIFOS_OAUTH_CLIENT_ID:=}"
: "${MIFOS_OAUTH_AUTHORIZE_URL:=}"
: "${MIFOS_OAUTH_TOKEN_URL:=}"
: "${MIFOS_OAUTH_REDIRECT_URI:=}"
: "${MIFOS_OAUTH_SCOPE:=}"
: "${MIFOS_MIN_PASSWORD_LENGTH:=}"
: "${MIFOS_HTTP_CACHE_ENABLED:=true}"
: "${MIFOS_COMPLIANCE_HIDE_CLIENT_DATA:=false}"
: "${MIFOS_INTERBANK_TRANSFERS_API_URL:=}"
: "${MIFOS_INTERBANK_TRANSFERS_API_PROVIDER:=}"
: "${MIFOS_INTERBANK_TRANSFERS_API_VERSION:=}"
: "${MIFOS_INTERBANK_TRANSFERS_ENABLED:=false}"
: "${MIFOS_REMITTANCE_API_CLIENT_URL:=}"
: "${MIFOS_REMITTANCE_API_PROVIDER:=}"
: "${MIFOS_REMITTANCE_API_VERSION:=}"
: "${MIFOS_REMITTANCE_ENABLED:=false}"
: "${MIFOS_REMITTANCE_API_CLIENT_HEADER:=}"
: "${MIFOS_PRODUCTION_MODE_ENABLE_RBAC:=false}"
: "${ENABLE_EXTERNAL_NATIONAL_ID_SYSTEM:=false}"
: "${EXTERNAL_NATIONAL_ID_SYSTEM_URL:=}"
: "${EXTERNAL_NATIONAL_ID_SYSTEM_API_HEADER:=}"
: "${EXTERNAL_NATIONAL_ID_REGEX:=}"
: "${FINERACT_PLUGIN_OIDC_ENABLED:=false}"
: "${FINERACT_PLUGIN_OIDC_BASE_URL:=}"
: "${FINERACT_PLUGIN_OIDC_CLIENT_ID:=}"
: "${FINERACT_PLUGIN_OIDC_API_URL:=}"
: "${FINERACT_PLUGIN_OIDC_FRONTEND_URL:=}"

# These two fields are copied into window.env by the frontend bundle.
# Never inject confidential API keys into browser-delivered JavaScript.
MIFOS_REMITTANCE_API_CLIENT_KEY=""
EXTERNAL_NATIONAL_ID_SYSTEM_API_KEY=""

set +a

mkdir -p "$(dirname "$OUTPUT")"
TMP_OUTPUT="${OUTPUT}.tmp"
trap 'rm -f "$TMP_OUTPUT"' EXIT

# The template contains only Mifos environment placeholders. Unset variables
# therefore resolve to the safe defaults above or empty strings.
envsubst < "$TEMPLATE" > "$TMP_OUTPUT"

if grep -Eq '\$[A-Z][A-Z0-9_]*' "$TMP_OUTPUT"; then
  echo "ERROR: unresolved environment placeholders remain in generated env.js." >&2
  exit 1
fi

chmod 0644 "$TMP_OUTPUT"
mv "$TMP_OUTPUT" "$OUTPUT"
trap - EXIT

echo "Mifos frontend runtime configuration generated."
