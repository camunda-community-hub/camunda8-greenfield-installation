.PHONY: k8s
k8s: kube

.PHONY: kube
kube:
	az group create --name $(RESOURCE_GROUP) --location $(REGION)
	az aks create \
      --resource-group $(RESOURCE_GROUP) \
      --name $(CLUSTER_NAME) \
      --node-vm-size $(MACHINE_TYPE) \
      --node-count 1 \
      --vm-set-type VirtualMachineScaleSets \
      --enable-cluster-autoscaler \
      --min-count $(MIN_NODE_COUNT) \
      --max-count $(MAX_NODE_COUNT) \
      --network-plugin azure \
      --enable-managed-identity \
      -a ingress-appgw \
      --appgw-name myApplicationGateway \
      --appgw-subnet-cidr "10.225.0.0/16" \
      --generate-ssh-keys
	kubectl config unset clusters.$(CLUSTER_NAME)
	kubectl config unset users.clusterUser_$(RESOURCE_GROUP)_$(CLUSTER_NAME)
	az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(CLUSTER_NAME)
	kubectl apply -f ./ssd-storageclass-azure.yaml

.PHONY: clean-k8s
clean-k8s: use-k8s clean-kube

.PHONY: clean-kube
clean-kube:
	az aks delete -y -g $(RESOURCE_GROUP) -n $(CLUSTER_NAME)
	az group delete -y --resource-group $(RESOURCE_GROUP)

.PHONY: use-k8s
use-k8s:
	kubectl config unset clusters.$(CLUSTER_NAME)
	kubectl config unset users.clusterUser_$(RESOURCE_GROUP)_$(CLUSTER_NAME)
	az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(CLUSTER_NAME)

.PHONY: urls
urls:
	@echo "Cluster: https://portal.azure.com/#@camunda.com/resource/subscriptions/$(SUBSCRIPTION_ID)/resourceGroups/$(RESOURCE_GROUP)/providers/Microsoft.ContainerService/managedClusters/$(CLUSTER_NAME)/overview"
#	@echo "Workflows: https://portal.azure.com/#@camunda.com/resource/subscriptions/$(SUBSCRIPTION_ID)/resourceGroups/$(RESOURCE_GROUP)/providers/Microsoft.ContainerService/managedClusters/$(CLUSTER_NAME)/workflows"

.PHONY: ingress
ingress:
	kubectl apply -f ingress-identity-gw.yaml
	kubectl apply -f ingress-keycloak-gw.yaml
	kubectl apply -f ingress-operate-gw.yaml
	kubectl apply -f ingress-tasklist-gw.yaml

.PHONY: ingress-zeebe
ingress-zeebe:
	kubectl apply -f zeebe-lb.yaml