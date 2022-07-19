COMMON_DIR ?= ../common

RESOURCE_GROUP ?= camunda-group
NODE_RESOURCE_GROUP ?= camunda-node-group
CLUSTER_NAME ?= camunda-cluster-01
REGION ?= eastus2
MACHINE_TYPE ?= Standard_B2s
MIN_NODE_COUNT ?= 1
MAX_NODE_COUNT ?= 256

CAMUNDA_NAMESPACE ?= camunda
CAMUNDA_VALUES_FILE ?= "$(COMMON_DIR)/camunda/zeebe-small-profile.yaml"
CAMUNDA_MODEL_FILE = "$(COMMON_DIR)/camunda/EightTasks.bpmn"
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

.PHONY: clean
clean: clean-camunda clean-k8s

.PHONY: camunda
camunda: zeebe await-zeebe

.PHONY: clean-camunda
clean-camunda: clean-zeebe

include ./kubernetes-azure.mk
include $(COMMON_DIR)/metrics/metrics.mk
include $(COMMON_DIR)/camunda/zeebe.mk