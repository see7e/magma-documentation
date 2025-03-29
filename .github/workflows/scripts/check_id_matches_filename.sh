#!/bin/bash

# File: ./scripts/docs/check_id_matches_filename.sh
# Description: Ensure each doc file's frontmatter id matches its filename
# Is possible to add more checks to the Front Matter infromations

set -euo pipefail

DEBUG_MODE=false
DOCS_DIR="docusaurus/docs"  # Updated path

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

echo "🔍 Checking if doc IDs match filenames in $DOCS_DIR..."

if [[ ! -d "$DOCS_DIR" ]]; then
    echo "❌ Error: Documentation directory not found at $DOCS_DIR"
    exit 1
fi

MISMATCHES=()
CHECKED_FILES=0

find "$DOCS_DIR" -type \( -name '*.md' -o -name '*.mdx' \) | while read -r file; do
    CHECKED_FILES=$((CHECKED_FILES + 1))
    filename=$(basename "$file")
    expected_id="${filename%.*}"
    found_id=$(grep -E '^id: ' "$file" | head -n 1 | cut -d ' ' -f2- || echo "")

    if [[ "$DEBUG_MODE" == true ]]; then
        echo "🔎 Checking: ${file#$DOCS_DIR/} (ID: $found_id)"
    fi

    if [ -n "$found_id" ] && [ "$found_id" != "$expected_id" ]; then
        MISMATCHES+=("${file#$DOCS_DIR/} (id: $found_id, expected: $expected_id)")
    fi
done

if [ ${#MISMATCHES[@]} -eq 0 ]; then
    echo "✅ All doc IDs match filenames (checked $CHECKED_FILES files)."
else
    echo "❌ ID/Filename mismatches found:"
    for msg in "${MISMATCHES[@]}"; do
        echo "- $msg"
    done
    exit 1
fi