.PHONY: k8s
k8s: kube

.PHONY: kube
kube:
	eksctl create cluster --name $(CLUSTER_NAME) --region $(REGION)
	kubectl apply -f ./ssd-storageclass-aws.yaml

.PHONY: clean-k8s
clean-k8s: use-k8s clean-kube

.PHONY: clean-kube
clean-kube: clean-camunda
	eksctl delete cluster --name $(CLUSTER_NAME) --region $(REGION)

.PHONY: use-k8s
use-k8s:
	eksctl utils write-kubeconfig -c $(CLUSTER_NAME)

.PHONY: urls
urls:
	@echo "Cluser: https://us-east-1.console.aws.amazon.com/eks/home?region=us-east-1#/clusters/$(CLUSTER_NAME)"

