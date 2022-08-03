helmProfilesDir ?= ../../camunda-8-helm-profiles

clusterName ?= camunda-greenfield
region ?= us-east-1
zones ?= ['us-east-1a', 'us-east-1b']
machineType ?= m5.2xlarge
# TODO: Currently, auto scaling configuration using these scripts for AWS is not configured
# for now, minSize is also used as the starting size of the cluster
minSize ?= 4
maxSize ?= 10

chartValues ?= "$(helmProfilesDir)/ingress-nginx/camunda-values.yaml"

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

.PHONY: all
all: cluster.yaml kube oidc-provider ingress-nginx-camunda urls

.PHONY: ingress-nginx-camunda
ingress-nginx-camunda:
	$(MAKE) -e -C $(helmProfilesDir)/ingress-nginx ingress-nginx
	$(MAKE) -e -C $(helmProfilesDir)/ingress-nginx ingress-ip-from-commandline camunda

.PHONY: clean
clean: clean-ingress-nginx-camunda clean-kube clean-files

.PHONY: clean-ingress-nginx-camunda
clean-ingress-nginx-camunda:
	$(MAKE) -e -C $(helmProfilesDir)/ingress-nginx clean

include ./kubernetes-aws.mk
# Note: the ingress-nginx makefile already includes this. But if we don't include it here, we can't access targets
#       such as `make port-zeebe`, etc.
include $(helmProfilesDir)/include/camunda.mk