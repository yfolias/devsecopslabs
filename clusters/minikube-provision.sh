#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="lab-cluster"
CPUS=3
MEMORY="6g"

echo "[+] Checking Minikube cluster: $CLUSTER_NAME"

# Check whether the cluster already exists
if minikube status -p "$CLUSTER_NAME" >/dev/null 2>&1; then
    echo "[+] Minikube cluster '$CLUSTER_NAME' is already running."
    exit 0
fi

echo "[+] Provisioning Minikube cluster: $CLUSTER_NAME"

minikube start \
    --profile "$CLUSTER_NAME" \
    --driver=docker \
    --cpus="$CPUS" \
    --memory="$MEMORY" \
    --cni=cilium

echo "[+] Validating cluster..."

kubectl --context="$CLUSTER_NAME" wait \
    --for=condition=Ready \
    node \
    --all \
    --timeout=120s

kubectl --context="$CLUSTER_NAME" get nodes

echo "[+] Minikube cluster '$CLUSTER_NAME' is ready."