#!/usr/bin/env bash

set -euo pipefail

KUBECTL_VERSION="v1.37.1"
KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
KUBECTL_SHA_URL="${KUBECTL_URL}.sha256"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[+] Installing kubectl ${KUBECTL_VERSION}"

wget -q "$KUBECTL_URL" \
    -O "$TMP_DIR/kubectl"

wget -q "$KUBECTL_SHA_URL" \
    -O "$TMP_DIR/kubectl.sha256"

echo "$(cat "$TMP_DIR/kubectl.sha256")  $TMP_DIR/kubectl" \
    | sha256sum -c -

install -m 0755 "$TMP_DIR/kubectl" /usr/local/bin/kubectl

echo "[+] Validating kubectl installation"

kubectl version --client