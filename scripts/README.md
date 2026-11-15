# Image build scripts

## Fineract API

The Fineract API builder reproduces the successful image-build approach: Apache Fineract source at a reviewed ref, Temurin JDK 25.0.5, Gradle 9.7.1, MariaDB Connector/J 3.5.7 added to the Jib image classpath, and image verification.

~~~bash
export FINERACT_SOURCE_REF=<reviewed-tag-or-commit>
export FINERACT_IMAGE_NAME=fineract-api
export FINERACT_IMAGE_TAG=local

bash scripts/build-fineract-image.sh
~~~

The source ref is required. Do not use a moving branch for a release build; pin a tag or commit and record its resolved Git SHA.

## Mifos frontend

First place the approved static Mifos web distribution in frontend/. Then build:

~~~bash
export MIFOS_IMAGE_NAME=mifos-web
export MIFOS_IMAGE_TAG=local

bash scripts/build-mifos-image.sh
~~~

The script requires index.html and assets/env.template.js and refuses to package a generated env.js file.
