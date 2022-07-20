COMMON_DIR ?= ../common

PROJECT ?= <CHANGE_ME> #camunda-researchanddevelopment
CLUSTER_NAME ?= camunda-cluster-01
REGION ?= us-east1-b
MACHINE_TYPE ?= n1-standard-16

CAMUNDA_NAMESPACE ?= camunda
CAMUNDA_VALUES_FILE ?= "$(COMMON_DIR)/camunda/camunda-values-default.yaml"
CAMUNDA_RELEASE ?= camunda
CAMUNDA_CHART ?= camunda/camunda-platform

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Run 'make k8s' to create a new cluster. See README.md for more."

.PHONY: all
all: k8s urls

.PHONY: clean
clean: clean-k8s

include ./include/kubernetes-gke.mk
include $(COMMON_DIR)/metrics/metrics.mk