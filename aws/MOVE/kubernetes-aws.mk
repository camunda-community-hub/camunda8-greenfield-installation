.PHONY: k8s
k8s: cluster.yaml kube

camunda-values-identity.yaml:
	sed "s/<PUBLIC IP ADDRESS>/$(PUBLIC_IP_ADDRESS)/g;" ../common/camunda/camunda-values-identity.tpl.yaml > camunda-values-identity.yaml

cluster.yaml:
	sed "s/<YOUR CLUSTER NAME>/$(CLUSTER_NAME)/g; s/<YOUR REGION>/$(REGION)/g; s/<YOUR INSTANCE TYPE>/$(INSTANCE_TYPE)/g; s/<YOUR MIN SIZE>/$(MIN_SIZE)/g; s/<YOUR MAX SIZE>/$(MAX_SIZE)/g; s/<YOUR AVAILABILITY ZONES>/$(AVAILABILITY_ZONES)/g;" cluster.tpl.yaml > cluster.yaml

cluster-autoscaler-policy.json:
	sed "s/<YOUR CLUSTER NAME>/$(CLUSTER_NAME)/g" cluster-autoscaler-policy.tpl.json > cluster-autoscaler-policy.json

cluster-autoscaler-autodiscover.yaml:
	sed "s/<YOUR CLUSTER NAME>/$(CLUSTER_NAME)/g" cluster-autoscaler-autodiscover.tpl.yaml > cluster-autoscaler-autodiscover.yaml

.PHONY: clean-files
clean-files:
	rm -f cluster.yaml
	rm -f cluster-autoscaler-autodiscover.yaml
	rm -f cluster-autoscaler-autodiscover-2.yaml
	rm -f cluster-autoscaler-policy.json
	rm -f camunda-values-identity.yaml

.PHONY: oidc-provider
oidc-provider:
	eksctl utils associate-iam-oidc-provider --cluster $(CLUSTER_NAME) --approve

.PHONY: autoscaler
autoscaler: oidc-provider cluster-autoscaler-policy.json cluster-autoscaler-autodiscover.yaml
	aws iam create-policy --policy-name AmazonEKSClusterAutoscalerPolicy --policy-document file://cluster-autoscaler-policy.json
	eksctl create iamserviceaccount --cluster=$(CLUSTER_NAME) --namespace=kube-system --name=cluster-autoscaler --attach-policy-arn=arn:aws:iam::$(ACCOUNT_ID):policy/AmazonEKSClusterAutoscalerPolicy --override-existing-serviceaccounts --approve
	kubectl apply -f cluster-autoscaler-autodiscover.yaml
	kubectl annotate serviceaccount cluster-autoscaler -n kube-system eks.amazonaws.com/role-arn=arn:aws:iam::$(ACCOUNT_ID):role/AWSServiceRoleForAutoScaling --overwrite
	kubectl patch deployment cluster-autoscaler -n kube-system -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'
	sed "s/<YOUR CLUSTER NAME>/$(CLUSTER_NAME)/" cluster-autoscaler-autodiscover-2.tpl.yaml > cluster-autoscaler-autodiscover-2.yaml
	kubectl apply -f cluster-autoscaler-autodiscover-2.yaml
#	kubectl set image deployment cluster-autoscaler -n kube-system cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.22.3


.PHONY: clean-autoscaler
clean-autoscaler:
	kubectl delete deployment cluster-autoscaler --namespace kube-system || true
	kubectl delete RoleBinding cluster-autoscaler --namespace kube-system || true
	kubectl delete ClusterRoleBinding cluster-autoscaler --namespace kube-system || true
	kubectl delete Role cluster-autoscaler --namespace kube-system || true
	kubectl delete ClusterRole cluster-autoscaler --namespace kube-system || true
	eksctl delete iamserviceaccount --cluster=dave-greenfield --name=cluster-autoscaler || true
	aws iam delete-policy --policy-arn arn:aws:iam::985136719106:policy/AmazonEKSClusterAutoscalerPolicy || true

# check logs of autoscaler
.PHONY: logs-autoscaler
logs-autoscaler:
	kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler

.PHONY: kube
kube:
	eksctl create cluster -f cluster.yaml
	kubectl apply -f ./ssd-storageclass-aws.yaml

.PHONY: clean-k8s
clean-k8s: use-k8s clean-kube clean-files

.PHONY: clean-kube
clean-kube: clean-camunda
	eksctl delete cluster --name $(CLUSTER_NAME) --region $(REGION)

.PHONY: use-k8s
use-k8s:
	eksctl utils write-kubeconfig -c $(CLUSTER_NAME)

.PHONY: urls
urls:
	@echo "Cluser: https://us-east-1.console.aws.amazon.com/eks/home?region=us-east-1#/clusters/$(CLUSTER_NAME)"

.PHONY: ingress
ingress: namespace oidc-provider
	@echo "TODO: AWS Ingress"


# Nginx load balancer

# Maybe use helm chart?
# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/

# kubectl apply -f ./ns-and-sa.yaml
# kubectl apply -f ./default-server-secret.yaml

# kubectl apply -f ./nginx-config.yaml

# kubectl apply -f ./rbac.yaml

# kubectl apply -f ./ingress-class.yaml

# kubectl apply -f ./nginx-ingress.yaml

# kubectl apply -f ./loadbalancer-aws-elb.yaml

# a94dc47b2291448639901bc28e9d15a0-1335233274.us-east-1.elb.amazonaws.com




## App Load Balancer (not working yet)
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
# aws iam create-policy --policy-name ALBIngressControllerIAMPolicy --policy-document ./iam-policy.json

# eksctl create iamserviceaccount \
#       --cluster=dave-greenfield \
#       --namespace=kube-system \
#       --name=alb-ingress-controller \
#       --attach-policy-arn=arn:aws:iam::985136719106:policy/ALBIngressControllerIAMPolicy \
#       --override-existing-serviceaccounts \
#       --approve

#curl -sS "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml" \
#     | sed "s/# - --cluster-name=devCluster/- --cluster-name=dave-greenfield/g" \
#     | kubectl apply -f -


.PHONY: one+two
one+two:
	@echo "TODO: AWS Ingress"

