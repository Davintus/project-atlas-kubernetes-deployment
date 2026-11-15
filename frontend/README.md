# Mifos frontend distribution

The historical Mifos static frontend distribution is committed in this directory on the private `docs/sanitised-project-baseline` branch (import commit `b9c0891`).

## Upstream source provenance

- Repository: https://github.com/openMF/web-app
- Commit: `4f5be2d5040e37ae26adef023c610028cbf34343`
- `git describe`: `v1.0.0-fineract1.14-563-g4f5be2d50`
- Package version: `1.0.0`
- Licence: MPL-2.0

The reviewed archive contained 406 regular files across 468 archive entries (approximately 34.6 MB uncompressed), including `index.html` and `assets/env.template.js`. The generated `assets/env.js` was absent. The bundled TinyMCE licence and notice files are retained. The archive SHA-256 is recorded in [build provenance](../docs/build-provenance.md).

## Build the frontend image

From the repository root:

~~~bash
bash scripts/validate-mifos-frontend.sh frontend
bash scripts/build-mifos-image.sh
~~~

The build script validates the imported distribution, checks the NGINX entrypoint syntax, and builds the local image. The generated `frontend/assets/env.js` must not be committed; it is created in the container at startup from `assets/env.template.js`.

## Runtime configuration security

The frontend template includes browser-visible properties for optional integrations. Any value written to `env.js` is delivered to the browser and is visible to users. The container entrypoint deliberately forces the two optional API-key fields to empty and keeps those integrations disabled by default. **Do not configure confidential API keys in frontend environment variables.** Use an approved trusted backend proxy for integrations requiring confidential keys.

## Compatibility and release status

This frontend source line is tagged for Fineract 1.14, while the later Kubernetes API image was built from a Fineract 1.16.1-derived source revision. The actual application integration test must verify compatibility; do not assume version alignment.

The files have been imported into a private portfolio branch after a targeted archive review. This does not constitute a complete security audit, legal approval or permission to redistribute the bundle publicly. Keep the repository private until third-party licence, disclosure and permission reviews are complete.
