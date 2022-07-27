.PHONY: zeebe
zeebe: namespace
	helm repo add camunda https://helm.camunda.io
	helm repo update camunda
	helm search repo $(CAMUNDA_CHART)
	helm install --namespace $(CAMUNDA_NAMESPACE) $(CAMUNDA_RELEASE) $(CAMUNDA_CHART) -f $(CAMUNDA_VALUES_FILE) --skip-crds

.PHONY: namespace
namespace:
	-kubectl create namespace $(CAMUNDA_NAMESPACE)
#	-kubens $(CAMUNDA_NAMESPACE)

# Generates templates from the camunda helm charts, useful to make some more specific changes which are not doable by the values file.
.PHONY: template
template:
	helm template $(CAMUNDA_RELEASE) $(CAMUNDA_CHART) -f $(CAMUNDA_VALUES_FILE) --skip-crds --output-dir .
	@echo "To apply the templates use: kubectl apply -f camunda-platform/templates/ -n $(CAMUNDA_NAMESPACE)"

.PHONY: update
update:
	OPERATE_SECRET=$$(kubectl get secret --namespace $(CAMUNDA_NAMESPACE) "camunda-operate-identity-secret" -o jsonpath="{.data.operate-secret}" | base64 --decode); \
	TASKLIST_SECRET=$$(kubectl get secret --namespace $(CAMUNDA_NAMESPACE) "camunda-tasklist-identity-secret" -o jsonpath="{.data.tasklist-secret}" | base64 --decode); \
	OPTIMIZE_SECRET=$$(kubectl get secret --namespace $(CAMUNDA_NAMESPACE) "camunda-optimize-identity-secret" -o jsonpath="{.data.optimize-secret}" | base64 --decode); \
	helm upgrade --namespace $(CAMUNDA_NAMESPACE) $(CAMUNDA_RELEASE) $(CAMUNDA_CHART) -f $(CAMUNDA_VALUES_FILE) \
	  --set global.identity.auth.operate.existingSecret=$$OPERATE_SECRET \
	  --set global.identity.auth.tasklist.existingSecret=$$TASKLIST_SECRET \
	  --set global.identity.auth.optimize.existingSecret=$$OPTIMIZE_SECRET

.PHONY: clean-zeebe
clean-zeebe:
	-helm --namespace $(CAMUNDA_NAMESPACE) uninstall $(CAMUNDA_RELEASE)
	-kubectl delete -n $(CAMUNDA_NAMESPACE) pvc -l app.kubernetes.io/instance=$(CAMUNDA_RELEASE)
	-kubectl delete -n $(CAMUNDA_NAMESPACE) pvc -l app=elasticsearch-master
	-kubectl delete namespace $(CAMUNDA_NAMESPACE)

.PHONY: watch
watch:
	kubectl get pods -w -n $(CAMUNDA_NAMESPACE)

.PHONY: watch-zeebe
watch-zeebe:
	kubectl get pods -w -n $(CAMUNDA_NAMESPACE) -l app.kubernetes.io/name=zeebe

.PHONY: await-zeebe
await-zeebe:
	kubectl wait --for=condition=Ready pod -n $(CAMUNDA_NAMESPACE) -l app.kubernetes.io/name=zeebe --timeout=900s

.PHONY: port-zeebe
port-zeebe:
	kubectl port-forward svc/$(CAMUNDA_RELEASE)-zeebe-gateway 26500:26500 -n $(CAMUNDA_NAMESPACE)

.PHONY: port-identity
port-identity:
	kubectl port-forward svc/camunda-identity 8080:80 -n $(CAMUNDA_NAMESPACE)

.PHONY: port-keycloak
port-keycloak:
	kubectl port-forward svc/camunda-keycloak 18080:80 -n $(CAMUNDA_NAMESPACE)

.PHONY: port-operate
port-operate:
	kubectl port-forward svc/camunda-operate 8081:80 -n $(CAMUNDA_NAMESPACE)

.PHONY: port-tasklist
port-tasklist:
	kubectl port-forward svc/camunda-tasklist 8082:80 -n $(CAMUNDA_NAMESPACE)

.PHONY: port-optimize
port-optimize:
	kubectl port-forward svc/camunda-optimize 8083:80 -n $(CAMUNDA_NAMESPACE)

.PHONY: bash
bash:
	kubectl exec --namespace $(CAMUNDA_NAMESPACE) --stdin --tty $(pod) -- /bin/bash

.PHONY: pods
pods:
	kubectl get pods --namespace $(CAMUNDA_NAMESPACE)

.PHONY: logs
logs:
	kubectl logs --namespace $(CAMUNDA_NAMESPACE) -f $(pod)


.PHONY: keycloak-password
keycloak-password:
	helm upgrade keycloak bitnami/keycloak --set auth.adminPassword=$(KEYCLOAK_ADMIN_PASSWORD) --set auth.managementPassword=$(KEYCLOAK_MANAGEMENT_PASSWORD)

