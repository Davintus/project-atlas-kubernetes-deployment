# Upstream components and source provenance

This portfolio repository does not copy the upstream Fineract or Mifos application source trees.

- Apache Fineract source: https://github.com/apache/fineract (Apache License 2.0)
- Mifos X web application: https://github.com/openMF/web-app (Mozilla Public License 2.0)
- Mifos X project information: https://mifos.org/mifos-x/

## Verified source references

The historical VM Fineract checkout was commit `54ac8de1f76694cb4d917f7b88f18100dca2d904`, described as `1.14.0-742-g54ac8de1f`. The later successful Kubernetes image build used Fineract commit `d63beed7ccfeadaffa0c7842b1011bc88451376f`, described in its build log as `1.16.1-383-gd63beed7cc`, with Temurin 25.0.5 and Gradle 9.7.1.

The Mifos web-app checkout was commit `4f5be2d5040e37ae26adef023c610028cbf34343`, described as `v1.0.0-fineract1.14-563-g4f5be2d50`; its package version was 1.0.0 and its licence was MPL-2.0. The frontend source line is therefore marked for Fineract 1.14, whereas the Kubernetes API build is from a later Fineract source line. Do not assume compatibility solely from the version labels: the real-application integration test must verify it.

See [Build and source provenance](build-provenance.md) for full SHA values, build details and the archive fingerprint.

## Frontend distribution review

The supplied static frontend archive contains the expected Mifos distribution, including `index.html`, `assets/env.template.js`, application bundles and supporting assets. It does not contain the generated `assets/env.js`. The source MPL-2.0 licence is retained in `frontend/LICENSE`, and the bundled TinyMCE licence and notice files are retained inside `frontend/assets/tinymce/`.

This preserves the identified project and bundled TinyMCE notices; it is not a complete third-party licensing review or legal approval for public release.

The reviewed static distribution is committed under `frontend/` in the sanitised portfolio branch. The runtime template `frontend/assets/env.template.js` was absent from the initial Git checkout even though it was present in the reviewed upstream archive and in the VM build context. It has now been restored in the release-review branch from the pinned Mifos web-app source revision, retaining its MPL-2.0 notice and adapting only the template content needed to keep optional browser-visible API-key values empty. The generated `frontend/assets/env.js` remains excluded from Git. The archive import and its fingerprint are documented in [build provenance](build-provenance.md).

## Security note on frontend environment variables

The Mifos runtime template includes browser-visible properties named `MIFOS_REMITTANCE_API_CLIENT_KEY` and `EXTERNAL_NATIONAL_ID_SYSTEM_API_KEY`. The frontend reads these values from `window.env`, meaning any populated value is visible to users. The sanitised NGINX entrypoint forces both values to empty and disables the optional integrations by default. Never inject a confidential server-side API key into browser runtime configuration; use a trusted backend proxy instead.
