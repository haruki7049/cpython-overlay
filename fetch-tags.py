#! /usr/bin/env nix-shell
#! nix-shell -i python3.11 -p python311 python311Packages.requests

import requests
import json


def get_all_tags(owner, repo):
    url = f"https://api.github.com/repos/{owner}/{repo}/tags"
    tags = []
    page = 1

    while True:
        response = requests.get(url, params={"page": page})
        if response.status_code == 200:
            tags_page = json.loads(response.text)
            if not tags_page:
                break  # ページが空の場合、ループを終了します。
            tags.extend(tags_page)
            page += 1
        else:
            print(f"Failed to fetch tags: {response.status_code} - {response.text}")
            break

    return tags


def save_to_json(tags, filename):
    with open(filename, "w") as file:
        json.dump(tags, file, indent=2)


if __name__ == "__main__":
    owner = "python"  # リポジトリの所有者のユーザー名または組織名
    repo = "cpython"  # リポジトリ名

    tags = get_all_tags(owner, repo)
    if tags:
        save_to_json(tags, "sources.json")
        print("Tags saved to sources.json!!")
