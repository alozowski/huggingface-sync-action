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
trap 'rm -rf "${STAGING_DIR}"' EXIT

echo "Staging files in ${STAGING_DIR}"

rsync -a \
  --exclude='.git/' \
  --exclude='.github/' \
  --exclude='.gitignore' \
  --exclude='.hfignore' \
  ./ "${STAGING_DIR}/"

# Safety check: fail fast if staging leaked infra
if [[ -d "${STAGING_DIR}/.github" ]]; then
  echo "ERROR: .github directory leaked into staging area"
  exit 1
fi

# Upload staged contents (true mirror)

echo "Uploading staged contents to Hugging Face..."
uvx hf upload \
  "${HF_REPO_ID}" \
  "${STAGING_DIR}" \
  --repo-type "${REPO_TYPE}" \
  --token "${HF_TOKEN}" \
  --delete="*"

echo "Sync completed successfully"
