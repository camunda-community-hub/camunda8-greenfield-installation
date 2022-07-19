RESOURCE_GROUP ?= camunda-group
NODE_RESOURCE_GROUP ?= camunda-node-group
CLUSTER_NAME ?= camunda-cluster-01
REGION ?= eastus2
MACHINE_TYPE ?= Standard_B2s

COMMON_DIR ?= ../common

# TODO: I'd rather not have to call a shell script, but I can't get this to work any other way?
SUBSCRIPTION_ID ?= $(shell "./azure.sh")

.PHONY: all
all: k8s

.PHONY: clean
clean: clean-k8s

include ./kubernetes-azure.mk
include $(COMMON_DIR)/metrics/metrics.mk