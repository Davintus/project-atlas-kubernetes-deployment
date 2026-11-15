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

## 6. Package the deployment with Helm

An initial reusable Helm chart is now present in `helm/fineract-mifos`. It templates the API and frontend Deployments and Services, consumes an externally created Kubernetes Secret for database configuration, and supports optional Ingress resources with separate TLS settings.

GitHub Actions has passed chart linting and template rendering for the default, development, staging and production-example values. A separate Kind smoke test installed the chart with disposable BusyBox and NGINX fixtures, verified in-cluster Service connectivity, upgraded the API replica count and rolled the release back.

These checks validate Helm packaging and Kubernetes release lifecycle. They do **not** yet prove that the actual Fineract and Mifos images can run together against MariaDB.

## 7. Remaining integration milestone

The reviewed historical Mifos frontend distribution has now been imported under `frontend/` on the private portfolio branch. Its archive fingerprint and expected paths were checked before extraction, and the generated runtime `env.js` is deliberately excluded from source control. The frontend validator passed (409 files, 34,643,965 bytes), the `mifos-web:local` image built successfully, and a disposable container returned HTTP 200 from NGINX while generating the runtime configuration. The optional browser-side API-key fields were confirmed empty. This is a static frontend/container smoke test only; it does not verify Fineract API communication.

The remaining work is to:

1. run the frontend validator and build/smoke-test the actual Mifos NGINX image;
2. prepare an isolated MariaDB instance with synthetic tenant data and the required Fineract bootstrap configuration;
3. build the pinned Fineract API image and the imported Mifos frontend image;
4. install both real application images with the Helm chart into a disposable Kubernetes cluster;
5. verify Fineract startup, tenant upgrade, API health and Mifos-to-API connectivity; and
6. test Helm upgrade and rollback with the real application workloads.

The Mifos frontend source line is tagged for Fineract 1.14, whereas the Kubernetes API image is based on a Fineract 1.16.1-derived revision. Their compatibility must be demonstrated by the real-app integration test. The private portfolio branch is not ready for public release until the third-party licence, permission and disclosure reviews are complete.

## Lessons

- A pipeline can deploy an unhealthy application consistently; application readiness and dependency checks matter.
- A working VM baseline can shorten diagnosis when a containerised or orchestrated deployment is failing.
- Tenant database credentials can involve encryption and master-password configuration, not only ordinary database username/password connectivity.
- Build, publish, deploy and post-deploy verification should be explicit pipeline stages.
- Public technical evidence should show the engineering approach without revealing private infrastructure.
