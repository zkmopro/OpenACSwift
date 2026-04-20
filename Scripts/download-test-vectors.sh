#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="Tests/OpenACSwiftTests/TestVectors"
BASE_URL="https://github.com/zkmopro/zkID/releases/download/latest"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

download_and_gunzip() {
    local name="$1"   # filename with .gz extension
    local folder="${2:-}" # subfolder under DEST_DIR, or empty
    local decompressed="${name%.gz}"
    local dest_dir="$DEST_DIR"
    if [ -n "$folder" ]; then
        dest_dir="$DEST_DIR/$folder"
    fi
    local dest="$dest_dir/$decompressed"

    if [ -f "$dest" ]; then
        echo "Already exists: $dest"
        return
    fi

    mkdir -p "$dest_dir"
    echo "Downloading $name..."
    curl -fL "$BASE_URL/$name" -o "$TMP/$name"
    gunzip -c "$TMP/$name" > "$dest"
    echo "Saved to $dest"
}

download_and_gunzip "cert_chain_rs4096.r1cs.gz"
download_and_gunzip "cert_chain_rs4096_proving.key.gz" "keys"
download_and_gunzip "cert_chain_rs4096_verifying.key.gz" "keys"
download_and_gunzip "device_sig_rs2048.r1cs.gz"
download_and_gunzip "device_sig_rs2048_proving.key.gz" "keys"
download_and_gunzip "device_sig_rs2048_verifying.key.gz" "keys"
