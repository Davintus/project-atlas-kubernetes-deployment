# Security and sanitisation rules

This repository is a public-facing portfolio project prepared from work performed in a separate customer/organisation environment. Keep it anonymised and reproducible; do not copy private production configuration.

## Never commit

- Customer, bank, employer or vendor names unless disclosure is explicitly approved.
- Real production or development domains, URLs, public IP addresses, private IP ranges, internal DNS names or hostnames.
- Cloud project, subscription, tenant, account, cluster, VM, node, registry, bucket or resource identifiers.
- Service-account emails, IAM bindings that expose account names, access tokens, private keys, kubeconfig files or certificate private keys.
- Passwords, API keys, bearer tokens, database connection strings, encrypted secrets, password hashes or secret values.
- Database dumps, application/customer data, tenant identifiers, account references or screenshots/logs that may contain such data.
- Original environment files, Terraform state, pipeline variables, CI logs or monitoring exports without a line-by-line review.

## Safe alternatives

- Use clearly marked placeholders such as <CLOUD_PROJECT_ID>, <REGION>, <REGISTRY>, <APP_DOMAIN> and <DATABASE_HOST>.
- Use Kubernetes Secret references and document the expected Secret keys without publishing values.
- Provide example values files containing non-sensitive demo values only.
- Draw logical architecture diagrams with generic component names.
- Use synthetic data and test-only credentials for reproducible demonstrations.
- Link to upstream Apache Fineract and Mifos documentation rather than copying their source code.

## Review before every push

1. Review the full diff, including hidden files and generated artefacts.
2. Search for domains, IP addresses, project IDs, email addresses, credentials and resource names.
3. Check YAML, shell scripts, Dockerfiles, Helm templates and documentation for hard-coded environment values.
4. Ensure secret files and build artefacts are ignored by Git.
5. Run secret scanning and repository history checks before public release.
6. Confirm that the material is approved for disclosure and does not violate customer, employer, vendor or open-source licensing obligations.

## Git hygiene

The .gitignore file excludes common environment, credential, kubeconfig, Terraform state, local build and editor artefacts. Ignore rules are a safety net, not a substitute for review. Never commit a secret and assume that deleting it in a later commit makes the repository safe: rotate exposed credentials and clean the Git history before any public release.

## Public-release gate

The repository must remain private until code, manifests, docs, screenshots and commit history have been reviewed. No production deployment instructions should contain real endpoints or identity details. Do not use this repository to connect to or modify the original production environment.
