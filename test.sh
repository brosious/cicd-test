
#! /bin/bash 
set -u

if [ -z "$DIGITALOCEAN_ACCESS_TOKEN" ]
then
    echo "Digital access token variable is not defined"
else 
    echo "Digital access token is defined"
    doctl auth init
    mkdir ~/.kube
    doctl kubernetes cluster kubeconfig show kenna > ~/.kube/config
    kubectl get nodes 
fi
