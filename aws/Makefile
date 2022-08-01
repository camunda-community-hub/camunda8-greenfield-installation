includedir ?= ../camunda-8-helm-profiles/include

clustername ?= <YOUR CLUSTER NAME>
region ?= us-east-1
availabilityzones ?= ['us-east-1a', 'us-east-1b']
machinetype ?= m5.2xlarge

# TODO: Currently, auto scaling configuration using these scripts for AWS is not quite working
# So, for now, MIN SIZE is also used as the starting size of the cluster
minsize ?= 4
maxsize ?= 10

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Chart values files
# TODO: test passing in a list
chartvalues ?= "camunda-values.yaml"
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

.PHONY: all
all: kube oidc-provider ingress camunda urls

.PHONY: clean
clean-all: clean-camunda clean-ingress clean-kube clean-files

include $(include-dir)/ingress-nginx.mk
include $(include-dir)/camunda.mk
include ./kubernetes-aws.mk
