#!/bin/bash

# File: ./scripts/docs/check_translations.sh
# Description: Ensure any updated docs in /docs have a corresponding translation in /i18n

set -euo pipefail

echo "🔍 Checking for missing translations..."

# Scan for modified Markdown files in docs (excluding versioned_docs)
MODIFIED_DOCS=$(git diff --name-only origin/master...HEAD -- 'docs/**/*.md' 'docs/**/*.mdx' ':!versioned_docs/**')

if [ -z "$MODIFIED_DOCS" ]; then
  echo "✅ No modified docs to check."
  exit 0
fi

MISSING_TRANSLATIONS=()

for file in $MODIFIED_DOCS; do
  REL_PATH=${file#docs/}
  for lang in $(ls i18n); do
    TRANSLATED_FILE="i18n/$lang/docusaurus-plugin-content-docs/current/$REL_PATH"
    if [ ! -f "$TRANSLATED_FILE" ]; then
      MISSING_TRANSLATIONS+=("$TRANSLATED_FILE")
    fi
  done

done

if [ ${#MISSING_TRANSLATIONS[@]} -eq 0 ]; then
  echo "✅ All translations present."
else
  echo "❌ Missing translations:"
  for file in "${MISSING_TRANSLATIONS[@]}"; do
    echo "- $file"
  done
  exit 1
fi