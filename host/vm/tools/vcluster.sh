#!/usr/bin/env bash

set -euxo pipefail

VCLUSTER_VERSION="0.37.2"
VCLUSTER_BINARY="vcluster-linux-amd64"

VCLUSTER_URL="https://github.com/loft-sh/vcluster/releases/download/v${VCLUSTER_VERSION}/${VCLUSTER_BINARY}"
VCLUSTER_SHA="e3aec254a8d1ed29e2155172ab5c872dc022f325279dd49dadb01f0887648b4a"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[+] Installing vCluster ${VCLUSTER_VERSION}"

# Download
wget "$VCLUSTER_URL" \
    -O "$TMP_DIR/$VCLUSTER_BINARY"

# Verify
echo "${VCLUSTER_SHA}  $TMP_DIR/$VCLUSTER_BINARY" \
    | sha256sum -c -

# Install
install -m 0755 \
    "$TMP_DIR/$VCLUSTER_BINARY" \
    /usr/local/bin/vcluster

# Validate
echo "[+] Validating vCluster installation"

vcluster --version

echo "[+] vCluster installed successfully"