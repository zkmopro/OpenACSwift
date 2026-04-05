#!/usr/bin/env bash
set -euo pipefail

DEST="Tests/OpenACSwiftTests/TestVectors/rs256.r1cs"
URL="https://github.com/zkmopro/zkID/releases/download/latest/rs256.r1cs.zip"

if [ -f "$DEST" ]; then
    echo "Already exists: $DEST"
    exit 0
fi

echo "Downloading rs256.r1cs.zip..."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fL "$URL" -o "$TMP/rs256.r1cs.zip"
unzip -q "$TMP/rs256.r1cs.zip" -d "$TMP"
mv "$TMP/rs256.r1cs" "$DEST"

echo "Saved to $DEST"
