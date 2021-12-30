#!/usr/bin/env bash
#
# Upload artifacts to GitHub Actions.
#
# Based on: https://gist.github.com/schell/2fe896953b6728cc3c5d8d5f9f3a17a3
#
# Requires curl and jq on PATH

set -euo pipefail

# Args:
#   token: GitHub API user token
#   repo: GitHub username/reponame
#   file: Path to the asset file to upload
#   name: Name to use for the uploaded asset
upload_release_file() {
    # Args
    token=$1
    repo=$2
    file=$3
    name=$4

    upload_url=$(curl --silent "https://api.github.com/repos/$repo/releases/latest" | jq -r .upload_url | cut -d"{" -f'1')
    http_code=$(
        curl -s -o upload.json -w '%{http_code}' \
            --request POST \
            --header "Authorization: Bearer $token" \
            --header "Content-Type: application/octet-stream" \
            --data-binary @\""$file"\" "$upload_url?name=$name"
    )
    if [ "$http_code" == "201" ]; then
        echo "Asset $name uploaded:"
        jq -r .browser_download_url upload.json
    else
        echo "Asset upload failed with code '$http_code':"
        cat upload.json
        return 1
    fi
}
