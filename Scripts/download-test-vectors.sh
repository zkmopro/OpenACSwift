#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="Tests/OpenACSwiftTests/TestVectors"
BASE_URL="https://github.com/zkmopro/zkID/releases/download/latest"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

download_and_unzip() {
    local name="$1"   # filename inside zip (without .zip)
    local dest="$DEST_DIR/$name"

    if [ -f "$dest" ]; then
        echo "Already exists: $dest"
        return
    fi

    echo "Downloading ${name}.zip..."
    curl -fL "$BASE_URL/${name}.zip" -o "$TMP/${name}.zip"
    unzip -q "$TMP/${name}.zip" -d "$TMP"
    mv "$TMP/$name" "$dest"
    echo "Saved to $dest"
}

download_and_unzip "sha256rsa4096.r1cs"
download_and_unzip "rs256_4096_proving.key"
download_and_unzip "rs256_4096_verifying.key"
