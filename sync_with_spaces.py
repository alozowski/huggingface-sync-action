from huggingface_hub import create_repo, upload_folder, whoami


def _to_bool(value):
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        return value.lower() in {"1", "true", "yes", "y"}
    return False


def main(
    repo_id: str,
    directory: str,
    token: str,
    repo_type: str = "space",
    space_sdk: str = "gradio",
    private=False,  # Fire will pass str, so let's normalize manually
):
    print("Syncing with Hugging Face Hub...")

    private = _to_bool(private)

    if "/" not in repo_id:
        username = whoami(token=token)["name"]
        repo_id = f"{username}/{repo_id}"

    print(f"\t- Repo ID: {repo_id}")
    print(f"\t- Directory: {directory}")
    print(f"\t- Private: {private}")

    url = create_repo(
        repo_id=repo_id,
        token=token,
        exist_ok=True,
        repo_type=repo_type,
        space_sdk=space_sdk if repo_type == "space" else None,
        private=private,
    )
    print(f"\t- Repo URL: {url}")

    commit_url = upload_folder(
        folder_path=directory,
        repo_id=repo_id,
        repo_type=repo_type,
        token=token,
        commit_message="Sync from GitHub via huggingface-sync-action",
        ignore_patterns=["*.git*", "*.github*", "*README.md*"],
    )
    print(f"\t- Repo synced: {commit_url}")


if __name__ == "__main__":
    from fire import Fire
    Fire(main)
