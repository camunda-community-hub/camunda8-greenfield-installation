[![Community Extension](https://img.shields.io/badge/Community%20Extension-An%20open%20source%20community%20maintained%20project-FF4700)](https://github.com/camunda-community-hub/community)
[![](https://img.shields.io/badge/Lifecycle-Incubating-blue)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#incubating-)

# Camunda 8 Greenfield Installation

This project contains Makefiles that help to quickly create a Camunda 8 self-managed Kubernetes environment in
Google Cloud or Microsoft Azure. (Stay tuned: AWS comming soon!)

To get started, first make sure you have installed and configured the prerequisite tools (see the sections below for more info). 

Then, run `make k8s` to create a new kubernetes cluster. 
Run `make camunda` to install and start Camunda in the cluster.

# Global Prerequisites

Complete the following steps regardless of which cloud provider you use.  

1. Verify `kubectl` is installed

       kubectl --help

2. Verify `helm` is installed. Helm version must be at least `3.7.0`

       helm version

3. Clone this [Camunda 8 Greenfield Installation git repository](https://github.com/camunda-community-hub/camunda8-greenfield-installation)

At this point, you should have a local directory named `camunda8-greenfield-installation`

The next step is to create a Kubernetes Cluster on the provider of your choice.

# Microsoft Azure Prerequisites

1. Verify that the `az` cli tool is installed (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

       $ az version
       {
        "azure-cli": "2.38.0",
        "azure-cli-core": "2.38.0",
        "azure-cli-telemetry": "1.0.6",
        "extensions": {}
       }

2. Make sure you are authenticated. If you don't already have one, you'll need to sign up for a new
   Azure Account. Then, run the following command and then follow the instructions to authenticate via your browser.

       $ az login

> :information_source: **Tip** If you're using SSO, first, open a browser and sign in to your Azure/Microsoft account.
> Then try doing the `az login` command again.

3. Use the Azure-specific `Makefile` to create the cluster

`cd` into the `azure` directory

Update the following bash variables so they are appropriate for your specific environment. 

     RESOURCE_GROUP ?= <YOUR GROUP NAME>
     CLUSTER_NAME ?= <YOUR CLUSTER NAME>
     REGION ?= eastus
     MACHINE_TYPE ?= Standard_A8_v2
     MIN_NODE_COUNT ?= 1
     MAX_NODE_COUNT ?= 256

> :information_source: **Note** By default, the vCPU Quota is set to 10 but the default cluster started below requires 
> more than 10 vCPUS. Either configure the camunda-values-dev.yaml file, or you may need to go to the Quotas page and 
> request an increase in the vCPU quota for the machine type that you choose. 

Run `make k8s` to create an Azure Kubernetes cluster

4. Run `make use-k8s` to make sure that your local `kubectl` environment is configured to connect to the new cluster.

5. Run `make urls` to see which url to use in order to manage your Azure Kubernetes cluster

# Google Compute Engine Prerequisites

1. Verify `gcloud` is installed (https://cloud.google.com/sdk/docs/install-sdk)

       gcloud --help
       # Google also requires the following plugin as of 2022
       gcloud components install gke-gcloud-auth-plugin

2. Make sure you are authenticated. If you don't already have one, you'll need to sign up for a new
   Google Cloud Account. Then, run the following command and then follow the instructions to authenticate via your browser.

       $ gcloud auth login

3. Use the Google-specific `Makefile` to create a GKE cluster

`cd` into the `google` directory

Edit the `./google/Makefile` and set the following bash variables so that they are appropriate for your specific environment.

     PROJECT ?= <YOUR PROJECT>
     CLUSTER_NAME ?= <NAME OF CLUSTER>
     REGION ?= us-east1-b
     MACHINE_TYPE ?= n1-standard-8

Run `make k8s` to create an Google Kubernetes cluster

4. Run `make use-k8s` to make sure that your local `kubectl` environment is configured to connect to the new cluster.

5. Run `make urls` to see which url to use in order to manage your GKE cluster

## Amazon Web Services Prerequisites

1. Verify `aws` command line tool is installed (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

       aws --help

2. Configure `aws` to connect to your account. If you don't already have one, you'll need to sign up for a new
   AWS Account. Use the following command to configure the `aws` tool to use your AWS Access Key ID and secret. 

       $ aws configure

Double check you can connect by running the following

       $ aws iam get-account-summary

3. Verify `eksctl` is installed (https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)

       $ eksctl version

4. Use the AWS-specific `Makefile` to create a GKE cluster

`cd` into the `aws` directory

Edit the `./aws/Makefile` and set the following bash variables so that they are appropriate for your specific environment.

    CLUSTER_NAME ?= <YOUR CLUSTER NAME>
    REGION ?= us-east-1

## Kind (local development environment) Prerequisites 

It's possible to use `kind` to experiment with kubernetes on your local developer laptop, but please keep in mind that 
Kubernetes is not really intended to be run on a single machine. That being said, this can be handy for learning and 
experimenting with Kubernetes. 

1. Make sure to install Docker Desktop (https://www.docker.com/products/docker-desktop/)

2. Make sure that `kind` is installed (https://kind.sigs.k8s.io/)

3. Use `Makefile` inside the `kind` directory to create a k8s cluster. Again, keep in mind that this is a weird, emulated
   kubernetes cluster. 

       cd kind
       make k8s

# Commands

If you haven't already, make sure to follow the Prerequisite steps above. At this point, you should have a Kubernetes 
Cluster created on the cloud provider of your choice. 

See the sections below for the commands that are available to install (and uninstall) different camunda related 
components

## Install (and Uninstall) Camunda 8 Environment

To start a basic Camunda environment, run the following: 

     make camunda

By default, this command will create a Camunda 8 environment that includes Zeebe Brokers, the Zeebe Gateway, 
Elasticsearch, Operate, and Tasklist. 

When you're finished, or want to start over, you can remove camunda by running: 

    make clean-camunda

# Cleaning Up

Unless this is a production environment, remember to clean things up! These can cost quite a lot of money if you leave them running. 

Run `make clean` to completely delete all kubernetes objects as well as the cluster.




