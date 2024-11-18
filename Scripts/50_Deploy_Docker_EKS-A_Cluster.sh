#!/bin/bash

docker ps -a || { echo "there is an issue with Docker.  Is it running?  Exiting now... "; exit; } 

docker kill $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)
docker rm $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)

# docker system prune --volumes

CLUSTER_NAME=mgmt

# Create the Directories to utilize
DADATE=$(date +%F)
mkdir -p ~/eksa/$CLUSTER_NAME/; cd $_
[ -d latest ] && rm latest
mkdir ${DADATE};
ln -s ${DADATE} latest

cd ~/eksa/$CLUSTER_NAME/latest
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

download_artifacts() {
eksctl anywhere download artifacts
tar -xvf eks-anywhere-downloads.tar.gz
eksctl anywhere download images -o images.tar

# you need to disable "AirPlay Receiver"
docker run -d -p 5000:5000 --name registry registry:2.7
sudo lsof -i -n -P  | grep 5000
docker pull ubuntu
docker tag ubuntu localhost:5000/ubuntu
docker login http://localhost:5000/ 
docker push localhost:5000/ubuntu

export REGISTRY_USERNAME=eksa
export REGISTRY_PASSWORD=eksa
export REGISTRY_MIRROR_URL=localhost:5000
eksctl anywhere import images -i images.tar -r ${REGISTRY_MIRROR_URL} --bundles ./eks-anywhere-downloads/bundle-release.yaml


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

# Cleanup - this removes *EVERYTHING*
docker ps -a || { echo "there is an issue with Docker.  Is it running?  Exiting now... "; exit; }

docker kill $(docker ps -a | awk '{ print $1 }' | grep -v CONTAINER)
docker rm $(docker ps -a | awk '{ print $1 }' | grep -v CONTAINER)
docker system prune
docker image prune -a
docker volume prune
