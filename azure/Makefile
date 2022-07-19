resource-group ?= dave-group
node-resource-group ?= dave-node-group
clustername ?= dave-cluster-01
region ?= eastus2
machine-type ?= Standard_B2s

common-dir ?= ../common

# TODO: I'd rather not have to call a shell script, but I can't get this to work any other way?
SUBSCRIPTION_ID ?= $(shell "./azure.sh")

.PHONY: all
all: k8s

.PHONY: clean
clean: clean-k8s

include ./kubernetes-azure.mk
include $(common-dir)/metrics.mk