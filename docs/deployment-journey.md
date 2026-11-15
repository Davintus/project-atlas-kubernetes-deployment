# Deployment journey

## 1. The first automation attempt exposed an application problem

The initial pipeline-led approach did not produce a stable Fineract deployment. The application failed during database bootstrap and tenant-upgrade processing. The pipeline could build and deploy workloads, but it could not make an application start successfully while its database prerequisites and tenant credential state were inconsistent.

The important distinction is that this was not just a YAML or pipeline syntax problem: the failure was visible in the application startup path.

## 2. Establish a working VM baseline

I stepped back and deployed Apache Fineract and its MariaDB database on a standalone cloud VM using Docker Compose. The Compose definition also included observability services for logs, metrics and traces.

The Mifos web interface was served separately by NGINX installed on the VM. One NGINX virtual host served the static Mifos single-page application, while another reverse-proxied requests to Fineract's local HTTPS listener. TLS certificates and HTTP-to-HTTPS redirects were configured at the VM's NGINX layer.

This distinction matters: the original VM deployment did not run Mifos as a service in the same Compose stack. The later Kubernetes delivery containerised the Mifos static distribution behind its own NGINX image.

The VM deployment provided a controlled baseline to understand application health, MariaDB readiness, runtime configuration and the boundary between the frontend and API.

## 3. Diagnose the Kubernetes tenant-upgrade failure

When the API was deployed to Kubernetes, its pods entered a crash/restart cycle. The useful error was further down the application stack: Fineract reported that it could not decrypt a stored tenant database password using the configured master password and encryption algorithm. The logs included an invalid Base64 character during the decryption attempt.

I traced this to the tenant credential/encryption configuration, corrected the inconsistency, and restored API startup. The important operational lesson was to follow the failure to its root cause rather than treating the outer Spring/JPA dependency errors as the root problem.

No live credential, encrypted value, tenant identifier, schema name or database connection string is included in this repository.

## 4. Reconstruct and refine the delivery workflow

The successful API image build used Temurin JDK 25.0.5 and Gradle 9.7.1. The pipeline downloaded MariaDB Connector/J 3.5.7, added it to the Jib image runtime classpath, then checked that the driver JAR and classpath entry were present in the resulting image. The frontend image used NGINX with gettext/envsubst to generate its API environment file at container startup, keeping environment-specific values out of the static image.

The resulting CI/CD process separated the main stages:

1. Locate and build the Fineract API using the repository's Gradle wrapper and Jib.
2. Build the Mifos web image from the reviewed static frontend distribution.
3. Tag and publish both images to a container registry.
4. Select an environment-specific Kubernetes overlay.
5. Render/validate the Kustomize output.
6. Apply the manifests and update the API and frontend image references.
7. Wait for both deployments to complete their rollouts and inspect workload status.

The original pipeline was built around a self-hosted Linux runner. This public case study intentionally omits runner identifiers, cloud project details, service-account identities, registry paths, build secrets and kubeconfig content.

## 5. Route traffic and verify the applications

NGINX Ingress provided hostname-based routing to the frontend and API services. TLS was configured for external access, with HTTPS used for the Fineract ingress backend.

Validation was performed in layers:

- Kubernetes deployments and pods reached their expected ready state.
- The Fineract health endpoint returned HTTP success and reported **UP**.
- The Mifos frontend returned a successful HTTP response.
- Direct HTTPS requests to both application origins through the public load-balancer path succeeded.

These checks establish application and ingress reachability at the time of testing; they are not a claim of a formal load, penetration, disaster-recovery or long-duration resilience test.

## 6. Package the deployment with Helm as an optional path

An initial reusable Helm chart is present in `helm/fineract-mifos`. It templates the API and frontend Deployments and Services, consumes an externally created Kubernetes Secret for database configuration, and supports optional Ingress resources with separate TLS settings.

The chart is included to demonstrate one possible way to package and deploy the workloads after they have been validated. Installing the real Fineract and Mifos images through Helm is **not part of the current scope and is not currently planned**. It remains a possible follow-on exercise if the project is extended.

The separate Kind smoke-test workflow completed successfully in runs #1 and #2 using disposable BusyBox and NGINX fixtures. It verified chart installation, in-cluster Service connectivity, an API replica upgrade and Helm rollback. These tests validate chart structure and Kubernetes release lifecycle only; they do not deploy the real application images or prove MariaDB integration.

The combined Helm/Mifos validation workflow run #32 also completed successfully before the frontend distribution was imported; at that point the workflow intentionally skipped frontend validation and image build, while Helm lint and value rendering passed. After the frontend import, runs #33 through #42 failed in the Mifos frontend validation step because `frontend/assets/env.template.js` was missing from the GitHub checkout. The subsequent frontend image build and Helm lint/render steps were skipped. The cause was an over-broad `.gitignore` pattern (`frontend/assets/env.*.js`) that also matched the required template. A negated ignore exception has now been added, but the missing template still needs to be committed from the VM checkout before CI can pass again. The current combined workflow status must therefore be reported as failing until that file is tracked and the workflow is rerun.

## 7. Validate the real application images together on the project VM

After the static frontend and API images were built and inspected, a disposable integration stack was created on the project VM on 15 November 2026. The stack used the actual `fineract-api:local` and `mifos-web:local` images, a separate MariaDB 12.2.2 container, a dedicated Docker volume and an isolated Docker network. MariaDB had no published host port. Random test passwords were held in mode-600 temporary files outside the repository, and the application database user was limited to the two Fineract test databases.

The initial database bootstrap completed successfully. The default tenant database contained 283 tables, and the tenant-store database contained 6 tables. Fineract connected to the default tenant database and its health endpoint returned HTTP 200 with status `UP`. Logs showed the default tenant connection pool starting successfully. An authenticated request to `/fineract-provider/api/v1/offices` returned HTTP 200 with the `Head Office` record.

The Mifos NGINX container served the frontend with HTTP 200 and generated `assets/env.js` at startup. The 4,315-byte runtime file was itself served with HTTP 200 and contained the expected API base URL, API provider path and `default` tenant value. A container-network probe from Mifos to the Fineract health endpoint returned HTTP 200. After aligning the NGINX upstream with Fineract's internal HTTP listener and recreating the Mifos container so it used the updated bind-mounted configuration, an authenticated offices API request through the Mifos NGINX reverse proxy returned HTTP 200 and the same Head Office record. At the last inspection, both application containers were running with zero restarts.

This verifies real-image application startup, MariaDB connectivity, Mifos static delivery, runtime configuration and authenticated API connectivity through the frontend reverse proxy. It is stronger than the earlier image-only and fixture-only tests.

## 8. Remaining validation and release boundaries

The workstation-to-VM SSH port-forwarding attempt did not establish a local browser connection. Therefore, an interactive Mifos browser login, dashboard rendering and complete user workflow were **not verified**. This is a limitation of the browser access path in this test, not evidence that the API proxy failed: the authenticated offices request through the proxy returned HTTP 200 from the VM. The VM-side integration objective—real application startup and authenticated API communication through the frontend proxy—has been met, but the work should not be described as a fully browser-accepted Mifos deployment.

The Mifos frontend source line is tagged for Fineract 1.14, whereas the Kubernetes API image is based on a Fineract 1.16.1-derived revision. The offices endpoint passed, but broad API/UI compatibility has not been established. Deploying the real application images through Helm in a disposable Kubernetes cluster is an optional future extension, not part of the current plan. No formal load, penetration, disaster-recovery or long-duration resilience tests are claimed.

The private portfolio branch remains private pending the third-party licence, permission, security and disclosure reviews. The original VM Compose environment has not been imported because its environment and tenant bootstrap files have not been sanitised.

## 9. CI history, known issue and contribution model

On 15 November 2026, the GitHub Actions history showed ten consecutive failures in the combined validation workflow (runs #33–#42). The jobs reached shell-syntax checking and Kustomize overlay rendering successfully, then failed because `frontend/assets/env.template.js` was not present in the GitHub checkout. The Mifos image build and the later Helm lint/render steps were consequently skipped. The failure was not caused by the VM-side Fineract/Mifos integration test.

The cause was traced to the `.gitignore` rule `frontend/assets/env.*.js`, which unintentionally ignored the source template as well as the generated runtime file. A specific exception has been added for `frontend/assets/env.template.js`. The template still needs to be committed from the VM checkout and the workflow rerun; until then, the latest combined CI result remains failing. The generated `frontend/assets/env.js` should remain ignored.

Project Atlas is intended to be refined collaboratively. Contributors with access to the currently private repository are welcome to improve the example Helm chart, Kubernetes overlays, CI validation, security controls, documentation and synthetic test fixtures. Broader community contributions can be invited once the sanitisation, licensing, permission and disclosure reviews permit public release. Never contribute customer details, live credentials, private network information or production configuration.

## Lessons

- A pipeline can deploy an unhealthy application consistently; application readiness and dependency checks matter.
- A working VM baseline can shorten diagnosis when a containerised or orchestrated deployment is failing.
- Tenant database credentials can involve encryption and master-password configuration, not only ordinary database username/password connectivity.
- Build, publish, deploy and post-deploy verification should be explicit pipeline stages.
- Public technical evidence should show the engineering approach without revealing private infrastructure.
