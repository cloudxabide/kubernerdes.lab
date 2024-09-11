#!/bin/sh

#     Purpose:  Deploy the ECS demo 3-tier App
#        Date:  2024-07-02
#      Status:  GTG | 
# Assumptions:
#        Todo:
#  References: 

# Manually clone
#git clone https://github.com/GIT_OWNER/eks-workshop.git
#git clone https://github.com/GIT_OWNER/ecsdemo-frontend.git
#git clone https://github.com/GIT_OWNER/ecsdemo-nodejs.git
#git clone https://github.com/GIT_OWNER/ecsdemo-crystal.git

cd ${HOME}/eksa/$CLUSTER_NAME/latest
mkdir ecsdemo; cd $_

kubectl create ns ecsdemo
kubectl config set-context --current --namespace=ecsdemo

for PROJECT in ecsdemo-nodejs ecsdemo-crystal ecsdemo-frontend
do 
  [ -d $PROJECT ] && { cd $PROJECT; git pull; } || { git clone  https://github.com/GIT_OWNER/$PROJECT; cd $PROJECT; }
  kubectl apply -f kubernetes/deployment.yaml
  kubectl apply -f kubernetes/service.yaml
  kubectl get deployment $PROJECT
  cd -
done

FRONTEND_IP=$(kubectl get service ecsdemo-frontend -o json | jq -r '.status.loadBalancer.ingress[].ip')
echo "Access FrontEnd at: http://$FRONTEND_IP/"

scale_out() {
kubectl scale deployment ecsdemo-nodejs --replicas=3 -n ecsdemo
kubectl scale deployment ecsdemo-crystal --replicas=3 -n ecsdemo
kubectl scale deployment ecsdemo-frontend --replicas=3 -n ecsdemo
}
scale_in() {
kubectl scale deployment ecsdemo-nodejs --replicas=1 -n ecsdemo
kubectl scale deployment ecsdemo-crystal --replicas=1 -n ecsdemo
kubectl scale deployment ecsdemo-frontend --replicas=1 -n ecsdemo
}

while sleep 2; do echo; kubectl get pods | egrep ContainerCreating || break; done
kubectl config set-context --current --namespace=default

exit 0

######################################
######################################
######################################
# To clean up
kubectl delete ns ecsdemo

## TO RUN THE ORIGINAL VERSION
# works, but it is dependent on "AZs" for the visualization
git clone https://github.com/aws-containers/ecsdemo-frontend.git
git clone https://github.com/aws-containers/ecsdemo-nodejs.git
git clone https://github.com/aws-containers/ecsdemo-crystal.git

for PROJECT in ecsdemo-nodejs ecsdemo-crystal ecsdemo-frontend
do
  cd $PROJECT
  kubectl apply -f kubernetes/deployment.yaml
  kubectl apply -f kubernetes/service.yaml
  cd -
done

## Cleanup
for PROJECT in ecsdemo-nodejs ecsdemo-crystal ecsdemo-frontend
do
  cd $PROJECT
  kubectl delete -f kubernetes/deployment.yaml
  kubectl delete -f kubernetes/service.yaml
  cd -
done

