#!/usr/bin/env bash
set -euo pipefail

echo "Syncing GitHub repo to Hugging Face"
echo "  Repo ID: ${HF_REPO_ID}"
echo "  Repo type: ${REPO_TYPE}"
echo "  Private: ${PRIVATE}"

# Create (or reuse) the HF repository

CREATE_ARGS=(
  hf repo create "${HF_REPO_ID}"
  --repo-type "${REPO_TYPE}"
  --token "${HF_TOKEN}"
  --exist-ok
)

if [[ "${PRIVATE}" == "true" ]]; then
  CREATE_ARGS+=(--private)
fi

if [[ "${REPO_TYPE}" == "space" && -n "${SPACE_SDK:-}" ]]; then
  CREATE_ARGS+=(--space-sdk "${SPACE_SDK}")
fi

echo "Creating or updating Hugging Face repo..."
uvx "${CREATE_ARGS[@]}"

# Stage files into a clean directory before upload

STAGING_DIR="$(mktemp -d)"
echo "Staging files in ${STAGING_DIR}"

rsync -a \
  --delete \
  --exclude='.git/' \
  --exclude='.github/' \
  --exclude='.gitignore' \
  --exclude='.hfignore' \
  ./ "${STAGING_DIR}/"

# Upload staged contents

echo "Uploading staged contents to Hugging Face..."
uvx hf upload \
  "${HF_REPO_ID}" \
  "${STAGING_DIR}" \
  --repo-type "${REPO_TYPE}" \
  --token "${HF_TOKEN}" \
  --delete="*"

echo "Sync completed successfully"
