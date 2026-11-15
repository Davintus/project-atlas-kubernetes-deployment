# Build and source provenance

This document separates the historical VM checkout from the source commit used by the later Kubernetes API image build. They are different Fineract revisions and should not be substituted for one another.

## Historical VM Fineract checkout

| Field | Value |
|---|---|
| Upstream repository | https://github.com/apache/fineract |
| Commit | `54ac8de1f76694cb4d917f7b88f18100dca2d904` |
| `git describe` | `1.14.0-742-g54ac8de1f` |
| Gradle wrapper at that commit | `8.14.3` |
| Java requirement in that checkout's README | Java 21 or later |

The commit is the `HEAD` of the VM's `~/fineract` checkout. Its working tree was not clean: local changes existed in Compose and environment configuration files, and untracked SQL dumps and miscellaneous files were present. None of those local modifications or untracked files are part of this portfolio import.

## Kubernetes API image build — known-good source

| Field | Value |
|---|---|
| Upstream repository | https://github.com/apache/fineract |
| Full source commit | `d63beed7ccfeadaffa0c7842b1011bc88451376f` |
| `git describe` from the build log | `1.16.1-383-gd63beed7cc` |
| Java | Eclipse Temurin 25.0.5 |
| Gradle used by the successful build | 9.7.1 |
| MariaDB Connector/J | 3.5.7 |

The 9 November successful build log explicitly checked out this commit, installed the specified JDK, pinned the Gradle wrapper to 9.7.1, added MariaDB Connector/J 3.5.7 to the Jib image runtime classpath and verified that the driver JAR and classpath entry were present in the built image.

The Gradle build output from a later source/build investigation also reported `project version: 1.17.0-SNAPSHOT`. This differs from the Git `git describe` value above. Preserve both observations; do not infer that one is a typo or silently rewrite the provenance. For the Kubernetes build script, the full source SHA and toolchain above are the reproducible baseline recovered from the successful pipeline log.

The build script defaults to this full source SHA. It accepts an explicit `FINERACT_SOURCE_REF` override, but a different source ref must be validated against its own compatible Java and Gradle requirements.

## Mifos web-app source checkout

| Field | Value |
|---|---|
| Upstream repository | https://github.com/openMF/web-app |
| Commit | `4f5be2d5040e37ae26adef023c610028cbf34343` |
| `git describe` | `v1.0.0-fineract1.14-563-g4f5be2d50` |
| Package version | `1.0.0` |
| Licence | Mozilla Public License 2.0 |

The source tag identifies this web-app line as intended for Apache Fineract 1.14. The supplied static distribution contains 406 regular files across 468 archive entries (approximately 34.6 MB uncompressed), including `index.html`, `assets/env.template.js`, compiled application bundles and supporting assets. The generated `assets/env.js` is absent. The bundled TinyMCE licence and notice files are present.

The Mifos 1.14-line frontend and the Kubernetes Fineract 1.16.1-derived API source are not identical version lines. The real-application integration test must therefore verify their actual API compatibility rather than assuming version alignment.

The reviewed archive SHA-256 is:

```
fd6987552194f07a1617ca366d955b20ebbb8517080884a4b29ab625c415b722
```

The targeted archive review did not identify the known project-specific domains, IP addresses, database dumps, environment files, private-key files or live token patterns. This was not a complete security audit or legal approval for public redistribution.

## Frontend runtime configuration security

The reviewed `env.template.js` declares browser runtime properties for `MIFOS_REMITTANCE_API_CLIENT_KEY` and `EXTERNAL_NATIONAL_ID_SYSTEM_API_KEY`. The compiled frontend reads these properties from `window.env` and may use them in browser-originated requests.

Any value substituted into `env.js` is delivered to the browser and is therefore visible to users. The container entrypoint deliberately forces these two fields to empty and leaves the corresponding optional integrations disabled by default. Do not put confidential API keys, client secrets or other server-side credentials into these browser properties. Where an integration requires a confidential key, use an approved trusted server-side proxy.

## Import status

The reviewed static distribution is committed under `frontend/` on the private `docs/sanitised-project-baseline` branch (import commit `b9c0891`). The checksum-verified import script validated the archive SHA-256 and expected top-level paths before extraction. The frontend validator passed with 409 files (34,643,965 bytes). The local `mifos-web:local` image built successfully, and a disposable container returned HTTP 200 from NGINX and generated `assets/env.js`; the two optional browser-side API-key fields were verified empty. This validates static delivery and runtime configuration, not real Fineract API integration. The targeted archive review is not a complete security audit or legal approval for public redistribution.
