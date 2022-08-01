
cluster.yaml:
	sed "s/<YOUR CLUSTER NAME>/$(clustername)/g; s/<YOUR REGION>/$(region)/g; s/<YOUR INSTANCE TYPE>/$(machine_type)/g; s/<YOUR MIN SIZE>/$(minsize)/g; s/<YOUR MAX SIZE>/$(maxsize)/g; s/<YOUR AVAILABILITY ZONES>/$(availabilityzones)/g;" cluster.tpl.yaml > cluster.yaml

.PHONY: clean-files
clean-files:
	rm -f cluster.yaml

.PHONY: oidc-provider
oidc-provider:
	eksctl utils associate-iam-oidc-provider --cluster $(clustername) --approve

.PHONY: kube
kube: cluster.yaml
	eksctl create cluster -f cluster.yaml
	kubectl apply -f ./ssd-storageclass-aws.yaml

.PHONY: clean-kube
clean-kube: use-k8s
	eksctl delete cluster --name $(clustername) --region $(region)

.PHONY: use-k8s
use-k8s:
	eksctl utils write-kubeconfig -c $(clustername)

.PHONY: urls
urls:
	@echo "Cluser: https://us-east-1.console.aws.amazon.com/eks/home?region=us-east-1#/clusters/$(clustername)"

