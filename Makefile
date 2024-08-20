cluster:
	# minikube v1.32.0-beta.0 or later (docker driver only).
	# https://minikube.sigs.k8s.io/docs/tutorials/nvidia/
	minikube start --driver docker --container-runtime docker --gpus all
	kubectl create namespace argo

cluster-removal:
	minikube delete

port-forward:
	kubectl -n argo port-forward service/argo-workflows-server 2746:2746 --address="0.0.0.0"

token:
	@echo "Bearer $(shell kubectl get secret argo-workflows-admin.service-account-token -o=jsonpath='{.data.token}' | base64 --decode)"
