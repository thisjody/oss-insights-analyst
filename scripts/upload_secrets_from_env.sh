#!/bin/bash

set -e

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
ENV_FILE="secrets/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ .env file not found at $ENV_FILE"
  exit 1
fi

echo "🚀 Uploading secrets from $ENV_FILE to GCP project: $PROJECT_ID"

# Read key-value pairs from .env
while IFS='=' read -r key value || [[ -n "$key" ]]; do
  # Skip empty lines and comments
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  # Strip quotes
  value="${value%\"}"
  value="${value#\"}"

  # Determine secret name
  secret_name=$(echo "$key" | tr '[:upper:]' '[:lower:]')

  echo "🔐 Uploading $secret_name..."

  # Create secret if it doesn't exist
  if ! gcloud secrets describe "$secret_name" --project "$PROJECT_ID" &>/dev/null; then
    gcloud secrets create "$secret_name" \
      --replication-policy="user-managed" \
      --locations="us-central1" \
      --project="$PROJECT_ID"
  fi

  # Add a new version
  echo -n "$value" | gcloud secrets versions add "$secret_name" \
    --data-file=- \
    --project="$PROJECT_ID"
done < "$ENV_FILE"

echo "✅ All secrets uploaded."

