#!/bin/bash


docker kill $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)
docker rm $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)

CLUSTER_NAME=mgmt
# eksctl anywhere generate clusterconfig $CLUSTER_NAME --provider docker > $CLUSTER_NAME.yaml
eksctl anywhere create cluster -f $CLUSTER_NAME.yaml

export KUBECONFIG=$(find $PWD -name $CLUSTER_NAME.kind.kubeconfig)

kubectl get pods -A | awk '{ print "kubectl logs --tail 5 " $2 " -n " $1  "; echo; echo" }' | sh - | more


