# Project Atlas public-release assessment

**Current decision: keep the repository private. Public release is not cleared.** Technical checks and the real-image VM integration evidence are substantially complete, but the review has identified a material GPL/MPL distribution choice, third-party asset attribution requirements, an untriaged historical Gitleaks finding, and permissions that cannot be established from repository evidence.

This document records verified source/configuration facts separately from decisions and approvals that must come from the project owner, rights-holders or qualified legal reviewers. It is a technical release assessment, not legal advice.

## 1. Executive assessment

| Area | Verified result | Public-release status |
|---|---|---|
| Real Fineract/Mifos integration | Real local images ran on the project VM against disposable MariaDB. Fineract health and authenticated offices API requests passed; the Mifos reverse proxy also passed an authenticated offices request. | Technical evidence available. Browser login, broad API/UI compatibility and production readiness are not established. |
| Kubernetes/Kustomize/Helm checks | Kustomize overlays render; Helm lint/template checks pass. A Kind fixture workflow has passed install, Service check, upgrade and rollback in prior runs. | Technical checks available. Fixture testing is not a real application Helm install. |
| Mifos frontend container | Tracked template, static distribution validation, Docker image build and HTTP/runtime smoke checks pass. | Technical checks available. |
| TinyMCE 8.3.2 | Pinned Mifos source uses `licenseKey="gpl"`. | Commercial TinyMCE key is not the selected route; GPLv2-or-later compliance and source/notice obligations remain. |
| lightGallery 2.9.0 | Pinned lockfile declares GPLv3; pinned Mifos source imports it in document and identity galleries and imports its SCSS. | **Material licensing gate:** choose and document a compliant GPLv3/MPL-2.0 distribution route, or obtain the appropriate lightGallery commercial licence / remove or replace the library. |
| Font Awesome Free 6.7.2 | Bundled assets include Font Awesome font files; package licences divide icon artwork, fonts and code among CC BY 4.0, OFL 1.1 and MIT. Versioned licence file is now included. | Attribution/notice retention and brand-icon trademark review still required. |
| Dependency inventory | A provisional CycloneDX 1.6 SBOM covers 1,763 npm lockfile entries. | Does not inventory all static assets, logos, fonts, images, container OS packages or copyright ownership. |
| Git history secrets | Gitleaks scanned all fetched refs/history and found one historical candidate; the current-commit/change-range scans reported no leak. | **Blocking:** candidate must be identified and triaged. Do not call the scan clean yet. |
| Customer/employer disclosure | No signed publication approval is recorded in the repository material reviewed. | **Blocking:** obtain written permission or remove/rework material that cannot be cleared. |
| Trademarks/branding | Mifos marks and logos are present in the frontend distribution. | **Blocking:** separate permission or a reviewed replacement/removal plan is required. |
| Project Atlas-authored files | No root repository licence is declared. | Choose the terms for original files without purporting to relicense third-party materials. |

## 2. Verified licensing findings

### 2.1 TinyMCE: GPLv2-or-later is the configured route

The Mifos source revision `openMF/web-app@4f5be2d5040e37ae26adef023c610028cbf34343` contains the editor declaration in:

`src/app/templates/create-edit-template/create-edit-template.component.html`

It explicitly sets:

```html
licenseKey="gpl"
```

The same source lockfile resolves:
- `tinymce@8.3.2`, whose package metadata says `SEE LICENSE IN license.md`;
- `@tinymce/tinymce-angular@9.1.1`, MIT.

The vendored TinyMCE `license.md` presents GPL version 2 or later as an available route and also describes a commercial self-hosted route. Tiny's official documentation confirms that `gpl` declares GPLv2+; a `T8LK:` key is the commercial self-hosted path. The pinned Mifos source selects the GPL route, so a commercial TinyMCE key is not the default requirement indicated by this code. See [TinyMCE licence-key documentation](https://www.tiny.cloud/docs/tinymce/latest/license-key/).

**Remaining action:** preserve the TinyMCE licence text and notices (now included under `frontend/third-party-licenses/`), and ensure the distributed frontend's GPLv2-or-later corresponding-source and notice obligations are satisfied. Do not add a fabricated commercial TinyMCE key.

### 2.2 lightGallery: the main open-source compatibility gate

The pinned Mifos `package-lock.json` resolves `lightgallery@2.9.0` and declares `GPLv3`. This is not merely a dev dependency:
- `src/app/shared/tabs/entity-documents-tab/entity-documents-tab.component.ts` imports `lightgallery` and its plugins.
- `src/app/clients/clients-view/identities-tab/identities-tab.component.ts` imports `lightgallery` and its plugins.
- `src/main.scss` imports lightGallery styles.

The full upstream `2.9.0/LICENSE` has been added at `frontend/third-party-licenses/lightGallery-2.9.0-LICENSE.txt`. The vendor describes GPLv3 as its open-source licence for applications distributed under GPLv3-compatible terms; it offers a commercial licence for proprietary applications. See the [lightGallery licence terms](https://www.lightgalleryjs.com/docs/license/) and [GPLv3 distribution conditions](https://www.gnu.org/licenses/gpl-3.0.html).

The Mifos web application itself declares MPL-2.0. Mozilla's MPL 2.0 Section 3.3 allows an MPL-covered work to be combined into a Larger Work governed by a secondary licence such as GPL, provided the covered software is not marked incompatible with secondary licences and the distributor additionally makes the MPL-covered source available under the secondary licence while preserving recipients' MPL rights. Mozilla explains the three conditions in its [MPL 2.0 FAQ](https://www.mozilla.org/en-US/MPL/2.0/FAQ/) and [MPL/GPL combination guidance](https://www.mozilla.org/en-US/MPL/2.0/combining-mpl-and-gpl/).

This means the Mifos/lightGallery combination is not automatically prohibited, and it does not automatically require buying lightGallery's commercial licence. However, public redistribution needs a deliberate, reviewed route:

**Route A — open-source distribution:** use the MPL 2.0 Section 3.3 Larger Work route, provide the Mifos covered source in the form required by GPLv3 as well as preserving MPL rights, provide complete corresponding source for the distributed frontend, preserve all notices, and verify there is no relevant MPL incompatibility notice. This should be approved by qualified legal review before release.

**Route B — proprietary distribution:** obtain a lightGallery commercial licence that covers the intended organisation/product/deployment and the bundled version, or remove/replace lightGallery. A commercial lightGallery licence does not itself settle Mifos MPL obligations or third-party marks.

**Current state:** the repository contains the license text and a provisional package SBOM, but does not yet document a signed decision for Route A or evidence of a commercial lightGallery licence. This is a material release blocker.

### 2.3 Font Awesome Free: separate licences apply to different asset classes

The pinned source lockfile resolves Font Awesome Free 6.7.2 packages. The static bundle contains Font Awesome web/desktop font files under `frontend/media/`.

The official versioned Font Awesome licence explains:
- SVG/JavaScript icon artwork: CC BY 4.0;
- web and desktop font files: SIL Open Font License 1.1;
- other code: MIT.

The full upstream `LICENSE.txt` for version 6.7.2 is now included at `frontend/third-party-licenses/Font-Awesome-Free-6.7.2-LICENSE.txt`. Preserve embedded attribution and the full licence text. Brand icons are trademarks of their respective owners and must only represent those brands; they are not endorsements. See [Font Awesome's licence](https://github.com/FortAwesome/Font-Awesome/blob/6.7.2/LICENSE.txt).

### 2.4 Other frontend notices and the provisional SBOM

The bundled TinyMCE notice file identifies:
- DOMPurify 3.2.6 — MPL-2.0 OR Apache-2.0;
- PrismJS 1.25.0 — MIT;
- Prism Themes 1.9.0 — MIT.

A CycloneDX 1.6 SBOM has been created from the pinned Mifos source lockfile:
- 1,763 npm package entries;
- 387 entries not marked development-only, 1,376 marked dev-only;
- 131 marked optional (overlap is possible);
- all package-lock entries have integrity hashes.

Two package entries with no licence field in the lockfile (`exit@0.1.2` and `svg-tags@1.0.0`) were manually checked against upstream MIT licence evidence and enriched in the SBOM. The SBOM preserves raw licence expressions and is documented in [docs/sbom/README.md](sbom/README.md).

**Limit:** this SBOM covers npm lockfile entries, not the full 409-file static frontend distribution, standalone images/logos, all font files, copied build artefacts, the final NGINX base image/OS packages, or all copyright owners. A separate asset-level review remains required.

### 2.5 Repository-level licence for original Project Atlas material

The GitHub repository currently has no repository-level licence selected, and no root `LICENSE` file. That means third parties do not have a clear licence grant for the original Project Atlas scripts, Kubernetes manifests, CI workflows and documentation.

Choose a licence for those original files only after defining the scope and excluding upstream/third-party files. Do not add a blanket root licence that appears to relicense the Mifos frontend, TinyMCE, lightGallery, Font Awesome or other bundled material.

## 3. Branding, trademarks and written disclosure permission

### 3.1 Mifos and other marks

The frontend distribution contains Mifos-branded logo/image assets, including:
- `frontend/assets/images/MifosX_logo.png`;
- `frontend/assets/images/MifosX_logoSmall.png`;
- `frontend/assets/images/mifos-logo-flat.png`;
- `frontend/assets/images/mifos_lg-logo.jpg`;
- `frontend/assets/images/white-mifos.png` and `frontend/media/white-mifos.png`.

The Mifos software licence does not by itself grant trademark/logo rights. Mifos Initiative's legal information identifies its Mifos marks and IP as separately controlled. Apache 2.0 likewise does not grant general trademark rights. See [Mifos legal information](https://mifos.org/about-us/financial-legal/) and [Apache License 2.0, section 6](https://www.apache.org/licenses/LICENSE-2.0.html).

**Required decision:** obtain written permission/brand guidance from the relevant owner for the specific portfolio publication, or remove/replace the branded artwork and present the case study as a third-party deployment using descriptive attribution only. Review Font Awesome brand icons separately.

### 3.2 Customer, employer and vendor disclosure

The repository contains a technical narrative derived from work in a separate environment. The repository review did not locate a signed publication permission from the customer/employer/vendor rights-holder. That permission cannot be inferred from technical sanitisation or from having access to the original environment.

Before release, obtain written approval that specifically covers:
- the project narrative and deployment architecture;
- any work product, configuration patterns, screenshots/log extracts or diagrams derived from the engagement;
- the use of company/customer/vendor names or marks, if any;
- the fact that the project was built and operated in the described environment.

If permission cannot be obtained, remove or rewrite the material to an independently authored generic technical exercise and exclude any employer/customer-owned code or confidential facts.

## 4. Secret and Git history scan

A new Gitleaks workflow was added. It checks the current push/PR change range and separately scans the commit history reachable from all branches and tags fetched by `actions/checkout` with `fetch-depth: 0`.

The first all-refs scan found **one historical secret-pattern candidate across 146 commits / approximately 28.4 MB**. The current-commit and PR change-range scan reported no findings, but that does not clear the older repository history. The candidate has not yet been confirmed as a real credential or a false positive.

**Required action:**
1. Identify the file, line, commit and Gitleaks rule from the redacted workflow summary.
2. Inspect the candidate securely without copying its value into a ticket, comment or chat.
3. If it is a real or possibly live credential, rotate/revoke it with its owner and remove it from all reachable refs through an approved history rewrite before public release.
4. If demonstrably synthetic or non-sensitive, record the reason and exact fingerprint in `.gitleaksignore`; do not suppress the whole rule or ignore an unreviewed hit.
5. Re-run the all-refs scan and ensure it passes after any history cleanup.
6. Separately perform manual checks for customer identifiers, private endpoints, sensitive architecture and personal data: secret scanners cannot detect every disclosure risk.

The workflow run status and redacted metadata are available from [GitHub Actions](https://github.com/Davintus/project-atlas-kubernetes-deployment/actions).

## 5. Required sign-offs before changing repository visibility

### Open-source licensing and attribution
- [ ] Approve a lightGallery/Mifos distribution route: MPL 2.0 Section 3.3 plus GPLv3-compatible Larger Work obligations and corresponding source, or a documented commercial lightGallery licence, or removal/replacement.
- [ ] Confirm TinyMCE is distributed under the selected GPLv2-or-later configuration and provide the required corresponding source and notices.
- [ ] Retain Font Awesome 6.7.2 licence and attribution files; complete the review of any brand/icon usage.
- [ ] Complete an asset-level licence inventory of the frontend distribution and built container, including fonts, logos, images and copied CSS/JS.
- [ ] Review the provisional npm SBOM, resolve any remaining `SEE LICENSE`/OR expressions and confirm the final dependency/source versions match the SBOM.
- [ ] Confirm Apache Fineract and Mifos notices/source links are complete for any material actually distributed.
- [ ] Select and document a licence for original Project Atlas-authored files without relicensing third-party material.

### Rights, branding and disclosure
- [ ] Obtain written permission from the customer/employer/vendor rights-holder for the portfolio narrative and all derived material, or remove material that cannot be cleared.
- [ ] Obtain Mifos Initiative permission/brand guidance for Mifos-branded logos/marks or remove/replace them.
- [ ] Review Font Awesome brand icons and any other third-party trademarks.
- [ ] Re-review every screenshot, log, diagram and example for direct or inferential disclosure.

### Repository security
- [ ] Triage the one historical Gitleaks candidate.
- [ ] Rotate/revoke and history-clean any real or possibly live credential; document false positives individually.
- [ ] Re-run the all-ref Gitleaks scan and obtain a clean result on the final release commit.
- [ ] Review every reachable branch, tag, commit, workflow, Actions log/artifact/cache, pull request metadata and any published release package.
- [ ] Check for customer data, internal hostnames/IPs, project IDs, service-account emails, secrets, generated `env.js`, database dumps, kubeconfigs and Terraform state.
- [ ] Record the final history-scan commit SHA and reviewer/date.

### Technical release verification
- [ ] Confirm latest Helm/Kustomize and Mifos frontend workflows pass on the exact final release commit.
- [ ] Confirm the Kind fixture install/upgrade/rollback check passes on the same PR/release commit; label it as a fixture test only.
- [ ] Confirm real VM app integration, Kustomize validation, Helm rendering, frontend container smoke test and fixture-based Kind validation remain separate evidence categories.
- [ ] Confirm README, CONTRIBUTING, deployment journey, SBOM, third-party notices and this checklist match the release contents.

## 6. Who can close each gate

The project owner can select the intended source distribution model and decide whether a public GPL-compatible release is appropriate. Qualified counsel or the relevant licence owner should confirm the MPL/GPL combination and any commercial agreement. Mifos Initiative and the customer/employer/vendor rights-holders must provide any needed brand or disclosure permission. Repository administrators must complete the security cleanup and approve the final visibility change.

Until the blocking items above are resolved and recorded, keep the repository private and the release PR in draft. The presence of a passing build or a licence file is not a substitute for these approvals.
