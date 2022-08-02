helmProfilesDir ?= ../../camunda-8-helm-profiles

project ?= camunda-researchanddevelopment
clusterName ?= camunda-greenfield-01
region ?= us-east1-b
machineType ?= n1-standard-16

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
	$(MAKE) -C $(helmProfilesDir)/ingress-nginx all
# TODO export variables and set flag to override default values

# TODO: fix clean-ingress and add back?
.PHONY: clean
clean: clean-ingress-nginx-camunda clean-kube

.PHONY: clean-ingress-nginx-camunda
clean-ingress-nginx-camunda:
	$(MAKE) -C $(helmProfilesDir)/ingress-nginx clean
# TODO export variables and set flag to override default values

include ./kubernetes-gke.mk