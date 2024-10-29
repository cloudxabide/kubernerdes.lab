#!/bin/bash

docker kill $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)
docker rm $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)

CLUSTER_NAME=mgmt
mkdir -p ~/eksa/$CLUSTER_NAME; cd $_
# eksctl anywhere generate clusterconfig $CLUSTER_NAME --provider docker > $CLUSTER_NAME.yaml
eksctl anywhere create cluster -f $CLUSTER_NAME.yaml

export KUBECONFIG=$(find $PWD -name $CLUSTER_NAME.kind.kubeconfig)

kubectl get pods -A | awk '{ print "kubectl logs --tail 3 " $2 " -n " $1  "; echo; echo; echo" }' | sh - | more
for POD in $(docker ps -a | grep eks-anywhere | awk '{ print $1 }'); do docker logs --tail 5 $POD; echo "######################"; done


