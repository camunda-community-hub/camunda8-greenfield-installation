project ?= <CHANGE_ME> #camunda-researchanddevelopment
clustername ?= camunda-cluster-01
region ?= us-east1-b
machine-type ?= n1-standard-16
common-dir ?= ../common

.PHONY: all
all: k8s urls

.PHONY: clean
clean: clean-k8s

include ./include/kubernetes-gke.mk
include $(common-dir)/metrics/metrics.mk