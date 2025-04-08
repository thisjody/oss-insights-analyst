#!/bin/bash

echo "🔁 Rebuilding secrets/.env from prompts/*.md"

mkdir -p secrets
output="secrets/.env"

# Preserve existing API key if present
if [ -f "$output" ]; then
  api_key=$(grep '^GEMINI_API_KEY=' "$output")
else
  api_key="GEMINI_API_KEY="
fi

echo "$api_key" > "$output"

for f in prompts/*.md; do
  key=$(basename "$f" .md | tr '[:lower:]' '[:upper:]' | tr '-' '_' )
  value=$(awk '{printf "%s\\n", $0}' "$f" | sed 's/"/\\"/g')
  echo "${key}_PROMPT=\"$value\"" >> "$output"
  echo >> "$output"
done

echo "✅ Rebuilt secrets/.env (preserved API key)"

