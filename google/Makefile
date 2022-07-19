PROJECT ?= <CHANGE_ME> #camunda-researchanddevelopment
CLUSTER_NAME ?= camunda-cluster-01
REGION ?= us-east1-b
MACHINE_TYPE ?= n1-standard-16

COMMON_DIR ?= ../common

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