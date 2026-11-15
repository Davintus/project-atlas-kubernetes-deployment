# Project Atlas — Fineract and Mifos on Kubernetes

**An anonymised cloud-native deployment case study.** This repository documents the engineering journey of taking Apache Fineract and its Mifos web interface from a VM-based baseline to an automated Kubernetes deployment.

> This is a portfolio reference, not the original production repository. Customer and organisation identifiers, production endpoints, IP addresses, internal hostnames, credentials, registry paths and account details are intentionally excluded.

## The journey

The first pipeline-led deployment ran into database bootstrap and tenant-upgrade failures. Rather than keep automating a system whose startup dependencies were not yet understood, I first deployed the applications on a standalone cloud VM with Docker Compose. That provided a working baseline and made it possible to inspect the database health dependency, application configuration and startup sequence.

When I returned to Kubernetes, the Fineract API pods exposed a tenant database upgrade failure. The logs showed that a stored tenant database password could not be decrypted with the configured master-password and encryption settings; the error also included an invalid Base64 character. I traced the failure through the tenant credential and encryption configuration, corrected the inconsistency, and restored application startup.

I then refined the delivery workflow to build the Fineract API image with Gradle/Jib, build the Mifos frontend image, publish both images, and deploy environment-specific Kubernetes manifests with Kustomize to a GCP-hosted k3s cluster.

The workloads were exposed through NGINX Ingress with TLS. I verified the frontend response and the Fineract health endpoint independently; the API health endpoint reported **UP**, and both application origins returned successful HTTPS responses when tested against the load-balancer origin.

The main lesson: **understand the application and its failure modes first; then automate a deployment you can explain, validate and repeat.**

## Reference architecture

~~~mermaid
flowchart TB
    U[Users / Browser] --> DNS[Public DNS / Edge]
    DNS --> LB[Public TCP Load Balancer]
    LB --> NP[Kubernetes Node Ports]
    NP --> IC[NGINX Ingress Controller]
    IC --> WEB[Mifos Web Frontend]
    IC --> API[Apache Fineract API]
    API --> DB[(Separately Hosted MariaDB)]
~~~

The diagram is intentionally logical. It does not disclose the original network ranges, public addresses, hostnames, node inventory, cloud project identifiers or security configuration.

## Technologies

- Apache Fineract and Mifos web interface
- Docker and Docker Compose
- Gradle and Jib for the Fineract API image
- Bitbucket Pipelines for CI/CD orchestration
- Google Cloud Platform and Artifact Registry
- k3s Kubernetes
- Kustomize environment overlays
- NGINX Ingress and TLS
- MariaDB

## Application build and pre-Helm deployment

The repository now includes the sanitised application build and deployment scaffolding that preceded Helm:

- [Fineract Jib build script](scripts/build-fineract-image.sh) — rebuilds Apache Fineract from a reviewed source ref, adds MariaDB Connector/J 3.5.7 to the Jib runtime classpath, and checks the resulting image.
- [Mifos frontend Dockerfile](Dockerfile.mifos) and [NGINX configuration](nginx/) — package the reviewed static frontend and generate runtime API configuration.
- [Frontend import script](scripts/import-mifos-frontend.sh) — verify the reviewed archive fingerprint, validate its paths and import the static assets.
- [Kubernetes base manifests](k8s/base/) and [environment overlays](k8s/overlays/) — retain the two Deployments, two Services, MariaDB Secret contract, ingress and namespace layout.
- [VM baseline notes](vm-baseline/README.md) — explain the earlier Docker Compose troubleshooting stage.

**Frontend build and runtime status:** The reviewed Mifos frontend distribution is present under `frontend/`, including the sanitised `assets/env.template.js` now tracked in the release-review branch. The template is based on the pinned Mifos web-app source revision documented in [source provenance](docs/upstream-components.md); it retains the MPL-2.0 notice and is aligned with the runtime environment variables used by the NGINX entrypoint. Generated `assets/env.js` remains excluded from Git. On 15 November 2026, the VM-hosted container served the frontend and generated `assets/env.js`; both `/` and `/assets/env.js` returned HTTP 200. An authenticated offices API request through the Mifos NGINX reverse proxy returned HTTP 200. Interactive browser login was not completed because workstation-to-VM port forwarding could not be established. The frontend source line is tagged for Fineract 1.14 while the API image is based on a later Fineract 1.16.1-derived revision; broader compatibility remains unverified. This branch adds an independent frontend CI workflow to validate the tracked files, build the image and smoke-test HTTP/runtime configuration. This does not replace the VM-side integration evidence or constitute a complete third-party licence, permission or disclosure review. A complete executable VM Compose environment has not been imported because its original environment and tenant bootstrap files have not been sanitised.

**Fineract API build and runtime status:** The pinned source revision `d63beed7ccfeadaffa0c7842b1011bc88451376f` was rebuilt locally with Temurin 25.0.5 and Gradle 9.7.1. Jib produced `fineract-api:local`, and the build script verified MariaDB Connector/J 3.5.7 and its runtime classpath entry inside the image. The build completed successfully in 7 minutes 28 seconds. On 15 November 2026, that image was started against a disposable MariaDB 12.2.2 instance with isolated tenant and default databases. Fineract's HTTP health endpoint returned 200 with status `UP`; the authenticated offices endpoint returned HTTP 200 and the default Head Office record, both directly and through the Mifos NGINX proxy.

**Local image inspection:** Both local images were inspected as `linux/amd64`. `fineract-api:local` is approximately 299 MB and its bundled Zulu Java runtime reports 25.0.5; `mifos-web:local` is approximately 40 MB. The Fineract image's Java executable reports Zulu OpenJDK 25.0.5.0.3. Subsequent application startup and MariaDB integration were verified separately on the project VM, as documented below.

## Local real-application integration test (15 November 2026)

A disposable integration stack was run on the project VM using the actual `fineract-api:local` and `mifos-web:local` images. It used a separate MariaDB 12.2.2 container, a dedicated Docker volume and private Docker network; MariaDB had no published host port. Random test passwords were kept in mode-600 temporary files outside the repository. The application database user was granted access only to the two Fineract test databases.

The Fineract default database contained 283 tables and the tenant-store database contained 6 tables after bootstrap. Fineract connected to the default tenant database, started successfully, and returned HTTP 200 with health status `UP`. An authenticated request to `/fineract-provider/api/v1/offices` returned HTTP 200 with the `Head Office` record.

The Mifos container served its single-page application and generated runtime configuration successfully. `assets/env.js` was 4,315 bytes, was served with HTTP 200, and contained the expected API base URL, provider path and default tenant identifier. From the VM, an authenticated offices request sent through the Mifos NGINX reverse proxy also returned HTTP 200 with the same `Head Office` record. A direct container-network probe from Mifos to Fineract's health endpoint returned HTTP 200. Both application containers were observed running with zero restarts.

This is evidence of real-image startup, MariaDB connectivity, frontend static delivery, runtime configuration and authenticated API connectivity through the Mifos reverse proxy. It does not establish that a person completed the interactive browser login: the workstation-to-VM SSH tunnel was not successfully established. It also does not prove every Mifos screen or API workflow, long-duration stability, load, penetration or disaster-recovery behaviour. The frontend source line is tagged for Fineract 1.14 while the API is based on a Fineract 1.16.1-derived revision; the offices endpoint passed, but broader compatibility remains unverified.

The local POC used HTTP between containers on a private Docker network, with host access bound to VM loopback. This is a test arrangement, not a production TLS recommendation. The existing Kubernetes/Ingress reference and the local Docker POC are distinct validation environments.

## Helm chart as an optional deployment path

The initial reusable Helm chart is at [helm/fineract-mifos](helm/fineract-mifos). It templates the Fineract API and Mifos frontend Deployments and Services, consumes a pre-created Kubernetes Secret for database settings, and supports optional Ingress resources with separate TLS configuration.

Helm is included as a possible way to package and deploy these workloads if the project is extended in that direction. **Installing the real Fineract and Mifos images through Helm is not part of the current scope and is not currently planned.** The chart is a reusable starting point and a demonstration of how the VM-validated workloads could be expressed as a Helm release. It uses example-only images, hostnames and Secret names and is not approved for production installation.

The separate Kind lifecycle workflow installed the chart with disposable BusyBox/NGINX fixtures and tested service connectivity, upgrade and rollback. It did not install or run the real application images. The release-review branch keeps that fixture evidence separate from the real-image VM integration evidence.

See:
- [Deployment journey](docs/deployment-journey.md)
- [VM baseline](vm-baseline/README.md)
- [Architecture notes](docs/architecture.md)
- [Upstream source provenance](docs/upstream-components.md)
- [Pinned build and source provenance](docs/build-provenance.md)
- [Kustomize deployment](k8s/README.md)
- [Security and sanitisation rules](docs/security-and-disclosure.md)
- [Helm chart documentation](helm/README.md)

## CI validation status (15 November 2026)

The GitHub Actions history is recorded with its test boundaries:

- Historical combined workflow run **#32** passed Helm lint and template rendering. At that earlier commit the frontend distribution was not present, so frontend checks were skipped.
- Historical combined workflow runs **#33–#42** failed because `frontend/assets/env.template.js` was missing from the Git checkout. The failing step prevented the later frontend image and Helm checks from running in those attempts.
- The release-review branch adds the sanitised runtime template and separates the checks into two independent workflows.
- The Kubernetes/Helm validation workflow passed on the release-review branch and again on the draft PR head (**#51**): it rendered the development, staging and production Kustomize overlays, linted the chart and rendered its default, development, staging and production-example values. This was validation only; it did not install the real Fineract or Mifos images.
- The Mifos frontend workflow also passed on the release-review branch and draft PR head (**#9**): it validated the tracked frontend distribution, built the image, and smoke-tested HTTP delivery and generated runtime configuration.
- A separate Kind workflow previously passed using BusyBox and NGINX fixtures. That proves chart installation, Service reachability, upgrade and rollback mechanics with fixtures only.

The original failure is preserved as engineering history rather than hidden: [failed run #42](https://github.com/Davintus/project-atlas-kubernetes-deployment/actions/runs/43725300686). The PR-head results are [Helm/Kubernetes run #51](https://github.com/Davintus/project-atlas-kubernetes-deployment/actions/runs/43727180769) and [Mifos frontend run #9](https://github.com/Davintus/project-atlas-kubernetes-deployment/actions/runs/43727180781). The [GitHub Actions page](https://github.com/Davintus/project-atlas-kubernetes-deployment/actions) shows any later reruns.

These automated checks do not replace the real-image VM integration test, and the Kind fixture test must not be described as a real application Helm deployment. Both workflows should be green on the final reviewed commit before merge.

## Contributions

Project Atlas is intended to be improved collaboratively. Contributions are welcome to refine the Helm chart, Kubernetes manifests, CI checks, security defaults, documentation and reproducible test fixtures. Please keep examples generic, use synthetic data, add validation for behaviour changes and never submit customer configuration, credentials, private endpoints or production artefacts.

The repository is currently private while sanitisation, licensing, permission and disclosure reviews are completed. Collaborators who have repository access can contribute now; broader community pull requests can be welcomed after the repository is approved for public release. See [CONTRIBUTING.md](CONTRIBUTING.md) for the contribution workflow.

## Evidence and attribution

This case study describes engineering work carried out on a real deployment, presented in anonymised form. It does not claim ownership of Apache Fineract or Mifos, and it does not publish customer data or production configuration. Any public release of implementation material is subject to an appropriate confidentiality and permission review.
