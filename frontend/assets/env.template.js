/**
 * Copyright since 2025 Mifos Initiative
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

(function (window) {
  window['env'] = window['env'] || {};

  // BackEnd Environment variables
  window['env']['fineractApiUrls'] = '$FINERACT_API_URLS';
  window['env']['fineractApiUrl'] = '$FINERACT_API_URL';
  window['env']['apiProvider'] = '$FINERACT_API_PROVIDER';
  window['env']['apiVersion'] = '$FINERACT_API_VERSION';
  window['env']['apiActuator'] = '$FINERACT_API_ACTUATOR';
  window['env']['fineractPlatformTenantId'] = '$FINERACT_PLATFORM_TENANT_IDENTIFIER';
  window['env']['fineractPlatformTenantIds'] = '$FINERACT_PLATFORM_TENANTS_IDENTIFIER';

  window['env']['tenantLogoUrl'] = '$TENANT_LOGO_URL';
  window['env']['tenantLogoUrlDark'] = '$TENANT_LOGO_URL_DARK';

  // Language Environment variables
  window['env']['defaultLanguage'] = '$MIFOS_DEFAULT_LANGUAGE';
  window['env']['supportedLanguages'] = '$MIFOS_SUPPORTED_LANGUAGES';
  window['env']['defaultFormatDate'] = '$MIFOS_DEFAULT_FORMAT_DATE';
  window['env']['defaultFormatDatetime'] = '$MIFOS_DEFAULT_FORMAT_DATETIME';
  window['env']['preloadClients'] = '$MIFOS_PRELOAD_CLIENTS';
  window['env']['defaultCharDelimiter'] = '$MIFOS_DEFAULT_CHAR_DELIMITER';
  window['env']['allowServerSwitch'] = '$MIFOS_ALLOW_SERVER_SWITCH_SELECTOR';
  window['env']['displayBackEndInfo'] = '$MIFOS_DISPLAY_BACKEND_INFO';
  window['env']['productionMode'] = '$MIFOS_PRODUCTION_MODE';
  window['env']['displayTenantSelector'] = '$MIFOS_DISPLAY_TENANT_SELECTOR';
  window['env']['documentationBaseUrl'] = '$MIFOS_DOCUMENTATION_BASE_URL';

  // Time settings
  window['env']['waitTimeForNotifications'] = '$MIFOS_WAIT_TIME_FOR_NOTIFICATIONS';
  window['env']['waitTimeForCOBCatchUp'] = '$MIFOS_WAIT_TIME_FOR_CATCHUP';
  window['env']['sessionIdleTimeout'] = '$MIFOS_SESSION_IDLE_TIMEOUT';

  // OAuth settings
  window['env']['oauthServerEnabled'] = '$MIFOS_OAUTH_SERVER_ENABLED';
  window['env']['oauthServerUrl'] = '$MIFOS_OAUTH_SERVER_URL';
  window['env']['oauthServerLogoutUrl'] = '$MIFOS_OAUTH_SERVER_LOGOUT_URL';
  window['env']['oauthAppId'] = '$MIFOS_OAUTH_CLIENT_ID';
  window['env']['oauthAuthorizeUrl'] = '$MIFOS_OAUTH_AUTHORIZE_URL';
  window['env']['oauthTokenUrl'] = '$MIFOS_OAUTH_TOKEN_URL';
  window['env']['oauthRedirectUri'] = '$MIFOS_OAUTH_REDIRECT_URI';
  window['env']['oauthScope'] = '$MIFOS_OAUTH_SCOPE';

  window['env']['minPasswordLength'] = '$MIFOS_MIN_PASSWORD_LENGTH';
  window['env']['httpCacheEnabled'] = '$MIFOS_HTTP_CACHE_ENABLED';
  window['env']['complianceHideClientData'] = '$MIFOS_COMPLIANCE_HIDE_CLIENT_DATA';

  // Interbank transfers
  window['env']['mifosInterbankTransfersApiUrl'] = '$MIFOS_INTERBANK_TRANSFERS_API_URL';
  window['env']['mifosInterbankTransfersApiProvider'] = '$MIFOS_INTERBANK_TRANSFERS_API_PROVIDER';
  window['env']['mifosInterbankTransfersApiVersion'] = '$MIFOS_INTERBANK_TRANSFERS_API_VERSION';
  window['env']['mifosInterbankTransfersEnabled'] = '$MIFOS_INTERBANK_TRANSFERS_ENABLED';

  // Remittance integration
  window['env']['mifosRemittanceApiClientUrl'] = '$MIFOS_REMITTANCE_API_CLIENT_URL';
  window['env']['mifosRemittanceApiProvider'] = '$MIFOS_REMITTANCE_API_PROVIDER';
  window['env']['mifosRemittanceApiVersion'] = '$MIFOS_REMITTANCE_API_VERSION';
  window['env']['mifosRemittanceEnabled'] = '$MIFOS_REMITTANCE_ENABLED';
  window['env']['mifosRemittanceApiClientHeader'] = '$MIFOS_REMITTANCE_API_CLIENT_HEADER';

  // Browser-delivered configuration must never contain confidential API keys.
  // The container entrypoint forces this optional field to an empty string.
  window['env']['mifosRemittanceApiClientKey'] = '$MIFOS_REMITTANCE_API_CLIENT_KEY';

  // Enable role-based access control for menu/button permissions
  window['env']['productionModeEnableRBAC'] = '$MIFOS_PRODUCTION_MODE_ENABLE_RBAC';

  // External National ID integration
  window['env']['enableExternalNationalIdSystem'] = '$ENABLE_EXTERNAL_NATIONAL_ID_SYSTEM';
  window['env']['externalNationalIdSystemUrl'] = '$EXTERNAL_NATIONAL_ID_SYSTEM_URL';
  window['env']['externalNationalIdSystemApiHeader'] = '$EXTERNAL_NATIONAL_ID_SYSTEM_API_HEADER';
  // This value is browser-visible. Keep it empty and use an approved backend proxy for secrets.
  window['env']['externalNationalIdSystemApiKey'] = '$EXTERNAL_NATIONAL_ID_SYSTEM_API_KEY';
  window['env']['externalNationalIdRegex'] = '$EXTERNAL_NATIONAL_ID_REGEX';

  // OIDC plugin settings
  window['env']['oidcServerEnabled'] = '$FINERACT_PLUGIN_OIDC_ENABLED';
  window['env']['oidcBaseUrl'] = '$FINERACT_PLUGIN_OIDC_BASE_URL';
  window['env']['oidcClientId'] = '$FINERACT_PLUGIN_OIDC_CLIENT_ID';
  window['env']['oidcApiUrl'] = '$FINERACT_PLUGIN_OIDC_API_URL';
  window['env']['oidcFrontUrl'] = '$FINERACT_PLUGIN_OIDC_FRONTEND_URL';
})(this);
