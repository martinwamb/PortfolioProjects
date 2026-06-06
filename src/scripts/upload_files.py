import os
import sys

from git import Repo


def add_files_to_repo(repo_path, files_to_add):
    repo = Repo(repo_path)

    missing = [f for f in files_to_add if not os.path.exists(os.path.join(repo_path, f))]
    if missing:
        print(f"Warning: files not found and skipped: {missing}")
        files_to_add = [f for f in files_to_add if f not in missing]

    if not files_to_add:
        print("No files to add.")
        return

    for f in files_to_add:
        repo.git.add(f)
        print(f"Staged: {f}")

    repo.git.commit(m="Add files via upload")
    print("Committed successfully.")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python upload_files.py <file1> [file2] ...")
        sys.exit(1)

    repo_path = os.getenv("REPO_PATH", ".")
    add_files_to_repo(repo_path, sys.argv[1:])
