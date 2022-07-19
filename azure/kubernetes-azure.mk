.PHONY: k8s
k8s: kube

.PHONY: kube
kube:
	az group create --name $(resource-group) --location $(region)
	az aks create -g $(resource-group) \
      --node-resource-group $(node-resource-group) \
     -n $(clustername) \
     --enable-cluster-autoscaler --min-count 1 --max-count 256 \
     --node-vm-size $(machine-type)
	az aks get-credentials -y --resource-group $(resource-group) --name $(clustername)
	kubectl apply -f ./ssd-storageclass-azure.yaml

.PHONY: clean-k8s
clean-k8s: use-k8s clean-kube

.PHONY: clean-kube
clean-kube:
	az aks delete -y -g $(resource-group) -n $(clustername)
	az group delete -y --resource-group $(resource-group)

.PHONY: use-k8s
use-k8s:
	az aks get-credentials --resource-group $(resource-group) --name $(clustername)

.PHONY: urls
urls:
	@echo "Cluster: https://portal.azure.com/#@camunda.com/resource/subscriptions/$(SUBSCRIPTION_ID)/resourceGroups/$(resource-group)/providers/Microsoft.ContainerService/managedClusters/$(clustername)/overview"
	@echo "Workflows: https://portal.azure.com/#@camunda.com/resource/subscriptions/$(SUBSCRIPTION_ID)/resourceGroups/$(resource-group)/providers/Microsoft.ContainerService/managedClusters/$(clustername)/workflows"

