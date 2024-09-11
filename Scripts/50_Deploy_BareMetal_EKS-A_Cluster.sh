#!/bin/bash

#     Purpose: deploy an EKS Anywhere Cluster on Bare Metal
#        Date: 2024-07-01
#      Status: GTG 
# Assumptions:
#        Todo:
#  References:

#############
## EKS Anywhere
#############
# Install EKS Anywhere
echo "Check out the following Doc"
echo "https://anywhere.eks.amazonaws.com/docs/getting-started/baremetal/bare-spec/"

# AWS Info file for Curated Packages
# I made this in to a routine as it should not be run as part of a script (ie you need to provide the details (below))
# I also don't like executing these commands to end up in my SHELL history (even if they are short-lived creds)
Curated_Packages() {
cat << EOF > ./.eksainfo
export EKSA_AWS_ACCESS_KEY_ID=""
export EKSA_AWS_SECRET_ACCESS_KEY=""
export EKSA_AWS_REGION="us-east-1"
EOF
.  ./.eksainfo

[ -z $EKSA_AWS_ACCESS_KEY_ID ] && { echo "Whoa there.... you need to set your EKSA_AWS_ACCESS_KEY_ID and associated variables, if you wish to use Curated Packages"; sleep 4;  }
}

############# ############# ############# ############# ############# #############
## START HERE ## START HERE ## START HERE ## START HERE ## START HERE ## START HERE
############# ############# ############# ############# ############# #############
## Cleanup existing Docker Containers (will show errors if no containers are running)
cd
docker kill $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)
docker rm $(docker ps -a | egrep 'boots|eks' | awk '{ print $1 }' | grep -v CONTAINER)

# Set Cluster-Specific Variables 
OS=ubuntu
NODE_LAYOUT="3_0"
KUBEVERSION="1.28"
export CLUSTER_NAME=kubernerdes-eksa
export CLUSTER_CONFIG=${CLUSTER_NAME}.yaml
export CLUSTER_CONFIG_SOURCE="example-clusterconfig-${OS}-${KUBEVERSION}-${NODE_LAYOUT}.yaml" # Name of file in Git Repo
export TINKERBELL_HOST_IP=10.10.12.101

# Create a Cluster-Specific directory for this install
TODAY=`date +%F`
EKS_BASE=$HOME/eksa/$CLUSTER_NAME
EKS_DIR=$EKS_BASE/${TODAY}
[ -d ${EKS_DIR}  ] && { mv ${EKS_DIR} ${EKS_DIR}-01; }
mkdir -p $EKS_DIR
cd ${EKS_BASE}/
rm latest
ln -s $EKS_DIR ${EKS_BASE}/latest
cd ${EKS_DIR}
mkdir $CLUSTER_NAME 

# Retrieve Cluster-Specific config - this a static URL (i.e. I cannot reference $REPO as this is the file that sets the value)
[ ! -f ENV.vars ] && { curl -o ENV.vars https://raw.githubusercontent.com/GIT_OWNER/kubernerdes.lab/main/Files/ENV.vars; }
. ./ENV.vars
echo "Repo URL: $REPO"

# The following command is how you create a default clusterconfig (created as a reference)
eksctl anywhere generate clusterconfig $CLUSTER_NAME --provider tinkerbell > $CLUSTER_CONFIG.default

# However, I have one that I have already modified for this cluster
curl -o $CLUSTER_CONFIG.vanilla ${REPO}main/Files/$CLUSTER_CONFIG_SOURCE

# Retrieve the hardware inventory csv file (custom to environment)
curl -o hardware.csv ${REPO}main/Files/hardware-${NODE_LAYOUT}.csv
cat hardware.csv

# Retrieve the SSH pub key for the "kubernerdes.lab" domain (this will be needed once cluster has deployed)
export MY_SSH_KEY=$(cat ~/.ssh/*kubernerdes.lab.pub)
# Update the cluster config with my own configuration values
envsubst <  $CLUSTER_CONFIG.vanilla > $CLUSTER_CONFIG
# Compare the original with the updated
sdiff $CLUSTER_CONFIG.vanilla $CLUSTER_CONFIG | egrep '\|'

## Let's build our cluster
sudo systemctl stop isc-dhcp-server.service
unset KUBECONFIG
eksctl anywhere create cluster \
  --hardware-csv hardware.csv \
   -f  $CLUSTER_CONFIG

export KUBECONFIG=$(find $PWD/ -name "*kubeconfig")
cp $KUBECONFIG ${HOME}/.kube/

exit 0

# Now that you have started the installation, shift focus to your other terminal and watch the pods 
echo ""
echo "You will now see the docker command (below) wait until the -boots- container is running, then move to the next step to follow the boots process"
echo "I typically do not start powering on nodes until I see 'Creating new workload cluster' from the installer output"
echo ""
echo "You should now start to power on your NUC, one at a time, and hit F12 until the network boot starts."
echo "  Wait for the initramfs to finish loading, then move to the next node"; sleep 3
echo ""
while sleep 2; do echo -n "Waiting for 'Running'....then will proceed. "; date; docker ps -a | grep boots && break ; done && sleep 30 && docker logs -f $(docker ps -a | grep boots | awk '{ print $1 }')

# Once cluster is built, set the KUBECONFIG (and copy it to html directory)
export KUBECONFIG=$(find ~/eksa/$CLUSTER_NAME/latest/ -name '*eks-a-cluster.kubeconfig' | sort | tail -1)
cp $KUBECONFIG /var/www/html/
