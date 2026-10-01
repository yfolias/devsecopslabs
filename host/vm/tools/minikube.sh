#!/usr/bin/env bash

set -euo pipefail

MINIKUBE_VERSION="v1.39.0"
MINIKUBE_BINARY="minikube-linux-amd64"

MINIKUBE_URL="https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/${MINIKUBE_BINARY}"
MINIKUBE_SHA_URL="${MINIKUBE_URL}.sha256"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[+] Installing minikube ${MINIKUBE_VERSION}"

wget -q "$MINIKUBE_URL" \
    -O "$TMP_DIR/$MINIKUBE_BINARY"

wget -q "$MINIKUBE_SHA_URL" \
    -O "$TMP_DIR/$MINIKUBE_BINARY.sha256"

echo "$(cat "$TMP_DIR/$MINIKUBE_BINARY.sha256")  $TMP_DIR/$MINIKUBE_BINARY" \
    | sha256sum -c -

install -m 0755 \
    "$TMP_DIR/$MINIKUBE_BINARY" \
    /usr/local/bin/minikube

echo "[+] Validating minikube installation"

minikube version