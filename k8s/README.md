# Sanitised Kubernetes deployment

These manifests preserve the application deployment shape used before Helm: Fineract API on HTTPS port 8443, Mifos frontend on port 80, an externally managed MariaDB database, separate environment overlays and NGINX Ingress.

The original live manifests are not copied verbatim. Image names, hostnames, ingress class and Secret name are placeholders.

## Database Secret contract

Create a Secret in the target namespace before applying an overlay. The API expects keys DB_HOST, DB_PORT, DEFAULT_DB, DB_USER, DB_PASSWORD and TENANTS_JDBC_URL.

Create the Secret out-of-band using approved values. Never commit Secret manifests containing literal values.

## Apply an overlay

Render first:

~~~bash
kubectl kustomize k8s/overlays/development
~~~

After reviewing the rendered YAML and creating the Secret:

~~~bash
kubectl apply -k k8s/overlays/development
kubectl rollout status deployment/fineract-api -n dev --timeout=10m
kubectl rollout status deployment/mifos-web -n dev --timeout=5m
~~~

Namespace mapping is development dev, staging staging, production default. The example.invalid hostnames and ghcr.io/example-project image references are not deployable values. Replace them only in a controlled environment.
