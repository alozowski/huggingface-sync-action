# huggingface-sync-action

A GitHub Action that syncs your repository to Hugging Face Hub 🤗

Uses the official HF CLI via `uvx` for fast, reliable deployments to Spaces, Models, or Datasets.

## Quick Start

Add your HF token as a GitHub secret (`HF_TOKEN`), then:

```yaml
name: Sync to Hugging Face
on:
  push:
    branches: [main]

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: alozowski/huggingface-sync-action@feature/use-hf-cli-via-uvx
        with:
          github_repo_id: ${{ github.repository }}
          huggingface_repo_id: username/repo-name
          hf_token: ${{ secrets.HF_TOKEN }}
```

## Usage

### All Options

```yaml
- uses: alozowski/huggingface-sync-action@feature/use-hf-cli-via-uvx
  with:
    # Required
    github_repo_id: ${{ github.repository }}
    huggingface_repo_id: username/repo-name
    hf_token: ${{ secrets.HF_TOKEN }}
    
    # Optional
    repo_type: space              # space | model | dataset (default: space)
    space_sdk: gradio             # gradio | streamlit | docker | static (default: gradio)
    private: false                # Create as private (default: false)
    subdirectory: ''              # Sync only this folder (default: '' = root)
```

## Features

**Automatic exclusions** - `.github/`, `.git/`, dotfiles  
**Respects `.gitignore`** - only syncs tracked files  
**True mirroring** - deletes removed files from HF  
**Subdirectory support** - perfect for monorepos  
**Safe** - built-in leak prevention checks  

## What Gets Synced

**✅ Synced:**
- Git-tracked files (committed)
- Regular files (not starting with `.`)
- Files not in `.gitignore`

**❌ Not synced:**
- `.github/` directory
- `.git/` directory  
- Dotfiles (`.env`, `.vscode/`, etc.)
- Ignored files (per `.gitignore`)
- Untracked files
