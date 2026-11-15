# Mifos frontend dependency inventory

## Artifact

- File: [mifos-web-app-1.0.0-package-lock.cdx.json](mifos-web-app-1.0.0-package-lock.cdx.json)
- Format: CycloneDX 1.6 JSON
- Source repository: https://github.com/openMF/web-app
- Source revision: `4f5be2d5040e37ae26adef023c610028cbf34343`
- Source manifest: `package-lock.json` (lockfile version 3)
- Package count: 1,763 npm package entries beneath `node_modules/`
- Entry breakdown: 387 entries not marked `dev`, 1,376 marked development-only; 131 entries marked optional (overlap is possible)
- Every locked npm package entry has an integrity hash in the pinned lockfile.

The SBOM preserves raw declared licence expressions rather than silently converting every expression into a single SPDX identifier. It includes the package-lock path, package URL, source tarball URL and development/optional properties where supplied by the lockfile.

Two entries in the source lockfile did not contain a `license` field: `exit@0.1.2` and `svg-tags@1.0.0`. Their upstream MIT licence metadata/files were checked and manually recorded in the SBOM with evidence references. This is a manual enrichment, not an upstream lockfile change.

## Important components requiring explicit review

| Package | Version | Lockfile declaration | Why it matters |
|---|---:|---|---|
| `tinymce` | 8.3.2 | `SEE LICENSE IN license.md` | Mifos editor markup sets `licenseKey="gpl"`; vendor terms support GPLv2-or-later or commercial self-hosting. |
| `lightgallery` | 2.9.0 | `GPLv3` | Runtime dependency used in document/identity galleries and stylesheet imports. This is the main licence compatibility gate alongside the MPL-2.0 Mifos source. |
| `@fortawesome/fontawesome-free` | 6.7.2 | `CC-BY-4.0 AND OFL-1.1 AND MIT` | Contains icons and fonts under separate licences; notices/attribution must accompany copied assets. |
| `@fortawesome/free-brands-svg-icons` | 6.7.2 | `CC-BY-4.0 AND MIT` | Brand icons carry third-party trademark considerations in addition to copyright licensing. |
| `@tinymce/tinymce-angular` | 9.1.1 | MIT | Angular integration package; separate from the TinyMCE editor core. |

## Known metadata licence groups

The package-lock contains a broad collection of declared expressions, primarily MIT, ISC, Apache-2.0, BSD-2-Clause and BSD-3-Clause, with additional entries under BlueOak-1.0.0, CC-BY, OFL, CC0, Zlib, Unlicense, GPL, AFL and other expressions. The SBOM records these verbatim, including OR/AND expressions and references such as `SEE LICENSE IN ...`.

## What this SBOM does not prove

This is a **provisional npm dependency SBOM**, not a complete software and asset bill of materials and not a legal clearance. It does not fully cover:

- Fonts, images, icons, logos, screenshots and other media copied into the static frontend distribution.
- Licences for separately copied build artefacts or source files that no longer map one-to-one to npm package entries.
- The final Docker image's operating-system packages and NGINX/gettext base image.
- Copyright ownership, trademark permission or contractual rights to redistribute customer/employer/vendor material.
- Whether every corresponding-source, attribution, notice and offer-of-source obligation is satisfied.

Before public release, run an asset-level licence scanner/inventory against the complete frontend directory and built container, inspect the result manually, and get qualified review of the combined MPL-2.0/GPLv3 distribution route.
