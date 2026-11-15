# Upstream components and source provenance

This portfolio repository does not copy the upstream Fineract or Mifos application source trees.

- Apache Fineract source: https://github.com/apache/fineract (Apache License 2.0)
- Mifos X web application: https://github.com/openMF/web-app (Mozilla Public License 2.0)
- Mifos X project information: https://mifos.org/mifos-x/

## Build provenance

The deployed pipeline cloned Apache Fineract source during the build, added MariaDB Connector/J to the Jib runtime classpath, and built the Fineract API image. The exact source commit used for the historic production image still needs to be recorded from the original build metadata.

The frontend image was built from a static Mifos distribution present in the private `fineract-mono` repository. Its exact upstream release/tag/commit has not yet been verified here. The frontend bundle is therefore intentionally not copied to this repository yet.

Before importing the historic frontend distribution, verify its source revision, license notice and permission to redistribute it in a public portfolio repository. Do not silently replace it with the latest upstream build: that may not match the deployed application.
