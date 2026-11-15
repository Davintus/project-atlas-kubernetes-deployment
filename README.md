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

**Frontend build status:** The reviewed Mifos static distribution is committed under `frontend/` (import commit `b9c0891`). Its validator passed, the `mifos-web:local` image built successfully, and a local container smoke test returned HTTP 200 from NGINX and generated `assets/env.js` with optional browser-side API-key fields empty. This verifies frontend static delivery and runtime configuration only; real Fineract API connectivity and full application integration remain outstanding. A complete third-party licence, permission and disclosure review is still required before any public release. This repository also does not yet include a complete executable VM Compose environment because its original environment and tenant bootstrap files have not been imported and sanitised.

## Helm chart

The initial reusable Helm chart is at [helm/fineract-mifos](helm/fineract-mifos). It templates the Fineract API and Mifos frontend Deployments and Services, consumes a pre-created Kubernetes Secret for database settings, and supports optional Ingress resources with separate TLS configuration.

The chart uses example-only images, hostnames and Secret names. It is **not approved for production installation**. GitHub Actions validates chart lint/rendering and runs an isolated kind-based smoke test using disposable BusyBox/NGINX test containers. That smoke test validates Helm installation, in-cluster Service connectivity, upgrade and rollback; it does not run the real Fineract application or prove MariaDB integration.

See:
- [Deployment journey](docs/deployment-journey.md)
- [VM baseline](vm-baseline/README.md)
- [Architecture notes](docs/architecture.md)
- [Upstream source provenance](docs/upstream-components.md)
- [Pinned build and source provenance](docs/build-provenance.md)
- [Kustomize deployment](k8s/README.md)
- [Security and sanitisation rules](docs/security-and-disclosure.md)
- [Helm chart documentation](helm/README.md)

## Evidence and attribution

This case study describes engineering work carried out on a real deployment, presented in anonymised form. It does not claim ownership of Apache Fineract or Mifos, and it does not publish customer data or production configuration. Any public release of implementation material is subject to an appropriate confidentiality and permission review.
