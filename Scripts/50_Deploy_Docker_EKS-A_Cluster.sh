#!/bin/bash

docker ps -a || { echo "there is an issue with Docker.  Is it running?  Exiting now... "; exit; } 

docker kill $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)
docker rm $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)

CLUSTER_NAME=mgmt

# Create the Directories to utilize
DADATE=$(date +%F)
mkdir -p ~/eksa/$CLUSTER_NAME/; cd $_
[ -d latest ] && rm latest
mkdir ${DADATE};
ln -s ${DADATE} latest; cd $_
pwd

eksctl anywhere generate clusterconfig $CLUSTER_NAME --provider docker > $CLUSTER_NAME.yaml
MyTweaks() {
cp $CLUSTER_NAME.yaml $CLUSTER_NAME.orig
sed -i -e 's/192.168.0.0/172.16.0.0/g' $CLUSTER_NAME.yaml
yq -i e --front-matter=process '.spec.controlPlaneConfiguration.count |= 3'  $CLUSTER_NAME.yaml
yq -i e --front-matter=process '.spec.externalEtcdConfiguration.count |= 3'  $CLUSTER_NAME.yaml
yq -i e --front-matter=process '.spec.workerNodeGroupConfigurations.count |= 2'  $CLUSTER_NAME.yaml
sdiff $CLUSTER_NAME.yaml $CLUSTER_NAME.orig
}

unset KUBECONFIG
eksctl anywhere create cluster -f $CLUSTER_NAME.yaml

# To access K8s during the install
export KUBECONFIG=$(find $PWD/ |grep "$CLUSTER_NAME.kind.kubeconfig")

# Access K8s post install
export KUBECONFIG=$(find $PWD/ | grep "${CLUSTER_NAME}.eks-a-cluster.kubeconfig")

# Some quick troubleshooting tips
kubectl get pods -A | awk '{ print "kubectl logs --tail 3 " $2 " -n " $1  "; echo; echo; echo" }' | sh - | more
for POD in $(docker ps -a | grep eks-anywhere | awk '{ print $1 }'); do docker logs --tail 5 $POD; echo "######################"; done

exit 0


#yq e --front-matter=process '.site_name |= "src/" + sub("[^a-zA-Z]", "")' file.yaml
yq e --front-matter=process '.spec.controlPlaneConfiguration.count |= "3")  $CLUSTER_NAME.yaml
/" + sub("[^a-zA-Z]", "")' file.yaml

