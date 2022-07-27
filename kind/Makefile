COMMON_DIR ?= ../common

CAMUNDA_NAMESPACE ?= camunda
CAMUNDA_VALUES_FILE ?= "$(COMMON_DIR)/camunda/camunda-values-dev.yaml"
CAMUNDA_RELEASE ?= camunda
CAMUNDA_CHART ?= camunda/camunda-platform

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Run 'make k8s' to create a new cluster. See README.md for more."

.PHONY: all
all: k8s urls

.PHONY: clean-all
clean-all: clean-camunda clean-k8s

.PHONY: camunda
camunda: zeebe await-zeebe

.PHONY: clean-camunda
clean-camunda: clean-zeebe

include ./kubernetes-kind.mk
include $(COMMON_DIR)/metrics/metrics.mk
include $(COMMON_DIR)/camunda/zeebe.mk