helmProfilesDir ?= ../../camunda-8-helm-profiles

resourceGroup ?= greenfield-group-01
clusterName ?= camunda-greenfield-01
#region ?= eastus2
region ?= eastus
# The resource group above is used to contain the Kubernetes Cluster
# Azure also uses a second "node" resource group that contains nodes and other objects
# By default, Azure will name this Node Resource Group something like `MC_resourceGroup_clusterName_region`
# The following allows for specifying the exact name of this second, "Managed Cluster" node resource group
nodeResourceGroup ?= greenfield-node-group-01
gatewayName ?= myApplicationGateway
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general
# Note that there is a default Quota of 10 vCPUs for each machine type and region
# You have to request a quota increase. I got the message "This quota cannot be increased at this time." when requesting
# that the quota be increased from 10 to 30 for the eastus2 region.
# MACHINE_TYPE ?= Standard_B2s
machineType ?= Standard_A8_v2
minSize ?= 1
maxSize ?= 256

chartValues ?= "$(helmProfilesDir)/ingress-azure/camunda-values.yaml"

# TODO: I'd rather not have to call a shell script, but I can't get this to work any other way?
subscriptionId ?= $(shell "./azure.sh")

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform


.PHONY: all
all: kube ingress-nginx-camunda urls

.PHONY: ingress-nginx-camunda
ingress-nginx-camunda:
	$(MAKE) -e -C $(helmProfilesDir)/ingress-azure all

.PHONY: clean
clean: clean-ingress-nginx-camunda clean-kube

.PHONY: clean-ingress-nginx-camunda
clean-ingress-nginx-camunda:
	$(MAKE) -e -C $(helmProfilesDir)/ingress-azure clean

include ./kubernetes-azure.mk
# Note: the ingress-nginx makefile already includes this. But if we don't include it here, we can't access targets
#       such as `make port-zeebe`, etc.
include $(helmProfilesDir)/include/camunda.mk
