
cluster.yaml:
	sed "s/<YOUR CLUSTER NAME>/$(clusterName)/g; s/<YOUR REGION>/$(region)/g; s/<YOUR INSTANCE TYPE>/$(machineType)/g; s/<YOUR MIN SIZE>/$(minSize)/g; s/<YOUR MAX SIZE>/$(maxSize)/g; s/<YOUR AVAILABILITY ZONES>/$(zones)/g;" cluster.tpl.yaml > cluster.yaml

.PHONY: clean-files
clean-files:
	rm -f cluster.yaml

.PHONY: oidc-provider
oidc-provider:
	eksctl utils associate-iam-oidc-provider --cluster $(clusterName) --approve

.PHONY: kube
kube: cluster.yaml
	eksctl create cluster -f cluster.yaml
	kubectl apply -f ./ssd-storageclass-aws.yaml

.PHONY: clean-kube
clean-kube: use-kube
	eksctl delete cluster --name $(clusterName) --region $(region)

.PHONY: use-kube
use-kube:
	eksctl utils write-kubeconfig -c $(clusterName)

.PHONY: urls
urls:
	@echo "Cluster: https://$(region).console.aws.amazon.com/eks/home?region=$(region)#/clusters/$(clusterName)"

