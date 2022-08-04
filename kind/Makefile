helmProfilesDir ?= ../../camunda-8-helm-profiles

chartValues ?= "$(helmProfilesDir)/development/camunda-values.yaml"
#chartValues ?= "/Users/dave/code/camunda-platform-helm/kind/camunda-platform-core-kind-values.yaml"

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

.PHONY: all
all: kube camunda urls

.PHONY: clean
clean: clean-camunda clean-kube

include ./kubernetes-kind.mk
# Note: the ingress-nginx makefile already includes this. But if we don't include it here, we can't access targets
#       such as `make port-zeebe`, etc.
include $(helmProfilesDir)/include/camunda.mk
