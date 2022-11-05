helmProfilesDir ?= ../../camunda-8-helm-profiles

chartValues ?= "$(helmProfilesDir)/development/camunda-values.yaml"

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform
# Service to apply cert
service ?= zeebe-gateway
# TLS secret name
secret_name ?= tls-secret
# Cert Signing Reqest (CSR) signer name
signerName ?= example.com\/pdiddy

.PHONY: all
all: kube camunda urls

.PHONY: camunda-ingress
camunda-ingress: kube namespace ingress grpc-gateway-tls camunda urls

.PHONY: grpc-gateway-tls
grpc-gateway-tls: cfssl-create-csr kube-upload-csr kube-approve-csr \
									cfssl-create-cert-authority cfssl-sign-certificate \
									kube-upload-cert kube-create-secret clean-certs

.PHONY: ingress
ingress: ingress-kind

.PHONY: clean
clean: clean-camunda clean-kube

include ./kubernetes-kind.mk
# Note: the ingress-nginx makefile already includes this. But if we don't include it here, we can't access targets
#       such as `make port-zeebe`, etc.

include $(helmProfilesDir)/certs/tls-certs.mk
include $(helmProfilesDir)/include/ingress-kind.mk
include $(helmProfilesDir)/include/camunda.mk
