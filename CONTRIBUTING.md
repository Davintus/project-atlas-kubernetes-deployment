# Contributing to Project Atlas

Thank you for helping improve Project Atlas.

Project Atlas is a sanitised engineering reference for Apache Fineract, Mifos, container builds, Kubernetes manifests, CI/CD and deployment automation. Contributions that make the examples more accurate, secure, reproducible and easier to maintain are welcome.

## What you can improve

- Helm chart templates, values and documentation.
- Kubernetes base manifests and environment overlays.
- Container build scripts and frontend runtime configuration.
- GitHub Actions validation, chart rendering and test coverage.
- Security defaults, secret-handling guidance and operational runbooks.
- Architecture diagrams, troubleshooting notes and lessons learned.
- Synthetic fixtures and reproducible local integration tests.

Helm is an optional packaging/deployment path in this repository. A real application installation through Helm is not currently part of the project scope; chart changes should be validated with linting, rendering and fixture-based tests unless a future scope explicitly adds real-workload testing.

## Contribution workflow

1. Open an issue or discussion describing the improvement, bug or proposed change.
2. Work on a focused branch and keep pull requests small enough to review.
3. Include the reasoning, expected behaviour and any compatibility implications.
4. Run the relevant shell checks, frontend validation, Kustomize rendering and Helm lint/template checks.
5. Add or update tests when behaviour changes. Do not claim an end-to-end test unless it was actually run.
6. Explain any tests that could not be run and include safe, sanitised output.

## Security and confidentiality rules

- Use synthetic data and clearly marked example values only.
- Never submit customer, employer, bank or vendor information without explicit approval.
- Never commit credentials, API keys, private keys, kubeconfigs, Terraform state, database dumps, production endpoints, private IP ranges or real hostnames.
- Do not add confidential API keys to browser-delivered Mifos runtime configuration.
- Keep generated `frontend/assets/env.js` out of Git. The source template `frontend/assets/env.template.js` is required and should remain tracked.
- Report a suspected secret exposure privately to the repository owner; do not open a public issue containing the value.

## Current repository access

The repository is currently private while source sanitisation, third-party licensing, permission and disclosure reviews are completed. Collaborators with granted repository access are welcome to contribute now. Wider community pull requests can be opened after the project is approved for public release.

Contributions do not imply that this portfolio reference is approved for production use. Any proposed production use requires independent security, architecture, licensing and operational review.
