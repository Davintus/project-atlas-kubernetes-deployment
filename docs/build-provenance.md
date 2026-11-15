# Build and source provenance

This document records the source revisions identified from the original VM and frontend checkout. These are historical provenance references; they must not be conflated with the later Kubernetes pipeline build until that image's exact source commit is independently verified.

## Historical VM Fineract checkout

| Field | Value |
|---|---|
| Upstream repository | https://github.com/apache/fineract |
| Commit | `54ac8de1f76694cb4d917f7b88f18100dca2d904` |
| `git describe` | `1.14.0-742-g54ac8de1f` |
| Gradle wrapper at that commit | `8.14.3` |
| Java requirement in that checkout's README | Java 21 or later |

The commit is the `HEAD` of the VM's `~/fineract` checkout. Its working tree was not clean: local changes existed in Compose and environment configuration files, and untracked SQL dumps and miscellaneous files were present. None of those local modifications or untracked files are part of this portfolio import.

## Mifos web-app source checkout

| Field | Value |
|---|---|
| Upstream repository | https://github.com/openMF/web-app |
| Commit | `4f5be2d5040e37ae26adef023c610028cbf34343` |
| `git describe` | `v1.0.0-fineract1.14-563-g4f5be2d50` |
| Package version | `1.0.0` |
| Licence | Mozilla Public License 2.0 |

The source tag identifies this web-app line as intended for Apache Fineract 1.14. The exact source commit and licence were checked against the upstream repository. The static distribution supplied for review contains 468 files (approximately 34.6 MB uncompressed); its archive SHA-256 is:

```
fd6987552194f07a1617ca366d955b20ebbb8517080884a4b29ab625c415b722
```

The archive contains `index.html`, `assets/env.template.js`, the compiled application bundles and supporting assets. It does not contain the generated `assets/env.js`. The bundled TinyMCE licence and notice files are present.

The archive review did not identify the known project-specific domains, IP addresses, database dumps, environment files, private-key files or live token patterns in the distribution. This was a targeted review, not a complete security audit or a legal approval for public redistribution.

## Important distinction: VM source versus Kubernetes image source

The VM checkout above is Fineract 1.14.0-derived and uses Gradle wrapper 8.14.3 with Java 21 or later.

The later Kubernetes image-build evidence recorded a different Fineract build line and build toolchain (including Java 25.0.5 and Gradle 9.7.1). The exact source commit for that Kubernetes image has not yet been reconciled to the VM checkout.

Do not change the Kubernetes image build's pinned source reference to the VM commit merely because both are Apache Fineract. Keep the two records separate until the successful image's Bitbucket build log or image metadata identifies its exact source commit.

## Frontend runtime configuration security

The reviewed `env.template.js` declares browser runtime properties for `MIFOS_REMITTANCE_API_CLIENT_KEY` and `EXTERNAL_NATIONAL_ID_SYSTEM_API_KEY`. The compiled frontend reads these properties from `window.env` and may use them in browser-originated requests.

Any value substituted into `env.js` is delivered to the browser and is therefore visible to users. Do not put confidential API keys, client secrets or other server-side credentials into these fields. The container entrypoint deliberately leaves these two values empty and the corresponding optional integrations disabled by default. Where a remote integration requires a confidential key, route it through a trusted server-side proxy instead.

## Import status

The archive has been inspected in this working session, but its 468 binary/static files have not yet been committed to this GitHub branch. The repository's `frontend/` directory therefore remains a placeholder until those assets are transferred through a Git-enabled workspace. See [frontend import instructions](frontend/README.md).
