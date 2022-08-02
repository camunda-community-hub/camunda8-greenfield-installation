helmProfilesDir ?= ../../camunda-8-helm-profiles

project ?= camunda-researchanddevelopment
clusterName ?= camunda-greenfield-01
region ?= us-east1-b
machineType ?= n1-standard-16

chartValues ?= "$(helmProfilesDir)/ingress-nginx/camunda-values.yaml"

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

ipAddress ?= 35.231.29.210

.PHONY: all
all: kube ingress-nginx-camunda urls

.PHONY: ingress-nginx-camunda
ingress-nginx-camunda:
	$(MAKE) -e -C $(helmProfilesDir)/ingress-nginx all
# TODO export variables and set flag to override default values
# Dave's note: I think the -e accomplishes sending variables to sub make, correct?

.PHONY: clean
clean: clean-ingress-nginx-camunda clean-kube

.PHONY: clean-ingress-nginx-camunda
clean-ingress-nginx-camunda:
	$(MAKE) -e -C $(helmProfilesDir)/ingress-nginx clean
# TODO export variables and set flag to override default values
# Dave's note: I think the -e accomplishes sending variables to sub make, correct?

include ./kubernetes-gke.mk
# Note: the ingress-nginx makefile already includes this. But if we don't include it here, we can't access targets
#       such as `make port-zeebe`, etc.
include $(helmProfilesDir)/include/camunda.mk