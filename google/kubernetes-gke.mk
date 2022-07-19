.PHONY: k8s
k8s: kube

.PHONY: kube
kube:
	gcloud config set project $(PROJECT)
	gcloud container clusters create $(CLUSTER_NAME) \
	  --region $(REGION) \
	  --num-nodes=1 \
	  --enable-autoscaling --max-nodes=256 --min-nodes=1 \
	  --enable-ip-alias \
	  --machine-type=$(MACHINE_TYPE) \
	  --disk-type "pd-ssd" \
	  --preemptible \
	  --maintenance-window=4:00 \
	  --release-channel=regular \
	  --cluster-version=latest
	kubectl apply -f ./ssd-storageclass-gke.yaml

.PHONY: clean-k8s
clean-k8s: use-k8s clean-kube

.PHONY: clean-kube
clean-kube:
#	-kubectl delete pvc --all
	@echo "Please check the console if all PVCs have been deleted: https://console.cloud.google.com/compute/disks?authuser=0&project=$(PROJECT)&supportedpurview=project"
	gcloud container clusters delete $(CLUSTER_NAME) --region $(REGION) --async --quiet

.PHONY: use-k8s
use-k8s:
	gcloud config set project $(PROJECT)
	gcloud container clusters get-credentials $(CLUSTER_NAME) --region $(REGION)

.PHONY: urls
urls:
	@echo "Cluser: https://console.cloud.google.com/kubernetes/clusters/details/$(REGION)/$(CLUSTER_NAME)/details?project=$(PROJECT)"
	@echo "Workloads: https://console.cloud.google.com/kubernetes/workload/overview?project=$(PROJECT)&pageState=(%22savedViews%22:(%22i%22:%221cd686805f0e43189d3b33934863017b%22,%22c%22:%5B%22gke%2F$(REGION)%2F$(CLUSTER_NAME)%22%5D,%22n%22:%5B%5D))"
