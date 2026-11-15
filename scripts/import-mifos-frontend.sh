#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE="${1:-}"
EXPECTED_SHA256="fd6987552194f07a1617ca366d955b20ebbb8517080884a4b29ab625c415b722"

if [[ -z "$ARCHIVE" || ! -f "$ARCHIVE" ]]; then
  echo "Usage: $0 /path/to/mifos-frontend-review.tar.gz" >&2
  exit 2
fi

command -v sha256sum >/dev/null
command -v tar >/dev/null

ACTUAL_SHA256="$(sha256sum "$ARCHIVE" | awk '{print $1}')"
if [[ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]]; then
  echo "ERROR: archive SHA-256 does not match the reviewed Mifos distribution." >&2
  echo "Expected: $EXPECTED_SHA256" >&2
  echo "Actual:   $ACTUAL_SHA256" >&2
  exit 1
fi

# Refuse unexpected top-level entries and path traversal before extraction.
while IFS= read -r member; do
  case "$member" in
    frontend|frontend/*) ;;
    *)
      echo "ERROR: unexpected archive path: $member" >&2
      exit 1
      ;;
  esac

  case "$member" in
    /*|../*|*/../*|*/..|*//*|*/./*|*/.)
      echo "ERROR: unsafe archive path: $member" >&2
      exit 1
      ;;
  esac
done < <(tar -tzf "$ARCHIVE")

echo "Archive checksum and paths verified."
tar -xzf "$ARCHIVE" -C "$ROOT_DIR" --no-same-owner

bash "$ROOT_DIR/scripts/validate-mifos-frontend.sh" "$ROOT_DIR/frontend"

echo
echo "Frontend files extracted. Review the complete staged/untracked file list before committing:"
git -C "$ROOT_DIR" status --short -- frontend/
echo
echo "The import script does not commit or push automatically."
echo "Review, then run:"
echo "  git add frontend/"
echo "  git diff --cached --stat"
echo "  git diff --cached --check"
echo "  git commit -m 'Add reviewed Mifos frontend distribution'"
echo "  git push origin <your-review-branch>"
