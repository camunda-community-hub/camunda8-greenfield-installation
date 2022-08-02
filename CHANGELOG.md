## August 2 2022

- Changed `use-k8s` to `use-kube`
- Now using the `-e` to pass top level Makefile variables down to sub make
- Had to include `camunda.mk` in top level Makefile in order to have access to targets like `port-zeebe`
- Had to change this:

       sed -Ei "s/\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/$$IP/g" camunda-values.yaml

  to this: 

       sed -Ei '' "s/([0-9]{1,3}\.){3}[0-9]{1,3}/$$IP/g" camunda-values.yaml
- Long story short: I reamed `ingress-ip` to `ingress-ip-from-service`. And I added `ingress-ip-from-commandline`.  

  AWS gives dns name that resolves to several ip addresses. One ip address for each availability zone. For example: 
  
       kubectl get service -n ingress-nginx
       NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)                      AGE
       ingress-nginx-controller             LoadBalancer   10.100.66.193   a6e4157656634474fb0c4480dd894683-683984428.us-east-1.elb.amazonaws.com   80:30828/TCP,443:30157/TCP   112m

  There are several ways to configure this: 
  1. Pass parameters to helm charts (just put the extra parameters into a variable and leave that empty when running without ingress)
  2. Use `aws` command line to configure subdomains via rout s3 service?
  3. Create multiple nginx ingress controllers: one for each service?

  For now, the make file will pause and prompt the user to enter an ip address. 

