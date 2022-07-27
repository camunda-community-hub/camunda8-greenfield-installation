COMMON_DIR ?= ../common

RESOURCE_GROUP ?= camunda-group
CLUSTER_NAME ?= camunda-cluster-01
#REGION ?= eastus2
REGION ?= eastus
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general
# Note that there is a default Quota of 10 vCPUs for each machine type and region
# You have to request a quota increase. I got the message "This quota cannot be increased at this time." when requesting
# that the quota be increased from 10 to 30 for the eastus2 region.
# MACHINE_TYPE ?= Standard_B2s
MACHINE_TYPE ?= Standard_A8_v2
MIN_NODE_COUNT ?= 1
MAX_NODE_COUNT ?= 256



CAMUNDA_NAMESPACE ?= camunda
CAMUNDA_VALUES_FILE ?= "$(COMMON_DIR)/camunda/camunda-values-identity.yaml"
CAMUNDA_RELEASE ?= camunda
CAMUNDA_CHART ?= camunda/camunda-platform

# TODO: I'd rather not have to call a shell script, but I can't get this to work any other way?
SUBSCRIPTION_ID ?= $(shell "./azure.sh")

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Run 'make k8s' to create a new cluster. See README.md for more."

.PHONY: all
all: k8s urls

.PHONY: clean-all
clean-all: clean-camunda clean-k8s

.PHONY: camunda
camunda: zeebe await-zeebe ingress

.PHONY: clean-camunda
clean-camunda: clean-zeebe

include ./kubernetes-azure.mk
include $(COMMON_DIR)/metrics/metrics.mk
include $(COMMON_DIR)/camunda/zeebe.mk