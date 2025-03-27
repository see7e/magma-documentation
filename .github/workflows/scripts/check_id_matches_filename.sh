# File: ./scripts/docs/check_id_matches_filename.sh
# Description: Ensure each doc file's frontmatter id matches its filename

set -euo pipefail

echo "🔍 Checking if doc IDs match filenames..."

MISMATCHES=()

find docs -name '*.md' -o -name '*.mdx' | while read -r file; do
  filename=$(basename "$file")
  expected_id="${filename%.*}"
  found_id=$(grep -E '^id: ' "$file" | head -n 1 | cut -d ' ' -f2- || echo "")

  if [ -n "$found_id" ] && [ "$found_id" != "$expected_id" ]; then
    MISMATCHES+=("$file (id: $found_id, expected: $expected_id)")
  fi

done

if [ ${#MISMATCHES[@]} -eq 0 ]; then
  echo "✅ All doc IDs match filenames."
else
  echo "❌ ID/Filename mismatches found:"
  for msg in "${MISMATCHES[@]}"; do
    echo "- $msg"
  done
  exit 1
fi
