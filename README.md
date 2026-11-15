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

## Repository status

This repository is being built privately and sanitised before any public release. The current baseline documents the deployment journey and logical architecture. The original production manifests and pipeline files are **not** copied here.

**Next milestone:** create and validate a reusable Helm chart with environment-specific values, external database configuration, Kubernetes Secret references, ingress/TLS options, health probes, resource settings and documented upgrade/rollback guidance.

See:
- [Deployment journey](docs/deployment-journey.md)
- [Architecture notes](docs/architecture.md)
- [Security and sanitisation rules](docs/security-and-disclosure.md)
- [Helm chart plan](helm/README.md)

## Evidence and attribution

This case study describes engineering work carried out on a real deployment, presented in anonymised form. It does not claim ownership of Apache Fineract or Mifos, and it does not publish customer data or production configuration. Any public release of implementation material is subject to an appropriate confidentiality and permission review.
