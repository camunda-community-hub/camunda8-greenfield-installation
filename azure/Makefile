helmProfilesDir ?= ../../camunda-8-helm-profiles

resourceGroup ?= greenfield-group-01
clusterName ?= camunda-greenfield-01
#region ?= eastus2
region ?= eastus
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general
# Note that there is a default Quota of 10 vCPUs for each machine type and region
# You have to request a quota increase. I got the message "This quota cannot be increased at this time." when requesting
# that the quota be increased from 10 to 30 for the eastus2 region.
# MACHINE_TYPE ?= Standard_B2s
machineType ?= Standard_A8_v2
minSize ?= 1
maxSize ?= 256

# Change this to match the front end IP address from App Gateway
ipAddress ?= <IP ADDRESS>

# TODO: I'd rather not have to call a shell script, but I can't get this to work any other way?
subscriptionId ?= $(shell "./azure.sh")

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Chart values files
# TODO: test passing in a list
chartValues ?= "camunda-values.yaml"
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

.PHONY: all
all: kube ingress camunda urls

.PHONY: clean
clean: clean-camunda clean-kube

include $(helmProfilesDir)/include/camunda.mk
include ./kubernetes-azure.mk