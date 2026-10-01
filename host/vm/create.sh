#!/bin/bash

set -e

VM_NAME=$1
VM_CONFIG="./host/vm/lab-env.yaml"

echo "Creating VM: $VM_NAME"
limactl create -y --name=$VM_NAME $VM_CONFIG --debug

echo "Starting VM: $VM_NAME"
limactl start --name=$VM_NAME 