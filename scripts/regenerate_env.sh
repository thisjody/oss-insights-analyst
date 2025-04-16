#!/bin/bash

set -euo pipefail

echo "🔁 Rebuilding secrets/.env from prompts/*.md"

output="secrets/.env"
mkdir -p secrets

# === Ensure API key line is preserved or inserted ===
api_key_line="GEMINI_API_KEY="
if [[ -f "$output" ]]; then
  existing=$(grep '^GEMINI_API_KEY=' "$output" || true)
  if [[ -n "$existing" ]]; then
    api_key_line="$existing"
  fi
fi

# === Write the key line first ===
echo "$api_key_line" > "$output"
echo >> "$output"

# === Convert prompt files to escaped .env entries ===
for f in prompts/*.md; do
  var=$(basename "$f" .md | tr '[:lower:]' '[:upper:]' | tr '-' '_' )
  value=$(sed ':a;N;$!ba;s/"/\\"/g;s/\n/\\n/g' "$f")
  echo "${var}_PROMPT=\"$value\"" >> "$output"
  echo >> "$output"
done

echo "✅ Rebuilt secrets/.env (preserved or initialized GEMINI_API_KEY)"
