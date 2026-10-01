#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="/opt/devsecopslabs"

SCENARIO_NAME="00_setup"
VCLUSTER_NAME="vlab-cluster-1"
HOST_CLUSTER="lab-cluster"

VCLUSTER_CREATE="$REPO_ROOT/clusters/virtual/create.sh"
WORKLOAD_MANIFESTS="$REPO_ROOT/workloads/${SCENARIO_NAME}_lab_files/manifests"

echo "[+] Setting up scenario: $SCENARIO_NAME"

# Verify Minikube host cluster

echo "[+] Checking host cluster: $HOST_CLUSTER"

if ! minikube status -p "$HOST_CLUSTER" >/dev/null 2>&1; then
    echo "[-] Minikube host cluster is not running."
    exit 1
fi

echo "[+] Minikube host cluster is running."

# Create vCluster

echo "[+] Creating vCluster: $VCLUSTER_NAME"

bash "$VCLUSTER_CREATE" "$VCLUSTER_NAME"

# Connect to vCluster

echo "[+] Connecting to vCluster: $VCLUSTER_NAME"

vcluster connect "$VCLUSTER_NAME"

# Safety check

CURRENT_CONTEXT="$(kubectl config current-context)"

echo "[+] Current Kubernetes context: $CURRENT_CONTEXT"

if [[ "$CURRENT_CONTEXT" == "$HOST_CLUSTER" ]]; then
    echo "[-] Refusing to deploy workload to host cluster."
    exit 1
fi

# Verify vCluster

echo "[+] Verifying vCluster connection..."

kubectl cluster-info >/dev/null

# Deploy workload into vCluster

echo "[+] Deploying workload manifests..."

kubectl apply -f "$WORKLOAD_MANIFESTS"

# Validate

echo "[+] Waiting for deployments..."

kubectl wait \
    --for=condition=Available \
    deployment \
    --all \
    --timeout=120s

echo
echo "[+] Scenario resources:"

kubectl get pods

echo
echo "[+] Scenario '$SCENARIO_NAME' is ready."