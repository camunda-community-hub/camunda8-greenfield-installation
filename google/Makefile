helmProfilesDir ?= ../../camunda-8-helm-profiles

project ?= camunda-researchanddevelopment
clusterName ?= camunda-greenfield-01
region ?= us-east1-b
machineType ?= n1-standard-16

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Chart values files
# TODO: test passing in a list
chartValues ?= "camunda-values.yaml"
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

ipAddress ?= 35.231.29.210

.PHONY: all
all: kube ingress camunda-values.yaml camunda urls

# TODO: fix clean-ingress and add back?
.PHONY: clean
clean: clean-camunda clean-kube clean-files

include $(helmProfilesDir)/include/ingress-nginx.mk
include $(helmProfilesDir)/include/camunda.mk
include ./kubernetes-gke.mk