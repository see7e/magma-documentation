#!/bin/bash

# File: ./.github/workflows/scripts/check_translations.sh
# Description: Ensure any updated docs in /docs have corresponding translations

set -euo pipefail

DEBUG_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --debug)
        DEBUG_MODE=true
        shift
        ;;
        *)
        shift
        ;;
    esac
done

echo "🔍 Checking for missing translations..."
if [[ "$DEBUG_MODE" == true ]]; then
    echo "⚠️ DEBUG MODE: Checking ALL documentation files"
fi

# Get modified files or all files based on debug mode
if [[ "$DEBUG_MODE" == true ]]; then
    # Find all .md and .mdx files in docs (excluding versioned_docs)
    MODIFIED_DOCS=$(find docs -type f \( -name "*.md" -o -name "*.mdx" \) -not -path "versioned_docs/*")
else
    # Get files changed compared to main branch
    BASE_REF="${GITHUB_BASE_REF:-origin/main}"
    MODIFIED_DOCS=$(git diff --name-only "$BASE_REF...HEAD" -- 'docs/**/*.md' 'docs/**/*.mdx' ':!versioned_docs/**')
fi

if [[ -z "$MODIFIED_DOCS" ]]; then
    echo "✅ No files to check."
    exit 0
fi

MISSING_TRANSLATIONS=()

for file in $MODIFIED_DOCS; do
    # Only process existing files (find might return deleted files in diff)
    if [[ ! -f "$file" ]]; then continue; fi
    
    REL_PATH=${file#docs/}
    echo "Checking translations for: $REL_PATH"
    
    for lang in $(ls i18n); do
        TRANSLATED_FILE="i18n/$lang/docusaurus-plugin-content-docs/current/$REL_PATH"
        if [[ ! -f "$TRANSLATED_FILE" ]]; then
            MISSING_TRANSLATIONS+=("$TRANSLATED_FILE")
        fi
    done
done

if [[ ${#MISSING_TRANSLATIONS[@]} -eq 0 ]]; then
    echo "✅ All translations present."
    exit 0
else
    echo "❌ Missing translations:"
    for file in "${MISSING_TRANSLATIONS[@]}"; do
        echo "- $file"
    done
    exit 1
fi
