#!/bin/bash

docker ps -a || { echo "there is an issue with Docker.  Is it running?  Exiting now... "; exit; } 

docker kill $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)
docker rm $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)

DADATE=$(date +%F)
CLUSTER_NAME=mgmt
mkdir -p ~/eksa/$CLUSTER_NAME/; cd $_
mkdir ${DADATE};
ln -s ${DADATE} latest; cd $_


# eksctl anywhere generate clusterconfig $CLUSTER_NAME --provider docker > $CLUSTER_NAME.yaml
sed -i -e 's/192.168.0.0/172.16.0.0/g' $CLUSTER_NAME.yaml
unset KUBECONFIG
eksctl anywhere create cluster -f $CLUSTER_NAME.yaml

export KUBECONFIG=$(find $PWD/ -name $CLUSTER_NAME.kind.kubeconfig)
export KUBECONFIG=$(find $PWD/  | grep "${CLUSTER_NAME}.eks-a-cluster.kubeconfig")
find $PWD/ -name $CLUSTER_NAME.eks-a-cluster.kubeconfig)

kubectl get pods -A | awk '{ print "kubectl logs --tail 3 " $2 " -n " $1  "; echo; echo; echo" }' | sh - | more
for POD in $(docker ps -a | grep eks-anywhere | awk '{ print $1 }'); do docker logs --tail 5 $POD; echo "######################"; done

