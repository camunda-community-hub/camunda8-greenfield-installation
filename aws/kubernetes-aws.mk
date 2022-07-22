.PHONY: k8s
k8s: kube autoscaler

cluster-autoscaler-policy.json:
	sed "s/<YOUR CLUSTER NAME>/$(CLUSTER_NAME)/" cluster-autoscaler-policy.tpl.json > cluster-autoscaler-policy.json

cluster-autoscaler-autodiscover.yaml:
	sed "s/<YOUR CLUSTER NAME>/$(CLUSTER_NAME)/" cluster-autoscaler-autodiscover.tpl.yaml > cluster-autoscaler-autodiscover.yaml

.PHONY: autoscaler
autoscaler: cluster-autoscaler-policy.json cluster-autoscaler-autodiscover.yaml
	eksctl utils associate-iam-oidc-provider --cluster $(CLUSTER_NAME) --approve
	aws iam create-policy --policy-name AmazonEKSClusterAutoscalerPolicy --policy-document file://cluster-autoscaler-policy.json
	eksctl create iamserviceaccount --cluster=$(CLUSTER_NAME) --namespace=kube-system --name=cluster-autoscaler --attach-policy-arn=arn:aws:iam::$(ACCOUNT_ID):policy/AmazonEKSClusterAutoscalerPolicy --override-existing-serviceaccounts --approve
	kubectl apply -f cluster-autoscaler-autodiscover.yaml
	kubectl annotate serviceaccount cluster-autoscaler -n kube-system eks.amazonaws.com/role-arn=arn:aws:iam::$(ACCOUNT_ID):role/AWSServiceRoleForAutoScaling
	kubectl patch deployment cluster-autoscaler -n kube-system -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'
#	kubectl set image deployment cluster-autoscaler -n kube-system cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.22.3

# check logs of autoscaler
.PHONY: logs-autoscaler
logs-autoscaler:
	kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler

.PHONY: kube
kube:
	eksctl create cluster --name $(CLUSTER_NAME) --region $(REGION) --asg-access
	kubectl apply -f ./ssd-storageclass-aws.yaml

.PHONY: clean-k8s
clean-k8s: use-k8s clean-kube

.PHONY: clean-kube
clean-kube: clean-camunda
	eksctl delete cluster --name $(CLUSTER_NAME) --region $(REGION)

.PHONY: use-k8s
use-k8s:
	eksctl utils write-kubeconfig -c $(CLUSTER_NAME)

.PHONY: urls
urls:
	@echo "Cluser: https://us-east-1.console.aws.amazon.com/eks/home?region=us-east-1#/clusters/$(CLUSTER_NAME)"

