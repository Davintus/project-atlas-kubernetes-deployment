# Third-party notices for the Mifos frontend bundle

This directory accompanies the reviewed Mifos X web application distribution committed under `frontend/`. It is a dependency and attribution index for the versions identified in the pinned Mifos source lockfile; it is not a legal opinion or a complete asset-by-asset copyright audit.

## Mifos X web application

- Upstream: https://github.com/openMF/web-app
- Source revision: `4f5be2d5040e37ae26adef023c610028cbf34343`
- Package version: `1.0.0`
- Declared project licence: MPL-2.0
- Licence text: [../LICENSE](../LICENSE)
- Source and build provenance: [../../docs/build-provenance.md](../../docs/build-provenance.md)

The distribution retains Mifos source copyright/licence notices. Mifos names and logos are separately subject to trademark and permission review; MPL-2.0 is not a trademark grant.

## TinyMCE

- Package: `tinymce` version `8.3.2`
- Angular wrapper: `@tinymce/tinymce-angular` version `9.1.1` (MIT)
- Mifos component configuration at the pinned source revision explicitly sets `licenseKey="gpl"` in `src/app/templates/create-edit-template/create-edit-template.component.html`.
- TinyMCE package metadata points to `license.md`; the included vendor terms identify GPL version 2 or later as an option, or a commercial self-hosted licence.
- The Mifos source selects the GPLv2-or-later route. It does not select a commercial `T8LK:` key in this code path.
- Retained terms: [assets/tinymce/license.md](assets/tinymce/license.md)
- Full GPLv2 licence text: [GNU-GPL-2.0-or-later.txt](third-party-licenses/GNU-GPL-2.0-or-later.txt)

Any public redistribution under this route must comply with GPLv2-or-later, including providing the corresponding source and preserving notices. TinyMCE self-hosting documentation explains the GPL declaration and commercial alternative: https://www.tiny.cloud/docs/tinymce/latest/license-key/.

## lightGallery

- Package: `lightgallery` version `2.9.0`
- Declared licence in the pinned npm lockfile: GPLv3
- It is a runtime dependency and is used by the Mifos application for document and identity image galleries; its SCSS is also imported by the frontend stylesheet.
- Full upstream licence file from the v2.9.0 tag: [lightGallery-2.9.0-LICENSE.txt](third-party-licenses/lightGallery-2.9.0-LICENSE.txt)
- Upstream licence terms: https://www.lightgalleryjs.com/docs/license/

lightGallery's open-source route requires a project distributed under GPLv3-compatible terms. Its commercial licence is an alternative for a proprietary distribution. The Mifos web application is declared MPL-2.0; Mozilla MPL 2.0 Section 3.3 permits certain Larger Work combinations with GPL-licensed software, but the conditions must be followed, including additionally distributing the MPL-covered source under the secondary licence while preserving recipients' MPL rights. See https://www.mozilla.org/en-US/MPL/2.0/FAQ/ and https://www.mozilla.org/en-US/MPL/2.0/combining-mpl-and-gpl/.

**Release gate:** the project owner must choose and document a compliant distribution model for the combined Mifos/lightGallery work (including complete corresponding source and the MPL/GPL recipient options), or obtain and retain a commercial lightGallery licence that covers the intended redistribution. Do not assume that the presence of the upstream licence files alone resolves this.

## Font Awesome Free

- Packages in the pinned source lockfile: `@fortawesome/fontawesome-free`, `@fortawesome/free-solid-svg-icons`, `@fortawesome/free-brands-svg-icons` version `6.7.2`, plus the Angular/SVG integration packages.
- The bundle contains Font Awesome font files under `media/`.
- Font Awesome Free uses different licences for different asset classes:
  - SVG/JavaScript icon artwork: CC BY 4.0
  - Web and desktop font files: SIL Open Font License 1.1
  - Other code: MIT
- Full upstream licence and attribution terms: [Font-Awesome-Free-6.7.2-LICENSE.txt](third-party-licenses/Font-Awesome-Free-6.7.2-LICENSE.txt)
- Upstream: https://github.com/FortAwesome/Font-Awesome/tree/6.7.2

Brand icons depict third-party brands and remain subject to the relevant owners' trademark rights. Do not use them as endorsements or for unrelated purposes.

## Other notices identified in the supplied TinyMCE distribution

The bundled `assets/tinymce/notices.txt` identifies:

| Component | Version | Declared licence |
|---|---:|---|
| DOMPurify | 3.2.6 | MPL-2.0 OR Apache-2.0 |
| PrismJS | 1.25.0 | MIT |
| Prism Themes | 1.9.0 | MIT |

The complete bundled notice file is retained at [assets/tinymce/notices.txt](assets/tinymce/notices.txt).

## Additional lockfile observations

The pinned Mifos npm lockfile also records `rgbcolor@1.0.1` with `MIT OR SEE LICENSE IN FEEL-FREE.md`; the MIT option is an available path and the upstream package includes its licence materials. Two package entries did not declare a licence in the lockfile metadata (`exit@0.1.2` and `svg-tags@1.0.0)); their upstream package metadata/licence files were checked as MIT for the provisional SBOM. These individual checks do not replace a formal licence scan and review of the actual deployed asset contents.

## Important scope boundary

The accompanying [CycloneDX SBOM](../docs/sbom/mifos-web-app-1.0.0-package-lock.cdx.json) inventories the pinned npm lockfile packages. It does not automatically inventory separately copied fonts, logos, screenshots, images, generated assets, copied CSS or any assets not represented by npm package records. A complete release review must still reconcile the frontend file tree to its actual source packages and licence notices.
