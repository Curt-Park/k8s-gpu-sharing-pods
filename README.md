# [WIP] GPU Sharing Pods on Kubernetes
By default, Kubernetes doesn't allow GPU sharing cases as follows:
- A pod with multiple containers that share a single GPU.
- Multiple pods that share a single GPU.

In this repository, I introduce some tricks for GPU sharing pods on Kubernetes with only use of NVIDIA device plugin.

## Prerequisites
- Install [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- Install [Minikube](https://minikube.sigs.k8s.io/docs/start)
- Install [HELM](https://helm.sh/docs/intro/install/)
- Install [Argo Workflows CLI](https://github.com/argoproj/argo-workflows/releases/tag/v3.5.10)

## K8s Cluster Creation
```bash
make cluster
kubectl get pods --all-namespaces
# Check `nvidia-device-plugin-daemonset` is running.
```

## Argo Workflow Installation
```bash
kubectl create namespace argo
helm install argo-workflows charts/argo-workflows -n argo
# Wait for argo-workflows ready...
make port-forward
```

Open http://localhost:2746/

Login with the token:
```bash
kubectl apply -f secret.yaml
kubectl get secret  # Check `argo-workflows-admin.service-account-token` created.
make token
# Paste all strings including Bearer.
```

Execute a simple workflow for testing:
```bash
argo submit --watch workflows/hello-world.yaml
```
<img width="1497" src="https://github.com/user-attachments/assets/ba15639e-d789-4116-bf5a-b67a129d4061">

## Example: A single pod with multiple containers that share a single GPU
Create a workflow template that have consecutive jobs sharing a single GPU.
```bash
kubectl apply -f workflows/templates/gpu-sharing-workflowtemplate.yaml
```

Trigger the gpu allocation and gpu-sharing job execution.
```bash
argo submit --watch workflows/submit-gpu-sharing-workflow.yaml
argo submit --watch workflows/submit-gpu-sharing-workflow.yaml -p gpus=2  # 2 gpus
```

<img width="3004" src="https://github.com/user-attachments/assets/c599da15-dc81-48dc-a9d6-b6833e16e3f5">

Logs:
```bash
# gpu-allocation
gpu-allocation-zj8g7-create-wf-1869261602: GPU:GPU-7e42023c-83da-f45d-8b7a-98d93dec657b / node:minikube
gpu-allocation-zj8g7-create-wf-1869261602: gpu-sharing-workflow-template-w89qv triggered
gpu-allocation-zj8g7-create-wf-1869261602: Running
gpu-allocation-zj8g7-create-wf-1869261602: Running
gpu-allocation-zj8g7-create-wf-1869261602: Running
gpu-allocation-zj8g7-create-wf-1869261602: Running
gpu-allocation-zj8g7-create-wf-1869261602: Running
gpu-allocation-zj8g7-create-wf-1869261602: Running
gpu-allocation-zj8g7-create-wf-1869261602: Succeeded
gpu-allocation-zj8g7-create-wf-1869261602: time="2024-08-20T00:27:08 UTC" level=info msg="sub-process exited" argo=true error="<nil>"

# gpu-sharing-workflow
gpu-sharing-workflow-template-w89qv-train-1102222563: GPU_UUID: GPU-7e42023c-83da-f45d-8b7a-98d93dec657b
gpu-sharing-workflow-template-w89qv-train-1102222563: GPU Count:  1
gpu-sharing-workflow-template-w89qv-train-1102222563: time="2024-08-20T00:26:49 UTC" level=info msg="sub-process exited" argo=true error="<nil>"
gpu-sharing-workflow-template-w89qv-inference-2403067347: GPU_UUID: GPU-7e42023c-83da-f45d-8b7a-98d93dec657b
gpu-sharing-workflow-template-w89qv-inference-2403067347: GPU Count:  1
gpu-sharing-workflow-template-w89qv-inference-2403067347: time="2024-08-20T00:27:00 UTC" level=info msg="sub-process exited" argo=true error="<nil>"
```

## Example: A single pod with multiple containers that share a single GPU with MPS
TBD

## References
- https://argo-workflows.readthedocs.io/en/latest/walk-through/argo-cli/
- https://argo-workflows.readthedocs.io/en/latest/fields/#workflow
- https://gist.github.com/Curt-Park/bb20f76ba2b052b03b2e1ea9834517a6
- https://docs.nvidia.com/deploy/mps/#starting-and-stopping-mps-on-linux
