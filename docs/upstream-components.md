# Upstream components and source provenance

This portfolio repository does not copy the upstream Fineract or Mifos application source trees.

- Apache Fineract source: https://github.com/apache/fineract (Apache License 2.0)
- Mifos X web application: https://github.com/openMF/web-app (Mozilla Public License 2.0)
- Mifos X project information: https://mifos.org/mifos-x/

## Verified historical source references

The original VM's Fineract checkout was at commit `54ac8de1f76694cb4d917f7b88f18100dca2d904`, described as `1.14.0-742-g54ac8de1f`. That checkout's Gradle wrapper was 8.14.3, and its README specified Java 21 or later.

The Mifos web-app checkout was at commit `4f5be2d5040e37ae26adef023c610028cbf34343`, described as `v1.0.0-fineract1.14-563-g4f5be2d50`; its package version was 1.0.0 and its licence was MPL-2.0. This identifies the frontend source line as intended for Fineract 1.14.

See [Build and source provenance](build-provenance.md) for the source SHA values, archive fingerprint and the distinction between the VM checkout and the later Kubernetes image build.

## Frontend distribution review

The static frontend archive supplied from the VM was reviewed. It contains the expected static Mifos distribution, including `index.html`, `assets/env.template.js`, application bundles and supporting assets. It did not include the generated `assets/env.js`.

The archive review found the expected Mifos MPL notice in the template and the bundled TinyMCE licence and notice files. The upstream MPL-2.0 licence text is retained in `frontend/LICENSE`. This preserves source/licence attribution; it does not replace a complete third-party licence review before public release.

The 468 static files have not yet been added to this GitHub branch because binary assets cannot be transferred through the available GitHub text-file operation. The `frontend/` directory is still a placeholder; the reviewed archive remains the source for the import step.

## Build provenance caution

The Fineract 1.14 VM source reference above must not be assumed to be the exact source used for the later Kubernetes API image. The later image-build logs record a different build line and a Java 25 / Gradle 9.7.1 toolchain. Its exact Git commit still needs to be read from the successful Bitbucket pipeline checkout or image metadata.

The Fineract image build script therefore continues to require an explicit `FINERACT_SOURCE_REF`; do not use a moving branch or silently substitute the VM commit for the Kubernetes image source.

## Security note on frontend environment variables

The Mifos runtime template includes fields named `MIFOS_REMITTANCE_API_CLIENT_KEY` and `EXTERNAL_NATIONAL_ID_SYSTEM_API_KEY`. The frontend reads these values from browser-visible `window.env`. Never inject confidential server-side API keys into those properties. They remain blank in the sanitised container defaults; the optional integrations are disabled by default. Use a backend proxy for integrations that require confidential credentials.
