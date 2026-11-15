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

## Local API image build evidence

On 15 November 2026, `scripts/build-fineract-image.sh` completed successfully on the project VM using Temurin 25.0.5 and Gradle 9.7.1. It checked out the full source SHA above, downloaded MariaDB Connector/J 3.5.7, ran `:fineract-provider:jibDockerBuild`, and produced `fineract-api:local`. The script then copied the driver JAR and Jib classpath file out of the image and verified both the driver class and the `/app/libs/mariadb-java-client-3.5.7.jar` classpath entry. The observed Gradle result was `BUILD SUCCESSFUL` in 7 minutes 28 seconds (99 actionable tasks).

The build log reported `project version: 1.17.0-SNAPSHOT`, while the Git description for the checked-out source is `1.16.1-383-gd63beed7cc`. Retain both observations without inferring a cause. The build emitted compiler deprecation/removal warnings and a Gradle deprecation notice, but no build errors.

## Local Docker image inspection

After building, both local images were inspected on the project VM as `linux/amd64`:

| Image | Local image ID | Size |
|---|---|---:|
| `fineract-api:local` | `sha256:402965a19add06ac73eb5a372b357c6bd2925ee7d6d77053fc266ff3af0d6c01` | 299,287,552 bytes |
| `mifos-web:local` | `sha256:32da0fb98fd5fdc4d00a034808f598846b4184b3b1db809908573a57fb0936b4` | 40,265,230 bytes |

The Fineract image's Java executable was invoked with `-version` and reported Zulu OpenJDK 25.0.5.0.3 (Zulu25.38+109-CA, build dated 24 October 2026). This verifies the runtime included in the built image. Subsequent runtime tests on 15 November 2026 started the same image against an isolated MariaDB instance and validated the Fineract health endpoint and an authenticated API request; see the integration evidence below. The Mifos image was first validated by a disposable NGINX container smoke test and was later connected to the running API through its reverse proxy.

**Image reproducibility caveat:** Jib used the base image tag `azul/zulu-openjdk-alpine:25-jre-headless` and resolved it during this build to digest `sha256:fca8cd764db38d4c2b6e99f45269a09ef2cad8bd8546c812f40f7a4591e7e820`. The build log explicitly warned that the configured base-image reference was not pinned to a digest. For stronger long-term reproducibility, pin and review the approved base-image digest in a later change.

The image remains in the VM's local Docker daemon and was not pushed to a registry as part of this portfolio exercise. The later disposable VM integration test started this same image against MariaDB and verified Fineract health and an authenticated API request; see the real-application integration evidence in the deployment journey.

## Mifos web-app source checkout

| Field | Value |
|---|---|
| Upstream repository | https://github.com/openMF/web-app |
| Commit | `4f5be2d5040e37ae26adef023c610028cbf34343` |
| `git describe` | `v1.0.0-fineract1.14-563-g4f5be2d50` |
| Package version | `1.0.0` |
| Licence | Mozilla Public License 2.0 |

The source tag identifies this web-app line as intended for Apache Fineract 1.14. The supplied static distribution contains 406 regular files across 468 archive entries (approximately 34.6 MB uncompressed), including `index.html`, `assets/env.template.js`, compiled application bundles and supporting assets. The generated `assets/env.js` is absent. The bundled TinyMCE licence and notice files are present.

The Mifos 1.14-line frontend and the Kubernetes Fineract 1.16.1-derived API source are not identical version lines. The VM-side integration test below verified one authenticated offices API request through the frontend proxy. This is evidence of basic request-path compatibility, not proof of comprehensive API or UI compatibility.

The reviewed archive SHA-256 is:

```
fd6987552194f07a1617ca366d955b20ebbb8517080884a4b29ab625c415b722
```

The targeted archive review did not identify the known project-specific domains, IP addresses, database dumps, environment files, private-key files or live token patterns. This was not a complete security audit or legal approval for public redistribution.

## Frontend runtime configuration security

The reviewed `env.template.js` declares browser runtime properties for `MIFOS_REMITTANCE_API_CLIENT_KEY` and `EXTERNAL_NATIONAL_ID_SYSTEM_API_KEY`. The compiled frontend reads these properties from `window.env` and may use them in browser-originated requests.

Any value substituted into `env.js` is delivered to the browser and is therefore visible to users. The container entrypoint deliberately forces these two fields to empty and leaves the corresponding optional integrations disabled by default. Do not put confidential API keys, client secrets or other server-side credentials into these browser properties. Where an integration requires a confidential key, use an approved trusted server-side proxy.

## Import status

The reviewed static distribution is committed under `frontend/` on the private `docs/sanitised-project-baseline` branch (import commit `b9c0891`). The checksum-verified import script validated the archive SHA-256 and expected top-level paths before extraction. The frontend validator passed with 409 files (34,643,965 bytes). The local `mifos-web:local` image built successfully. During the VM-side integration test, the container returned HTTP 200 for the application and `assets/env.js`; the generated 4,315-byte runtime file exposed the intended API base URL, provider path and default tenant to the browser, while optional browser-side API-key fields remained empty. An authenticated offices request through the Mifos NGINX reverse proxy returned HTTP 200 from Fineract. The targeted archive review is not a complete security audit or legal approval for public redistribution. The bundled TinyMCE package identifies itself as version 8.3.2; its own `license.md` offers GPL v2-or-later or Tiny self-hosted/commercial terms. The applicable licence basis, any required self-hosted licence-key configuration, and redistribution obligations remain open release-review items.
