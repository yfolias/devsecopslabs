# DevSecOps Labs

A collection of hands-on labs for exploring, breaking and securing cloud-native environments.

The goal of this project is to provide reproducible security scenarios built around Kubernetes and modern software delivery practices, with an emphasis on understanding how individual weaknesses can be discovered, exploited, chained and ultimately mitigated.

Rather than requiring a permanent Kubernetes environment, the project builds disposable lab infrastructure locally using Lima, Minikube and vCluster.

> Build it. Break it. Secure it.

---

## Architecture

The lab environment currently uses a shared-node vCluster architecture.

```text
Physical Host
│
└── Lima VM
    │
    └── Minikube
        │
        └── vCluster
            │
            └── Lab Workloads
```

### Lima

[Lima](https://lima-vm.io/) provides the Linux virtual machine used as the lab environment.

This keeps the Kubernetes environment separated from the physical host and makes the entire lab disposable and reproducible.

### Minikube

[Minikube](https://minikube.sigs.k8s.io/) provides the host Kubernetes cluster inside the Lima VM.

The default host cluster is:

```text
lab-cluster
```

### vCluster

[vCluster](https://www.vcluster.com/) provides lightweight virtual Kubernetes clusters inside Minikube.

Each scenario can use its own vCluster, providing a separate Kubernetes API and logical cluster environment without requiring another complete Kubernetes cluster.

The current implementation uses **shared-node mode**.

This means the vCluster provides logical Kubernetes isolation while workloads ultimately execute using the underlying Minikube worker infrastructure.

This distinction is intentional and will also be explored from a security perspective throughout the project.

For more information about the design, see:

```text
docs/architecture.md
```

---

## Repository Structure

```text
devsecopslabs/
│
├── clusters/
│   ├── virtual/
│   │   ├── create.sh
│   │   └── delete.sh
│   │
│   └── minikube-provision.sh
│
├── docs/
│   ├── architecture.md
│   └── diagram.png
│
├── host/
│   └── vm/
│       ├── tools/
│       ├── create.sh
│       ├── delete.sh
│       ├── lab-env.yaml
│       └── tools-install.sh
│
├── scenarios/
│   ├── 00_setup/
│   │   ├── manifests/
│   │   └── setup.sh
│   │
│   ├── resources/
│   └── list.md
│
├── workloads/
│   └── 00_setup_lab_files/
│       └── manifests/
│           └── deployment.yaml
│
├── install.sh
├── Makefile
├── LICENSE
└── README.md
```

### `host/`

Contains the infrastructure required to create the underlying lab environment.

`host/vm/lab-env.yaml` defines the Lima VM, while the accompanying scripts handle creation, deletion and installation of the required tooling.

### `clusters/`

Contains Kubernetes cluster lifecycle tooling.

`minikube-provision.sh` creates the host Kubernetes cluster, while `clusters/virtual/` manages the vClusters used by individual scenarios.

### `scenarios/`

Contains the individual security labs.

Each scenario owns its setup and scenario-specific Kubernetes resources.

For example:

```text
scenarios/00_setup/setup.sh
```

is responsible for preparing the initial test scenario.

### `workloads/`

Contains the applications and Kubernetes workloads used by scenarios.

Keeping workloads separate from scenarios allows applications to be reused across multiple security exercises.

### `docs/`

Contains architecture documentation and diagrams describing how the lab environment works.

---

## Lab Lifecycle

The environment is intentionally layered.

```text
Host
  │
  ▼
Lima VM
  │
  ▼
Minikube
  │
  ▼
vCluster
  │
  ▼
Scenario Workload
```

Each layer has a specific responsibility.

The **host layer** creates the disposable Linux environment.

The **cluster layer** creates the Kubernetes infrastructure.

The **scenario layer** creates a dedicated virtual Kubernetes environment and deploys the resources required by the exercise.

This keeps infrastructure provisioning separate from the security scenarios themselves.

---

## Getting Started

### Requirements

The physical host requires:

- Lima
- QEMU
- Git
- Bash

The remaining lab tooling is installed inside the Lima VM.

This currently includes:

- Docker
- kubectl
- Minikube
- vCluster
- nmap

---

## Installation

Clone the repository:

```bash
git clone https://github.com/yfolias/devsecopslabs.git
cd devsecopslabs
```

Run the installer:

```bash
make vm-create VM_NAME=lab-00
```

Alternatively, the individual infrastructure components can be managed directly through the scripts contained in the repository.

---

## Creating the Lab Environment

Create the Lima VM:

```bash
./host/vm/create.sh
```

The VM is configured using:

```text
host/vm/lab-env.yaml
```

The repository is mounted inside the VM at:

```text
/opt/devsecopslabs
```

The mount is read-only by design. Development happens on the physical host while the VM consumes the lab files.

Once provisioned, the environment contains the Minikube host cluster:

```text
lab-cluster
```

Verify it with:

```bash
kubectl config use-context lab-cluster
kubectl get nodes
```

---

## Running a Scenario

Scenarios provide their own setup scripts.

For example:

```bash
cd /opt/devsecopslabs/scenarios/00_setup

bash setup.sh
```

The setup process currently performs the following flow:

```text
Verify Minikube
      │
      ▼
Create vCluster
      │
      ▼
Connect to vCluster
      │
      ▼
Deploy Workload
      │
      ▼
Validate Scenario
```

Scenario workloads are deployed into the **virtual Kubernetes cluster**, rather than directly into the Minikube host cluster.

This distinction is important because the host cluster is infrastructure supporting the lab, while the vCluster represents the Kubernetes environment being tested.

---

## Kubernetes Contexts

You can inspect the available Kubernetes contexts with:

```bash
kubectl config get-contexts
```

Check the active context:

```bash
kubectl config current-context
```

Switch back to the Minikube host cluster:

```bash
kubectl config use-context lab-cluster
```

When working with scenario workloads, make sure `kubectl` is targeting the appropriate vCluster.

---

## Shared-Node Isolation

The current architecture deliberately uses vCluster's shared-node model.

The vCluster provides its own Kubernetes control-plane experience, including its own API and logical Kubernetes resources.

However, workload execution ultimately relies on the underlying host Kubernetes cluster.

Conceptually:

```text
vCluster API
     │
     ▼
Virtual Kubernetes Resources
     │
     ▼
vCluster Syncer
     │
     ▼
Minikube
     │
     ▼
Host Worker Node
     │
     ▼
Scenario Workload
```

Therefore, a vCluster should not automatically be treated as equivalent to a completely independent VM or Kubernetes cluster from a security-boundary perspective.

Understanding those boundaries is itself part of the purpose of these labs.

---

## Scenarios

Available and planned scenarios are tracked in:

```text
scenarios/list.md
```

The initial `00_setup` scenario exists primarily to validate the lab architecture and deployment workflow before introducing more complex security scenarios.

Future labs will build on the same environment to explore areas such as:

- Kubernetes security
- Workload and container security
- Identity and access control
- Network isolation
- Secrets management
- Supply-chain security
- Secure software delivery
- Attack-path analysis
- Cloud-native security controls

The focus is not simply on demonstrating individual vulnerabilities, but on understanding how weaknesses interact across different layers of a modern application environment.

---

## Project Philosophy

Security issues rarely exist in isolation.

A vulnerability in an application may provide an initial foothold, but what happens next depends on identity, permissions, network access, workload configuration, Kubernetes controls and the surrounding infrastructure.

The labs therefore follow a simple model:

```text
BUILD
  |
  ▼
BREAK
  │
  ▼
UNDERSTAND
  │
  ▼
SECURE
```

The objective is to understand both the offensive path and the defensive controls capable of breaking that path.

---

## Disclaimer

These labs are intended for educational and security research purposes.

Only use the techniques demonstrated in this repository against systems you own or have explicit permission to test.

---

## License

See [LICENSE](LICENSE).