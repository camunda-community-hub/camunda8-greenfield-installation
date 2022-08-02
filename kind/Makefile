helmProfilesDir ?= ../../camunda-8-helm-profiles

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Chart values files
# TODO: test passing in a list
chartValues ?= "$(helmProfilesDir)/development/camunda-values.yaml"
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

.PHONY: all
all: kube camunda urls

.PHONY: clean
clean-all: clean-camunda clean-kube

include $(helmProfilesDir)/includes/camunda.mk
include ./kubernetes-kind.mk