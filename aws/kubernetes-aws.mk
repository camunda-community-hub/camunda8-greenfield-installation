.PHONY: k8s
k8s: cluster.yaml kube

cluster.yaml:
	sed "s/<YOUR CLUSTER NAME>/$(CLUSTER_NAME)/g; s/<YOUR REGION>/$(REGION)/g; s/<YOUR INSTANCE TYPE>/$(INSTANCE_TYPE)/g; s/<YOUR MIN SIZE>/$(MIN_SIZE)/g; s/<YOUR MAX SIZE>/$(MAX_SIZE)/g" cluster.tpl.yaml > cluster.yaml

cluster-autoscaler-policy.json:
	sed "s/<YOUR CLUSTER NAME>/$(CLUSTER_NAME)/g" cluster-autoscaler-policy.tpl.json > cluster-autoscaler-policy.json

cluster-autoscaler-autodiscover.yaml:
	sed "s/<YOUR CLUSTER NAME>/$(CLUSTER_NAME)/g" cluster-autoscaler-autodiscover.tpl.yaml > cluster-autoscaler-autodiscover.yaml

.PHONY: clean-files
clean-files:
	rm cluster.yaml
	rm cluster-autoscaler-autodiscover.yaml
	rm cluster-autoscaler-autodiscover-2.yaml
	rm cluster-autoscaler-policy.json

.PHONY: autoscaler
autoscaler: cluster-autoscaler-policy.json cluster-autoscaler-autodiscover.yaml
	eksctl utils associate-iam-oidc-provider --cluster $(CLUSTER_NAME) --approve
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
	eksctl create cluster -f cluster.yaml --name $(CLUSTER_NAME) --region $(REGION) --asg-access
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

