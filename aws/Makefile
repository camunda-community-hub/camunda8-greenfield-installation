helmProfilesDir ?= ../../camunda-8-helm-profiles

clusterName ?= camunda-greenfield
region ?= us-east-1
zones ?= ['us-east-1a', 'us-east-1b']
machineType ?= m5.2xlarge

# TODO: Currently, auto scaling configuration using these scripts for AWS is not quite working
# So, for now, MIN SIZE is also used as the starting size of the cluster
minSize ?= 4
maxSize ?= 10

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Chart values files
# TODO: test passing in a list
chartValues ?= "camunda-values.yaml"
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

ipAddress ?= <IP ADDRESS>

.PHONY: all
all: kube oidc-provider ingress camunda-values.yaml camunda urls

.PHONY: clean
clean: clean-camunda clean-ingress clean-kube clean-files

include $(helmProfilesDir)/include/ingress-nginx.mk
include $(helmProfilesDir)/include/camunda.mk
include ./kubernetes-aws.mk
