#!/bin/bash

# Usage:
#   bash scripts/deploy_cf.sh agents/agent_vc_strategist/.env.deploy

# --- Step 0: Accept env file path as first argument ---
ENV_FILE="$1"

if [[ -z "$ENV_FILE" ]]; then
  echo "❌ No .env.deploy file provided."
  echo "Usage: bash scripts/deploy_cf.sh path/to/.env.deploy"
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ File not found: $ENV_FILE"
  exit 1
fi

# --- Step 1: Load env vars ---
set -a
source "$ENV_FILE"
set +a

# --- Step 2: Validate ---
REQUIRED_VARS=("GEN2" "RUNTIME" "REGION" "PROJECT_ID" "SOURCE" "CLOUDFUNCTION" "ENTRY_POINT" "MEMORY" "TIMEOUT" "SERVICE_ACCOUNT")
MISSING=()

for VAR in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!VAR}" ]]; then
    MISSING+=("$VAR")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "❌ Missing required environment variables:"
  printf ' - %s\n' "${MISSING[@]}"
  exit 1
fi

echo "🔐 Verifying active GCP project and auth..."
gcloud config get-value project
gcloud auth list --filter=status:ACTIVE

echo "🚀 Deploying Cloud Function: $CLOUDFUNCTION from $SOURCE"

gcloud functions deploy "$CLOUDFUNCTION" \
  "--$GEN2" \
  --runtime="$RUNTIME" \
  --region="$REGION" \
  --source="$SOURCE" \
  --entry-point="$ENTRY_POINT" \
  --trigger-http \
  --memory="$MEMORY" \
  --timeout="$TIMEOUT" \
  --service-account="$SERVICE_ACCOUNT" \
  --allow-unauthenticated \
  --set-env-vars="PROJECT_ID=$PROJECT_ID"

DEPLOY_STATUS=$?

if [[ $DEPLOY_STATUS -eq 0 ]]; then
  echo "✅ Deployment successful!"
  echo "🌐 Trigger URL:"
  gcloud functions describe "$CLOUDFUNCTION" --region="$REGION" "--$GEN2" --format='value(serviceConfig.uri)' || true
else
  echo "❌ Deployment failed."
  exit 1
fi

