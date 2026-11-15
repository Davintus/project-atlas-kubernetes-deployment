#!/usr/bin/env bash
set -Eeuo pipefail

FRONTEND_DIR="${1:-frontend}"

required_files=(
  "$FRONTEND_DIR/index.html"
  "$FRONTEND_DIR/assets/env.template.js"
)

for file in "${required_files[@]}"; do
  if [[ ! -s "$file" ]]; then
    echo "ERROR: required Mifos frontend file is missing or empty: $file" >&2
    exit 1
  fi
done

if [[ -e "$FRONTEND_DIR/assets/env.js" ]]; then
  echo "ERROR: generated env.js must not be committed; it is created by the container at runtime." >&2
  exit 1
fi

unsafe_file="$(find "$FRONTEND_DIR" -type f \( \
  -iname '*.env' -o -iname '.env' -o -iname '*.pem' -o -iname '*.key' -o \
  -iname '*.p12' -o -iname '*.pfx' -o -iname '*.sql' -o -iname '*kubeconfig*' \
\) -print -quit)"

if [[ -n "$unsafe_file" ]]; then
  echo "ERROR: environment, credential, certificate, kubeconfig or database file found: $unsafe_file" >&2
  exit 1
fi

grep -Fq 'Mozilla Public License' "$FRONTEND_DIR/assets/env.template.js" || {
  echo "ERROR: expected Mifos MPL licence header was not found in env.template.js." >&2
  exit 1
}

if [[ ! -s "$FRONTEND_DIR/assets/tinymce/license.md" || ! -s "$FRONTEND_DIR/assets/tinymce/notices.txt" ]]; then
  echo "ERROR: bundled TinyMCE licence/notice files are missing." >&2
  exit 1
fi

file_count="$(find "$FRONTEND_DIR" -type f | wc -l | tr -d ' ')"
total_bytes="$(du -sb "$FRONTEND_DIR" | awk '{print $1}')"

echo "Mifos frontend checks passed."
echo "Files: $file_count"
echo "Bytes: $total_bytes"
