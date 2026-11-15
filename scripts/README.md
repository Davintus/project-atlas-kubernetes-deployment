# Image build scripts

## Fineract API

The Fineract API builder reproduces the successful Kubernetes image-build approach: the known-good Apache Fineract commit, Temurin JDK 25.0.5, Gradle 9.7.1, MariaDB Connector/J 3.5.7 added to the Jib image classpath, and verification of the resulting image.

The default source commit is the exact SHA recorded in the successful Bitbucket build log:

```
d63beed7ccfeadaffa0c7842b1011bc88451376f
```

Run:

~~~bash
export FINERACT_IMAGE_NAME=fineract-api
export FINERACT_IMAGE_TAG=local

bash scripts/build-fineract-image.sh
~~~

The script prints the resolved source SHA. Override `FINERACT_SOURCE_REF` only when deliberately testing a different revision, and verify that revision's Java and Gradle requirements before doing so. The historical VM checkout at Fineract 1.14 uses a different Gradle wrapper and Java baseline; it is not the default Kubernetes image source.

## Mifos frontend

Import the reviewed static Mifos distribution with the checksum-verified script:

~~~bash
bash scripts/import-mifos-frontend.sh /path/to/mifos-frontend-review.tar.gz
~~~

Then build:

~~~bash
export MIFOS_IMAGE_NAME=mifos-web
export MIFOS_IMAGE_TAG=local

bash scripts/build-mifos-image.sh
~~~

The build validates `index.html`, `assets/env.template.js`, the Mifos MPL header and bundled TinyMCE licence/notice files. It refuses to package a generated `assets/env.js` or common credential/database files.

The container entrypoint generates `assets/env.js` at startup. Values written to that file are visible in the browser. The two optional integration API-key fields are deliberately blank and their integrations disabled by default. Do not provide confidential credentials through frontend environment variables; use a trusted backend proxy where required.
