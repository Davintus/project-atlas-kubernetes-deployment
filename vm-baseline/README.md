# VM baseline deployment

This directory records the first working baseline used to understand Fineract and Mifos before completing the Kubernetes automation.

The baseline ran on a standalone cloud VM:

- Apache Fineract API built from upstream source using Gradle/Jib;
- MariaDB 12.2 running separately with persistent storage;
- Mifos web distribution served by an NGINX container;
- Docker Compose used to coordinate the containers and startup dependencies.

The VM approach exposed the relationship between database readiness and Fineract startup and provided a reference for the later Kubernetes deployment.

## Reproducing a VM baseline

1. Provision an isolated development VM with Docker Engine and Docker Compose.
2. Check out a reviewed Apache Fineract source release and build the API image using `scripts/build-fineract-image.sh`.
3. Prepare MariaDB and the Fineract tenant/tenant-store databases using configuration for the selected Fineract release.
4. Create local environment configuration from documented variable names; never commit it.
5. Place the approved Mifos static build in `frontend/`.
6. Build the frontend image with `docker build -f Dockerfile.mifos -t mifos-web:local .`.
7. Start the services using a reviewed Compose file, then verify API health and frontend access.

This repository does not yet include a fully executable Compose file because the original VM environment's complete environment files and database bootstrap configuration have not been imported and sanitised. Do not infer missing tenant master-password or Liquibase settings from this guide.

## Historical deployment notes

The original development VM used the Fineract development Compose configuration, MariaDB 12.2, a persistent database volume and a separate Mifos NGINX frontend container. Production later used an independently hosted MariaDB service outside the Kubernetes workloads.
