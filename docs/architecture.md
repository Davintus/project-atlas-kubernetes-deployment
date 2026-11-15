# Logical architecture

## Components

| Component | Responsibility | Public reference treatment |
|---|---|---|
| Public DNS / edge | Resolves application names and may proxy inbound traffic | Provider names and real hostnames omitted |
| Public TCP load balancer | Forwards HTTP/HTTPS traffic towards the Kubernetes ingress entry point | Public IP, forwarding-rule names and backend IDs omitted |
| k3s cluster | Hosts the application workloads | Cluster name, node names, node addresses and network ranges omitted |
| NGINX Ingress | Routes requests to the frontend and API services; handles external TLS | Ingress class names, hostnames and certificate names replaced with generic values |
| Mifos web frontend | Browser-facing application | Image registry path and environment-specific API URL omitted |
| Apache Fineract API | Core application API | Image registry path and tenant data omitted |
| MariaDB | Persistent relational database used by Fineract | Server address, database/schema names, users and credentials omitted |

## Request path

1. A user resolves the application hostname through public DNS/edge services.
2. Inbound HTTP or HTTPS reaches the public load balancer.
3. The load balancer forwards traffic to the Kubernetes ingress entry point.
4. NGINX Ingress routes the request to the Mifos frontend or Fineract API service.
5. The API connects to a separately hosted MariaDB service over a private network.

## Conceptual diagram

~~~mermaid
flowchart TB
    B[Browser] --> E[DNS / Edge]
    E --> F[Public Load Balancer]
    F --> K[k3s ingress entry point]
    K --> N[NGINX Ingress]
    N --> W[Mifos Frontend Service]
    N --> A[Fineract API Service]
    A --> M[(MariaDB on private network)]
~~~

## Security boundaries represented in the reference

- External application access uses TLS.
- The API ingress backend is configured for HTTPS.
- The database is separately hosted and reached over private connectivity.
- Application database credentials are supplied to Kubernetes through Secret references, not embedded as literal values in Deployment manifests.
- Public DNS and edge configuration are outside the application Helm chart's core responsibility.

This is a logical view for learning and portfolio evidence. It is not a substitute for the original approved architecture, firewall rules, route tables, threat model or security design.
