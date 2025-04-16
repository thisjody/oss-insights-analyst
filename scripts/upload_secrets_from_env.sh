#!/bin/bash

set -e

echo "🚀 Uploading secrets from secrets/.env to GCP project: oss-insights-analyst"

ENV_FILE="secrets/.env"
PROJECT_ID="oss-insights-analyst"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Missing $ENV_FILE"
  exit 1
fi

# Load GEMINI_API_KEY normally
GEMINI_API_KEY=$(grep '^GEMINI_API_KEY=' "$ENV_FILE" | cut -d '=' -f2-)

# Load all prompts from the .env
declare -A secrets

while IFS='=' read -r key value; do
  if [[ "$key" == *_PROMPT ]]; then
    # Join multiline prompt strings
    buffer="$value"
    while [[ "$buffer" != *\" ]]; do
      read -r continuation
      buffer+=$'\n'"$continuation"
    done
    # Remove surrounding quotes
    clean_value=$(echo "$buffer" | sed '1s/^"//' | sed '$s/"$//')
    secrets["$key"]="$clean_value"
  fi
done < <(grep -E '^[A-Z_]+_PROMPT=' "$ENV_FILE")

# Add the API key explicitly
secrets["gemini_api_key"]="$GEMINI_API_KEY"

# Upload to GCP
for key in "${!secrets[@]}"; do
  value="${secrets[$key]}"
  if [[ -z "$value" ]]; then
    echo "⚠️  Skipping empty secret: $key"
    continue
  fi

  echo "🔐 Uploading $key..."

  # Create the secret if it doesn’t exist
  if ! gcloud secrets describe "$key" --project="$PROJECT_ID" &>/dev/null; then
    gcloud secrets create "$key" \
      --replication-policy="user-managed" \
      --locations="us-central1" \
      --project="$PROJECT_ID"
  fi

  # Upload the new secret version
  echo -n "$value" | gcloud secrets versions add "$key" \
    --data-file=- \
    --project="$PROJECT_ID"
done

echo "✅ All secrets uploaded."
