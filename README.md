[![Community Extension](https://img.shields.io/badge/Community%20Extension-An%20open%20source%20community%20maintained%20project-FF4700)](https://github.com/camunda-community-hub/community)
[![](https://img.shields.io/badge/Lifecycle-Incubating-blue)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#incubating-)
![Compatible with: Camunda Platform 8](https://img.shields.io/badge/Compatible%20with-Camunda%20Platform%208-0072Ce)

# Camunda 8 Greenfield Installation

Create a Camunda 8 self-managed Kubernetes Cluster in 3 Steps:

Step 1: Setup some [global prerequisites](#global-prerequisites)

Step 2: Setup command line tools for your cloud provider: 

- [Microsoft Azure](#microsoft-azure-prerequisites)
- [Google Cloud](#google-compute-engine-prerequisites)
- [Amazon Web Services](#amazon-web-services-prerequisites)
- [Kind](#kind-local-development-environment-prerequisites) (for local development)

Step 3: Run `make` to create a new kubernetes cluster and install a default Camunda environment.

And when you're finished experimenting, run `make clean` to complete destroy your environment in order to keep hosting 
costs to a minimum.

# Global Prerequisites

Complete the following steps regardless of which cloud provider you use.  

1. Clone this [Camunda 8 Greenfield Installation git repository](https://github.com/camunda-community-hub/camunda8-greenfield-installation)

2. Clone the [Camunda 8 Helm Profiles git repository](https://github.com/camunda-community-hub/zeebe-helm-profiles).

3. Verify `kubectl` is installed

       kubectl --help

4. Verify `helm` is installed. Helm version must be at least `3.7.0`

       helm version

5. Verify GNU `make` is installed. 

       make --version

The next step is to create a Kubernetes Cluster on the cloud provider of your choice.

# A Note about Networking

Kubernetes Networking is, of course, a very complicated topic! There are many ways to configure Ingress and networks
in Kubernetes environments. And to make things worse, each cloud provider has a slightly different flavor of load 
balancers and network configuration options.

The purpose of this project is to provide an opinionated strategy for quickly and easily creating a Kubernetes 
environment running Camunda components. Here's a short summary of how this project configures a simple, prototype network. 

When an ingress controller is installed to Kubernetes, ultimately, it must be available via an IP address. Whether the
ingress controller is backed by nginx, or a load balancer (or other, more complicated, setups), it has to be available
over a network via an ip address in order to be useful. 

Currently, ingress rules for Camunda Kubernetes services must be configured using domain name routing. For example: 
`http://identity.my-domain`. The Camunda components do not currently support url path based routing. 
For example, urls such as `http://domain/identity` (as of Camunda version 8.0.4) will not work.

So, this means, in order to route network traffic via ingress to Camunda, we need dns names!

But, since this project is meant for quick prototyping, we don't want to go through the hassle of setting up custom domain names. 
As a solution, we are using [nip.io](https://nip.io) to quickly and easily translate ip addresses into domain names. 

[nip.io](https://nip.io) provides dynamic domain names for any ip address. For example, if your ip address is `1.2.3.4`, 
a doman name like `my-domain.1.2.3.4.nip.io` will resolve to ip address `1.2.3.4`. It's pretty handy!

So, for example, say our Cloud provider created a Load Balancer listening on ip address `54.210.85.151`. This project 
uses domain names like this: 

http://identity.54.210.85.151.nip.io
http://keycloak.54.210.85.151.nip.io
http://operate.54.210.85.151.nip.io
http://tasklist.54.210.85.151.nip.io

In other words, if you don't have a domain name yet, don't worry, we have you covered! 

And, even if you do have custom domain name ready, you may find it useful to first use this project to install an 
environment using the nip.io formatted domain names described above. This way you can experiment and inspect the kubernetes
components before configuring to use your own custom domain.

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

> :information_source: **Tip** If you or your company uses SSO to sign in to Microsoft, first, open a browser and sign in
> to your Azure/Microsoft account. Then try doing the `az login` command again.

3. Use the Azure-specific `Makefile` to create the cluster

`cd` into the `azure` directory

Update the `./azure/Makefile`. Edit the bash variables so that they are appropriate for your specific environment. 

    resourceGroup ?= <YOUR GROUP NAME>
    clusterName ?= <YOUR CLUSTER NAME>
    region ?= eastus
    machineType ?= Standard_A8_v2
    minSize ?= 1
    maxSize ?= 256

> :information_source: **Note** By default, the vCPU Quota is set to 10 but the default cluster started below requires
> more than 10 vCPUS. You may need to go to the Quotas page and request an increase in the vCPU quota for the
> machine type that you choose.

Run `make` to create an Azure Kubernetes cluster and install Camunda.

Note that the make file for `azure` will prompt for an IP address after it creates the cluster. Here are some notes on
how to find the IP Address of the App Gateway of your newly created Azure cluster.

## Azure App Gateway IP Address

By default, the azure kubernetes cluster created by this project will create an Application Gateway named `myApplicationGateway`.

To find the url of the Application Gateway for your cluster, open a browser and navigate to your Azure console. Find the Application 
Gateway named `myApplicationGateway`, and click on "Frontend IP configurations" and copy the IP address. 

When the make command pauses to ask for IP address, copy and paste this value and press enter to continue the installation. 

## Troubleshooting

The first time you attempt to authenticate to keycloak, you may encounter the following error: 

![Keycloak ssl required](docs/images/keycloak_ssl_required.png?raw=true)

In order to address this issue, we first need temporary access to keycloak. We can accomplish this using Kubernetes 
port forwarding. Run the following command to temporarily establish port forward from localhost to port 18080. 

     make port-keycloak

Now, you should be able to browse to `http://localhost:18080`. By default, the username is `admin` and password 
is `camunda`.

Follow the steps described [here](https://docs.camunda.io/docs/self-managed/identity/troubleshooting/common-problems/#solution-2-identity-making-requests-from-an-external-ip-address)
to fix the issue. 

# Google Compute Engine Prerequisites

1. Verify `gcloud` is installed (https://cloud.google.com/sdk/docs/install-sdk)

       gcloud --help

2. Make sure you are authenticated. If you don't already have one, you'll need to sign up for a new
   Google Cloud Account. Then, run the following command and then follow the instructions to authenticate via your browser.

       $ gcloud auth login

3. Use the Google-specific `Makefile` to create a GKE cluster

`cd` into the `google` directory

Edit the `./google/Makefile` and set the following bash variables so that they are appropriate for your specific environment.

    project ?= <YOUR PROJECT>
    clusterName ?= <YOUR CLUSTER NAME>
    region ?= us-east1-b
    machineType ?= n1-standard-16

Run `make` to create a Google Kubernetes cluster and install Camunda.

# Amazon Web Services Prerequisites

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

     clusterName ?= <YOUR CLUSTER NAME>
     region ?= us-east-1
     zones ?= ['us-east-1a', 'us-east-1b']
     machineType ?= m5.2xlarge
     minSize ?= 4

> :information_source: **Note** Currently autoscaling for AWS is not working yet. For now, minSize is also used to set 
> the starting size of the cluster

5. Run `make` to create a new AKS Cluster and install Camunda

Note that the make file for `aws` will prompt for an IP address after it creates the nginx ingress. Here are some notes on 
how to find the IP Address of the Load Balancer of your newly created EKS cluster. 

## EKS Load Balancer IP Address

When nginx ingress is installed in an EKS environment, AWS will create a Load Balancer. 

To see details, try running the following command:

```shell
kubectl get service -n ingress-nginx
```

You should see output like the following. The EXTERNAL-IP is your load balancer's dns name 

```shell
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.100.160.33    ac5770377baff43b7b35f28d725538eb-1410992827.us-east-1.elb.amazonaws.com   80:30114/TCP,443:31088/TCP   13m
ingress-nginx-controller-admission   ClusterIP      10.100.229.127   <none>                                                                    443/TCP                      13m
```

Alternatively, navigate to the "EC2 Dashboard" within the AWS console. Look on the left side bar and click on "Load Balancers". 
You should find the dns name in the "Basic Configration" section of the screen.   

This domain name is associated to multiple ip addresses, one IP address for each Availability Zone. To find the ip 
addresses used by this domain, try `nslookup` on windows, or `dig` on mac or linux. 

For example, on Windows: 
```shell
nslookup ac5770377baff43b7b35f28d725538eb-1410992827.us-east-1.elb.amazonaws.com
```

Or on Mac/Linux: 
```shell
dig +short ac5770377baff43b7b35f28d725538eb-1410992827.us-east-1.elb.amazonaws.com
```

Choose one of the IP Addresses and copy and paste it into the `make` file prompt to continue the install. 

# Kind (local development environment) Prerequisites 

It's possible to use `kind` to experiment with kubernetes on your local developer laptop, but please keep in mind that 
Kubernetes is not really intended to be run on a single machine. That being said, this can be handy for learning and 
experimenting with Kubernetes. 

1. Make sure to install Docker Desktop (https://www.docker.com/products/docker-desktop/)

2. Make sure that `kind` is installed (https://kind.sigs.k8s.io/)

3. Use `Makefile` inside the `kind` directory to create a k8s cluster. Again, keep in mind that this is an emulated
   kubernetes cluster meant only for development!

       cd kind
       make

The Kind environment is a stripped down version without ingress and without identity enabled. So, once pods start up, 
try using port forwarding to access them. 

For example, try `make port-operate`, and then access operate at localhost: http://localhost:8081

Or, try `make port-tasklist`, and then access task list here: http://localhost:8082

# Cleaning Up

Unless this is a production environment, remember to clean things up! These can cost quite a lot of money if you leave 
them running. 

Run `make clean` to completely delete all kubernetes objects as well as the cluster.

# Other Useful Commands 

There are several `make` targets that are available no matter what cloud provider you use. Here are a few: 

## Configure your kubectl

Run `make use-kube` to make sure that your local `kubectl` environment is configured to connect to the appropriate cluster. 

## Find urls to management console

Run `make urls` to see which url to use in order to manage your cluster. In google cloud, this will show you the url
to the GKE console, in aws this will show the EKS cluster, etc. 

## Port Forwarding

Run the following commands to establish port forwarding to your localhost

```shell
make port-zeebe
make port-keycloak
make port-identity
make port-operate
make port-tasklist
make port-optimize
```

## Stop and Uninstall Camunda 

Run the following command to uninstall the Camunda components, but leave the cluster intact.

This can be handy for benchmarking and performance tuning, when you don't want to wait for an entire cluster to be re-created. 

```shell
make clean-camunda
```

Later, when you want to install and start camunda again, simply run `make camunda`.
