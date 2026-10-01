#!/bin/bash

VM_NAME=$1

echo "Stopping Lima VM: $VM_name"
limactl stop $VM_NAME

echo "Deleting Lima VM: $VM_NAME"
limactl delete "$VM_NAME"

echo "Cleanup $VM_NAME" 
rm -rf ~/.lima/$VM_NAME
rm -rf ~/.cache/lima