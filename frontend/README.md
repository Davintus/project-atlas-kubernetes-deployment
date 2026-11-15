# Mifos frontend distribution

The historical Mifos static frontend distribution has been supplied and reviewed. Its source checkout is:

- Repository: https://github.com/openMF/web-app
- Commit: `4f5be2d5040e37ae26adef023c610028cbf34343`
- `git describe`: `v1.0.0-fineract1.14-563-g4f5be2d50`
- Package version: `1.0.0`
- Licence: MPL-2.0

The archive contains 406 regular files across 468 archive entries (approximately 34.6 MB uncompressed), including `index.html` and `assets/env.template.js`. It does not contain the generated `assets/env.js`. Its SHA-256 is recorded in [build provenance](../docs/build-provenance.md).

**Import status:** the static files have not yet been committed to this GitHub branch. The checksum-verified import script checks the exact reviewed archive before extraction.

## Import on a Git-enabled workspace

Clone the private Project Atlas branch, copy the supplied archive onto that workspace, and run:

~~~bash
git clone --branch docs/sanitised-project-baseline \
  git@github.com:Davintus/project-atlas-kubernetes-deployment.git
cd project-atlas-kubernetes-deployment

bash scripts/import-mifos-frontend.sh /path/to/mifos-frontend-review.tar.gz
~~~

The archive has a top-level `frontend/` directory, so the import script extracts it at the repository root. The script verifies the SHA-256 and archive paths, then runs the frontend validation script.

Review the staged/untracked files. The import script does not commit or push automatically:

~~~bash
git status --short -- frontend/
git add frontend/
git diff --cached --stat
git diff --cached --check
git commit -m "Add reviewed Mifos frontend distribution"
git push origin docs/sanitised-project-baseline
~~~

## Runtime configuration

The container entrypoint generates `assets/env.js` from `assets/env.template.js` when the container starts. The generated file is environment-specific and must never be committed.

The frontend template includes browser-visible API-key properties for optional integrations. The entrypoint deliberately forces both API-key properties to empty and keeps those integrations disabled by default. **Do not configure confidential API keys in frontend environment variables:** values written to `env.js` are visible to every user who can load the web application. Use an approved trusted backend proxy for integrations requiring confidential keys.

The bundled TinyMCE licence and notice files must remain with the distribution.
