# VM baseline deployment

This directory records the first working baseline used to understand Apache Fineract and the Mifos web interface before completing the Kubernetes automation.

## Original VM layout

The original development VM used two distinct delivery mechanisms:

1. **Docker Compose** ran the Fineract API and MariaDB. The Compose definition also included Loki, Prometheus, Grafana and Tempo services for observability.
2. **Host-level NGINX** served the Mifos static frontend from the VM's web root and reverse-proxied requests to the local Fineract HTTPS listener.

The original Compose service definitions made the Fineract service wait for MariaDB's health check before startup. The Fineract service exposed its HTTPS application port and a separate diagnostic/debug port. Environment settings were loaded from several local env files rather than hard-coded into the Compose YAML.

The NGINX virtual hosts were separate: one handled the Fineract reverse proxy, and another served the Mifos single-page application with an index-file fallback. TLS certificates and HTTP-to-HTTPS redirects were managed on the VM.

The public example intentionally does not include the original domain names, local account names, VM names, certificate paths, private IP addresses or customer identifiers.

## Logical VM architecture

~~~mermaid
flowchart TB
    U[Browser] --> HN[Host NGINX]
    HN -->|Static files| MF[Mifos web distribution]
    HN -->|HTTPS reverse proxy| FA[Fineract API :8443]
    subgraph VM[Standalone development VM]
      subgraph DC[Docker Compose]
        FA
        DB[(MariaDB 12.2)]
        OBS[Loki / Prometheus / Grafana / Tempo]
        FA --> DB
      end
      HN
      MF
    end
~~~

The diagram represents the original development arrangement. It is distinct from the later Kubernetes architecture, where both application workloads were containerised and exposed through Kubernetes Services and NGINX Ingress.

## Why the VM baseline mattered

The VM deployment provided a controlled reference for understanding:

- Fineract startup and application health;
- MariaDB readiness and the order in which services should start;
- the separation between the Fineract API and the Mifos static web bundle;
- the frontend's runtime API configuration;
- the local NGINX reverse-proxy and static-file serving behaviour; and
- which dependencies and configuration needed to be carried into Kubernetes.

This was a deliberate troubleshooting step after the first pipeline-led deployment failed during database bootstrap and tenant-upgrade processing. It helped establish a working application baseline before automating the Kubernetes rollout.

## Configuration and data handling

The original Compose file referenced local environment files for Fineract, MariaDB, database settings, tracing, metrics and optional integrations. Those files may contain database passwords, tenant master-password material, AWS credentials or other sensitive values.

Do not copy the original env files, database dumps, database data directories, generated frontend runtime configuration or certificates into this repository. Use a reviewed `.env.example` containing variable names and dummy placeholders only. Supply actual secrets through a local secret store or an approved runtime secret mechanism.

The original Compose file also referenced MariaDB compatibility and collation settings. These can be reproduced as non-secret example configuration after checking them against the selected MariaDB and Fineract versions.

## Reproducing a VM baseline

1. Provision an isolated development VM with Docker Engine, Docker Compose and NGINX.
2. Check out a reviewed Apache Fineract source release and build the API image using [the Fineract build script](../scripts/build-fineract-image.sh).
3. Prepare MariaDB and the Fineract tenant/tenant-store databases using configuration appropriate for the selected Fineract release.
4. Create local environment configuration from documented variable names. Keep all real values outside Git.
5. Place the approved Mifos static build in `frontend/`.
6. Build the Mifos frontend image with [the frontend Dockerfile](../Dockerfile.mifos) when testing the containerised delivery path, or serve the static files through host NGINX when reconstructing the original VM stage.
7. Start the API and database services, wait for MariaDB health, then verify the Fineract health endpoint and Mifos frontend separately.

This repository does not yet include a fully executable copy of the original VM Compose environment. The complete original env files, tenant database bootstrap material and runtime secrets have intentionally not been imported.

## Outstanding historical source material

The original VM transcript confirms the Compose service topology and the two host NGINX virtual hosts, but it is not a complete export of the VM project. The historical frontend distribution still needs a source-revision and redistribution review before import. A disposable MariaDB integration test is also required before claiming that the full application stack has been reproduced from this repository.
