cluster:
	# minikube v1.32.0-beta.0 or later (docker driver only).
	# https://minikube.sigs.k8s.io/docs/tutorials/nvidia/
	minikube start --driver docker --container-runtime docker --gpus all
	kubectl create namespace argo

cluster-removal:
	minikube delete


tunnel:
	minikube tunnel --bind-address="0.0.0.0"
