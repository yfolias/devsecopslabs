VM_NAME ?= minikube
LIMA_SSH = ssh -F ~/.lima/$(VM_NAME)/ssh.config

.PHONY: vm-create vm-delete vm-start vm-stop vm-shell

vm-create:
	./host/vm/create.sh ${VM_NAME}
 	# Workaround to drop the SSH master opened before provisioning so new sessions get the docker group
	-@$(LIMA_SSH) -O exit lima-$(VM_NAME) 2>/dev/null
	@limactl shell $(VM_NAME) docker ps >/dev/null && echo "docker OK in $(VM_NAME)"

vm-start:
	limactl start ${VM_NAME}

vm-stop:
	limactl stop ${VM_NAME}

vm-delete:
	./host/vm/delete.sh ${VM_NAME}

vm-shell:
	limactl shell $(VM_NAME)