# Mifos frontend build assets

This directory is intentionally not populated with the historical 35 MB frontend build from the private source repository.

The deployed frontend image was built from a static Mifos web application distribution containing at least:

- `index.html`
- `assets/env.template.js`
- application JavaScript, stylesheets, fonts, icons and translations

Place the reviewed, approved distribution in this directory before building `Dockerfile.mifos`. Keep the source release/tag or commit recorded in a separate build manifest.

The startup script generates `assets/env.js` from `assets/env.template.js` using environment variables. The generated file is environment-specific and must not be committed.

Do not assume that a current upstream Mifos web-app release is byte-for-byte equivalent to the deployed frontend. Confirm the source revision and redistribution terms before importing the historical asset bundle.
