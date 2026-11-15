# Mifos frontend distribution

The original static Mifos frontend distribution has been supplied and reviewed separately. Its source checkout is:

- Repository: https://github.com/openMF/web-app
- Commit: `4f5be2d5040e37ae26adef023c610028cbf34343`
- `git describe`: `v1.0.0-fineract1.14-563-g4f5be2d50`
- Package version: `1.0.0`
- Licence: MPL-2.0

The reviewed archive contained 468 files (approximately 34.6 MB uncompressed), including `index.html` and `assets/env.template.js`. It did not contain the generated `assets/env.js`. The archive SHA-256 is recorded in [build provenance](../docs/build-provenance.md).

**Import status:** the archive contents have not yet been committed to this GitHub branch. The static files must be transferred into this directory from the reviewed archive before `scripts/build-mifos-image.sh` can build the real frontend image.

## Import on a Git-enabled workspace

From a clean clone of this branch, place the reviewed archive next to the repository root and run:

~~~bash
sha256sum mifos-frontend-review.tar.gz
# Confirm the result matches the SHA-256 in docs/build-provenance.md.

tar -xzf mifos-frontend-review.tar.gz -C .
bash scripts/validate-mifos-frontend.sh frontend

git status --short
git diff --check
git add frontend/
git commit -m "Add reviewed Mifos frontend distribution"
git push origin docs/sanitised-project-baseline
~~~

The archive already has a top-level `frontend/` directory, so extract it at the repository root. Review the staged file list before committing.

## Runtime configuration

The container entrypoint generates `assets/env.js` from `assets/env.template.js` when the container starts. The generated file is environment-specific and must never be committed.

The frontend template contains browser-visible API-key properties for optional integrations. The container deliberately forces those key values to empty and disables the associated integrations by default. **Do not configure confidential API keys in frontend environment variables:** values written to `env.js` are visible to every user who can load the web application. Use a trusted backend proxy where an integration requires a confidential key.

The bundled TinyMCE licence and notice files must remain with the distribution.
