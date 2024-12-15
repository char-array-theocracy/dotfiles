#!/usr/bin/env bash

VM_LIST=$(virsh -c qemu:///system list --all --name)

if [ -z "$VM_LIST" ]; then
    echo "No virtual machines found under qemu:///system."
    exit 1
fi

echo "VM_LIST is: $VM_LIST" >&2

SELECTED_VM=$(printf "%s\n" "$VM_LIST" | tofi)

if [ -z "$SELECTED_VM" ]; then
    echo "No VM selected or selection canceled."
    exit 0
fi

RUNNING=$(virsh -c qemu:///system list --name --state-running | grep -w "$SELECTED_VM")

if [ -z "$RUNNING" ]; then
    virsh -c qemu:///system start "$SELECTED_VM"
    sleep 3
fi

virt-viewer --connect qemu:///system "$SELECTED_VM"

