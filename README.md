# GPU Sharing Pods on Kubernetes
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
kubectl -n argo port-forward service/argo-workflows-server 2746:2746 --address="0.0.0.0"
```

Open http://localhost:2746/

Login with the token:
```bash
kubectl create -f secret.yaml
echo "Bearer $(kubectl get secret ui-user-read-only.service-account-token -o=jsonpath='{.data.token}' | base64 --decode)"
# Paste all strings including Bearer
```

Execute a simple workflow for testing:
```bash
argo submit --watch --serviceaccount argo-workflow workflows/hello-world.yaml
```
<img width="1497" src="https://github.com/user-attachments/assets/ba15639e-d789-4116-bf5a-b67a129d4061">

## Example: A single pod with multiple containers that share a single GPU
TBD

## Example: Multiple pods that share a single GPU
TBD

## References
- https://argo-workflows.readthedocs.io/en/latest/walk-through/argo-cli/
- https://gist.github.com/Curt-Park/bb20f76ba2b052b03b2e1ea9834517a6
