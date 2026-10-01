#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <vcluster-name>"
    exit 1
fi

VCLUSTER_NAME="$1"
HOST_CLUSTER="lab-cluster"
NAMESPACE="vcluster-${VCLUSTER_NAME}"

echo "[+] Creating vCluster: $VCLUSTER_NAME"
echo "[+] Host cluster: $HOST_CLUSTER"
echo "[+] Namespace: $NAMESPACE"

# Ensure we're targeting the Minikube host cluster
kubectl config use-context "$HOST_CLUSTER" >/dev/null

# Create the vCluster
vcluster create "$VCLUSTER_NAME" \
    --namespace "$NAMESPACE"

echo "[+] vCluster '$VCLUSTER_NAME' created."

# Verify that vcluster switched kubectl to the virtual cluster
echo "[+] Current context:"
kubectl config current-context

echo "[+] Checking vCluster API..."

kubectl cluster-info >/dev/null

echo "[+] vCluster '$VCLUSTER_NAME' is ready."