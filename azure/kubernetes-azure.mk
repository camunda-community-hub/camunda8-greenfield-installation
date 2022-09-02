camunda-values.yaml:
	sed "s/127.0.0.1/$(ipAddress)/g;" camunda-values.tpl.yaml > camunda-values.yaml

ingress-azure.yaml:
	sed "s/127.0.0.1/$(ipAddress)/g;" ingress-azure.tpl.yaml > ingress-azure.yaml

.PHONY: clean-files
clean-files:
	rm -f camunda-values.yaml
	rm -f ingress-azure.yaml

.PHONY: kube
kube:
	az group create --name $(resourceGroup) --location $(region)
	az aks create \
      --resource-group $(resourceGroup) \
      --node-resource-group $(nodeResourceGroup) \
      --name $(clusterName) \
      --node-vm-size $(machineType) \
      --node-count 1 \
      --vm-set-type VirtualMachineScaleSets \
      --enable-cluster-autoscaler \
      --min-count $(minSize) \
      --max-count $(maxSize) \
      --network-plugin azure \
      --enable-managed-identity \
      -a ingress-appgw \
      --appgw-name $(gatewayName) \
      --appgw-subnet-cidr "10.225.0.0/16" \
      --generate-ssh-keys
	kubectl config unset clusters.$(clusterName)
	kubectl config unset users.clusterUser_$(resourceGroup)_$(clusterName)
	az aks get-credentials --resource-group $(resourceGroup) --name $(clusterName)
	kubectl apply -f ./ssd-storageclass-azure.yaml

.PHONY: clean-kube
clean-kube: use-kube
	az aks delete -y -g $(resourceGroup) -n $(clusterName)
	az group delete -y --resource-group $(resourceGroup)

.PHONY: use-kube
use-kube:
	kubectl config unset clusters.$(clusterName)
	kubectl config unset users.clusterUser_$(resourceGroup)_$(clusterName)
	az aks get-credentials --resource-group $(resourceGroup) --name $(clusterName)

.PHONY: urls
urls:
	@echo "Cluster: https://portal.azure.com/#@camunda.com/resource/subscriptions/$(subscriptionId)/resourceGroups/$(resourceGroup)/providers/Microsoft.ContainerService/managedClusters/$(clusterName)/overview"


