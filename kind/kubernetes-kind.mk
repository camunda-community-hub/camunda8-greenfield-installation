.PHONY: k8s
k8s: kube

.PHONY: kube
kube:
	kind create cluster --config=config.yaml
	kubectl apply -f ./ssd-storageclass-kind.yaml

.PHONY: clean-k8s
clean-k8s: use-k8s clean-kube

.PHONY: clean-kube
clean-kube:
	kind delete cluster --name camunda-kind-cluster

.PHONY: use-k8s
use-k8s:
	kubectl config use-context kind-camunda-kind-cluster

.PHONY: urls
urls:
	@echo "Cluster: (kind doesn't provide a user interface)"

