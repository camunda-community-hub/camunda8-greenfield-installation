COMMON_DIR ?= ../common

CLUSTER_NAME ?= <YOUR CLUSTER NAME>
REGION ?= us-east-1
# TODO: Availability zones isn't currently used anywhere
AVAILABILITY_ZONES ?= ['us-east-1a', 'us-east-1b']
INSTANCE_TYPE ?= m5.2xlarge
# TODO: Currently, auto scaling configuration using these scripts for AWS is not quite working
# So, for now, MIN SIZE is also used as the starting size of the cluster
MIN_SIZE ?= 4
MAX_SIZE ?= 10

CAMUNDA_NAMESPACE ?= camunda
CAMUNDA_VALUES_FILE ?= "$(COMMON_DIR)/camunda/camunda-values-default.yaml"
CAMUNDA_RELEASE ?= camunda
CAMUNDA_CHART ?= camunda/camunda-platform

ACCOUNT_ID ?= $(./aws.sh -a)

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Run 'make k8s' to create a new cluster. See README.md for more."

.PHONY: all
all: k8s urls

.PHONY: clean-all
clean-all: clean-k8s

.PHONY: camunda
camunda: zeebe await-zeebe

.PHONY: clean-camunda
clean-camunda: clean-zeebe

include ./kubernetes-aws.mk
include $(COMMON_DIR)/metrics/metrics.mk
include $(COMMON_DIR)/camunda/zeebe.mk