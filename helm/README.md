# Fineract and Mifos Helm chart

This chart deploys the Apache Fineract API and Mifos web frontend. MariaDB is intentionally external to the chart: the chart creates application Deployments, ClusterIP Services and optional Ingress resources, but does not create, migrate, back up or manage a database.

## Status and safety

This is an initial portfolio chart prepared from a sanitised deployment model. It has not been installed into the original cluster and must not be used against production as-is. All image references and hostnames in the defaults are example-only placeholders.

The GitHub Actions workflow runs:

- helm lint;
- helm template using default values;
- helm template using the development, staging and production-example values.

A disposable Kubernetes installation, API/frontend connectivity check and Helm upgrade/rollback test are still required before the chart can be considered operationally validated.

## Prerequisites

- A Kubernetes cluster with a compatible ingress controller if Ingress is enabled.
- Deployable Fineract API and Mifos frontend container images.
- An externally managed MariaDB instance and databases provisioned for Fineract.
- A Kubernetes Secret in the target namespace containing the database connection values required by the API.
- TLS Secret resources in the target namespace when TLS is enabled.

## Database Secret contract

By default, the API Deployment reads these keys from the existing Secret named fineract-db-credentials:

| Secret key | Used for |
|---|---|
| DB_HOST | Default tenant database host |
| DB_PORT | Default tenant database port |
| DEFAULT_DB | Default tenant database name |
| DB_USER | Database username |
| DB_PASSWORD | Database password |
| TENANTS_JDBC_URL | JDBC URL for the tenant store |

Override the Secret name and key names under api.database in a values file when necessary. The chart does not create a Secret and never places credential values in chart defaults.

Fineract tenant master-password/encryption configuration is version-sensitive. Use api.extraEnv to add the exact environment variable(s) supported by the Fineract version being deployed, with valueFrom.secretKeyRef pointing to a Secret. Do not guess the variable name or commit its value; verify the setting against the selected Fineract version and the deployment's approved configuration.

## Configure before installation

1. Replace both example image repositories and tags with the images built for your own environment.
2. Change the frontend API URL to the approved URL reachable by browsers using the Mifos interface.
3. Change the Ingress class, hostnames, TLS Secret names and annotations to values appropriate for the target cluster.
4. Create the database Secret and TLS Secrets out-of-band in the destination namespace.
5. Review the rendered Kubernetes resources and confirm no real credentials or customer identifiers appear in values or manifests.

## Render and lint

From the repository root:

~~~bash
helm lint helm/fineract-mifos

helm template project-atlas helm/fineract-mifos \
  --namespace project-atlas

helm template project-atlas helm/fineract-mifos \
  --namespace project-atlas \
  -f helm/fineract-mifos/values/development.yaml
~~~

Render the staging and production-example values in the same way. Inspect the output before applying it.

## Install into a disposable test namespace

After replacing the example values and creating the required external Secrets:

~~~bash
helm upgrade --install project-atlas helm/fineract-mifos \
  --namespace project-atlas-test \
  --create-namespace \
  -f helm/fineract-mifos/values/development.yaml \
  --dry-run
~~~

A dry-run validates Helm rendering and release processing; it does not prove that the application can connect to MariaDB or that ingress and TLS work end to end. Follow with a real installation only in a disposable test cluster/namespace with synthetic data.

## Upgrade and rollback testing

Test the following with a disposable database and synthetic tenant data:

- application image upgrade;
- configuration change and rollout;
- failed rollout recovery;
- Helm rollback;
- API health and frontend/API connectivity after each operation.

Back up the database before running application versions that may apply schema or tenant migrations. Do not assume application rollback reverses database migrations.

## Current values

- values.yaml: safe general defaults.
- values/development.yaml: one replica per workload and example development hosts.
- values/staging.yaml: one replica per workload and example staging hosts.
- values/production.example.yaml: two replicas per workload and placeholder production hosts. It is an illustration only, not an endorsed production configuration.
