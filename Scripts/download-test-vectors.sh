#!/usr/bin/env bash
set -euo pipefail

CIRCUIT_NAME=sha256rsa4096
DEST="Tests/OpenACSwiftTests/TestVectors/${CIRCUIT_NAME}.r1cs"
URL="https://github.com/zkmopro/zkID/releases/download/latest/${CIRCUIT_NAME}.r1cs.zip"

if [ -f "$DEST" ]; then
    echo "Already exists: $DEST"
    exit 0
fi

echo "Downloading ${CIRCUIT_NAME}.r1cs.zip..."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fL "$URL" -o "$TMP/${CIRCUIT_NAME}.r1cs.zip"
unzip -q "$TMP/${CIRCUIT_NAME}.r1cs.zip" -d "$TMP"
mv "$TMP/${CIRCUIT_NAME}.r1cs" "$DEST"

echo "Saved to $DEST"
