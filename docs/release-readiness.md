# Project Atlas release readiness

**Status: not approved for public release.** The repository is kept private while technical, licensing, permission and disclosure checks are completed. This document is a release gate, not a claim that the checks below have been approved.

## What is in scope

Project Atlas is an anonymised engineering case study. The repository combines original documentation and deployment scaffolding with third-party application material and evidence derived from a separate environment. A technically clean build does not itself grant permission to publish customer-derived details, third-party branding or bundled software.

The intended public release would include:
- the sanitised Fineract/Mifos deployment story and logical architecture;
- original scripts, Kubernetes manifests, Helm examples and documentation;
- the frontend distribution and its required notices, only if its complete redistribution conditions are confirmed;
- validation workflows and synthetic test fixtures.

## Current technical evidence

| Area | Evidence | Boundary |
|---|---|---|
| Real application integration | Real Fineract and Mifos images ran on the project VM against disposable MariaDB; health and authenticated offices API requests succeeded, including through the Mifos reverse proxy. | Interactive browser login was not verified. Broader API/UI version compatibility and production readiness are not established. |
| Kubernetes manifests | Kustomize development, staging and production overlays render in CI. | Rendering is not a cluster deployment. |
| Helm chart | Helm lint and template rendering passed; the Kind workflow installed the chart using BusyBox/NGINX fixtures and tested Service connectivity, upgrade and rollback. | The real Fineract/Mifos images were not installed through Helm. This is not planned for the current project scope. |
| Frontend container | A separate workflow validates the reviewed frontend files, builds the image and smoke-tests HTTP/runtime configuration. | This is not full interactive browser testing. Refer to the live Actions run status before release. |
| Sanitisation | The repository includes sanitisation guidance and example-only infrastructure configuration. | A complete history-wide secret and disclosure audit remains required. |

## Known third-party material requiring review

The following items are known from the repository's current provenance and retained notices. This is not a complete Software Bill of Materials (SBOM) or legal opinion.

| Component or material | Known notice / licence evidence | Release action |
|---|---|---|
| Apache Fineract | Apache License 2.0; built from a pinned upstream source revision by the build script. | Verify attribution and notice obligations for any distributed image or derived executable. Confirm the release does not include private upstream modifications. |
| Mifos web application | MPL-2.0 notice and `frontend/LICENSE` are retained; upstream repository and exact source commit are recorded. | Verify file-level notices and source-availability obligations for the bundled executable/static distribution. Confirm trademark and logo usage separately; the software licence does not by itself grant trademark rights. |
| TinyMCE | Bundled `frontend/assets/tinymce/license.md` presents GPL v2-or-later terms or Tiny's self-hosted/commercial terms. The bundled `notices.txt` also identifies DOMPurify (MPL-2.0 OR Apache-2.0), PrismJS (MIT) and Prism Themes (MIT). | **Blocking item:** determine and document the applicable TinyMCE licence for this distribution. If relying on GPL, verify that distribution and corresponding-source obligations are met; if relying on a commercial agreement, verify that the agreement covers this redistribution. Preserve the notices. |
| Other frontend dependencies and assets | The static bundle contains application libraries, fonts, icons and images beyond the notices above. | Generate and review a complete dependency/asset licence inventory (preferably an SBOM plus manual review of static assets); do not treat the TinyMCE notice file as exhaustive. |
| Project Atlas-authored material | No repository-wide licence has been selected or added. | Decide which original files, if any, can be licensed independently of third-party and customer-derived material. Do not add a root `LICENSE` file until the scope and compatibility of that choice have been reviewed. |

## Required sign-offs before changing the repository to public

### 1. Open-source licensing and attribution
- [ ] Produce a complete SBOM/licence inventory for application dependencies, bundled JavaScript, fonts, icons, images and other assets.
- [ ] Resolve TinyMCE 8.3.2's GPLv2+ versus commercial self-hosted licence position; inspect the Mifos configuration and ensure the self-hosted licence-key setup matches the selected terms. Retain evidence of GPL compliance or applicable commercial permission.
- [ ] Confirm Apache Fineract, Mifos/MPL-2.0, TinyMCE and other third-party notices are complete and placed where recipients can find them.
- [ ] Check source-code availability and corresponding-source obligations for any executable or bundled distribution.
- [ ] Decide the licence (if any) for original Project Atlas material without purporting to relicense third-party content.
- [ ] Review Mifos names, logos, marks and other branded imagery separately from copyright licensing.

### 2. Customer, employer and vendor disclosure
- [ ] Obtain written approval from the relevant rights-holder/organisation for publishing a case study derived from the work, including the technical narrative and architecture.
- [ ] Confirm no customer, bank, employer, vendor, tenant, account, environment or operational details are disclosed directly or by inference.
- [ ] Review all diagrams, screenshots, logs, command output and examples for identifiers and metadata.
- [ ] Confirm permission to publish any code or configuration created as part of employment, customer engagement or vendor work.
- [ ] Remove or replace any material whose ownership or disclosure rights cannot be established.

### 3. Repository and history security review
- [ ] Run secret scanning across every reachable commit, branch and tag, not only the current working tree.
- [ ] Review the full Git history for credentials, domains, IPs, project IDs, email addresses, resource names, hidden files and accidental customer artefacts.
- [ ] Review GitHub Actions workflows, logs, artifacts, caches, issue content and pull request metadata for disclosure.
- [ ] Rotate any credential that may have been exposed; removing a value in a later commit is not sufficient.
- [ ] Confirm generated runtime files (including `frontend/assets/env.js`), environment files, database dumps, kubeconfigs, Terraform state and private certificates are excluded.
- [ ] Record the final review commit SHA and the reviewers/sign-off date.

### 4. Release verification
- [ ] Confirm the README, deployment journey, contribution guide and this release-readiness document match the final branch contents.
- [ ] Confirm the Helm workflow and frontend workflow are green on the exact release commit.
- [ ] Confirm the Kind fixture test remains labelled as a fixture test, not a real application Helm deployment.
- [ ] Confirm the real-image VM integration evidence is described separately from Helm rendering and fixture testing.
- [ ] Review all links, example commands and references to the default branch.
- [ ] Obtain explicit approval from the repository owner before changing visibility to public.

## Who can close the remaining gates

Technical validation and documentation can be checked in this project. Licensing interpretation, commercial entitlement, customer/employer disclosure permission and trademark approval require confirmation from the relevant rights-holders and/or qualified legal reviewers. No such approval is inferred from the presence of an upstream licence file. See the [official MPL-2.0 text](https://www.mozilla.org/en-US/MPL/2.0/), the [Apache License 2.0 text](https://www.apache.org/licenses/LICENSE-2.0.html), and Tiny's [legal documents](https://www.tiny.cloud/legal/) and [licence-key documentation](https://www.tiny.cloud/docs/tinymce/latest/license-key/) as primary reference material; these references do not replace a review of the actual files, agreements and intended distribution.

Until all applicable boxes above are completed and recorded, keep the repository private. Existing collaborators with repository access can continue contributing under the safeguards in [CONTRIBUTING.md](../CONTRIBUTING.md).
