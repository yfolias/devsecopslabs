#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/tools"

TOOLS=(
    kubectl
    minikube
    vcluster
)

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[+] $tool already installed. Nothing to install."
        continue
    fi

    echo "[+] $tool not found. Installing..."

    bash "$INSTALL_DIR/$tool.sh"
done