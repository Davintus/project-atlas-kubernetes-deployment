# Helm chart — planned implementation

**Status: not yet implemented or validated.** This document defines the next engineering milestone; it is not a claim that a working chart is already available.

## Intended chart scope

A reusable chart for deploying:

- Apache Fineract API;
- Mifos web frontend;
- Kubernetes Services for both workloads;
- optional Ingress resources for both application routes.

The database remains external to the chart by default. This avoids silently coupling application release lifecycle to persistent database lifecycle.

## Configuration design

Values should be separated by concern and environment:

- image repository, tag and pull policy for API and frontend;
- replica counts and resource requests/limits;
- application environment variables;
- references to pre-created Kubernetes Secrets for database credentials and master-password material;
- API and frontend Service ports;
- ingress enablement, class, hostnames, TLS secret references and annotations;
- readiness and liveness probes;
- optional pod scheduling, security context and image pull secrets.

No real production values, hostnames, credentials, registry paths or cluster-specific ingress class names belong in the chart defaults.

## Validation plan

1. Run helm lint on the chart.
2. Render default and environment-specific configurations with helm template.
3. Inspect rendered output for hard-coded domains, IPs, credentials and cloud identifiers.
4. Validate rendered Kubernetes objects against the target Kubernetes API version.
5. Perform a dry-run installation in a disposable test namespace.
6. Verify API and frontend rollout behaviour, service routing, TLS configuration and health probes.
7. Test an upgrade and rollback using synthetic configuration and a disposable database.
8. Document external database preparation, Secret creation, install, upgrade and rollback commands.

## Proposed chart layout

~~~text
helm/
  fineract-mifos/
    Chart.yaml
    values.yaml
    values.schema.json
    templates/
      _helpers.tpl
      api-deployment.yaml
      api-service.yaml
      frontend-deployment.yaml
      frontend-service.yaml
      ingress-api.yaml
      ingress-frontend.yaml
      NOTES.txt
    values/
      development.yaml
      staging.yaml
      production.example.yaml
~~~

The chart will be added only after its templates have been built from a reviewed, sanitised resource model. The values files shown above are a proposed layout, not existing validated files.
