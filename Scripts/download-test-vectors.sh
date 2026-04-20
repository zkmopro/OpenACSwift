#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="Tests/OpenACSwiftTests/TestVectors"
BASE_URL="https://github.com/zkmopro/zkID/releases/download/latest"
SMT_BASE_URL="https://github.com/moven0831/moica-revocation-smt/releases/download/snapshot-latest"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

download_and_gunzip() {
    local url="$1"   # URL to download
    local folder="${2:-}" # subfolder under DEST_DIR, or empty
    local decompressed="${url##*/}"
    decompressed="${decompressed%.gz}"
    local dest="$DEST_DIR/${folder:+$folder/}$decompressed"

    if [ -f "$dest" ]; then
        echo "Already exists: $dest"
        return
    else
        mkdir -p "$(dirname "$dest")"
        echo "Downloading $url -> $dest"
        curl -fL "$url" -o "$TMP/$decompressed"
        gunzip -c "$TMP/$decompressed" > "$dest"
        echo "Saved to $dest"
    fi
}

download() {
    local url="$1"
    local folder="${2:-}"
    local filename="${url##*/}"
    local dest="$DEST_DIR/${folder:+$folder/}$filename"

    if [ -f "$dest" ]; then
        echo "Already exists: $dest"
    else
        mkdir -p "$(dirname "$dest")"
        echo "Downloading $url -> $dest"
        curl -fL "$url" -o "$dest"
        echo "Saved to $dest"
    fi
}

download_and_gunzip "$BASE_URL/cert_chain_rs4096.r1cs.gz"
download_and_gunzip "$BASE_URL/cert_chain_rs4096_proving.key.gz" "keys"
download_and_gunzip "$BASE_URL/cert_chain_rs4096_verifying.key.gz" "keys"
download_and_gunzip "$BASE_URL/device_sig_rs2048.r1cs.gz"
download_and_gunzip "$BASE_URL/device_sig_rs2048_proving.key.gz" "keys"
download_and_gunzip "$BASE_URL/device_sig_rs2048_verifying.key.gz" "keys"
download "$SMT_BASE_URL/g3-tree-snapshot.json.gz"