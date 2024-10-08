#!/bin/bash

#     Purpose: This script will prep the hosts and then install/configure openEBS
#        Date: 2024-06-04
#      Status: Work in Progress | Should be complete.  Need to test if it can be run as stand-alone
# Assumptions: This script assumes that you are using a dummy/disposable cluster, created using 3-nodes 
#                which are both control-plane and worker nodes (basically my lab setup).
#              Additionally, this is intended to only run on Bare Metal nodes.
#        Todo:
#  References:
#       Notes: I separate some of the commands in their own stanza (i.e. I run a for-loop to 
#                install, then another for-loop to check status).  This allows me to 
#                cut-and-paste sections of code while I am testing.  (in case my code 
#                looks ineffecient ;-)

# HOSTS="eks-mgmt-01 eks-mgmt-02 eks-mgmt-03"
# kubectl get nodes -o=jsonpath='{.items[1].metadata.labels.kubernetes\.io/hostname}'
HOSTS=$(kubectl get nodes --no-headers | awk '{ print $1 }')
echo "Hosts: $HOSTS"

# Install the iSCSI components on the worker nodes
# NOTE:  If openEBS was something to be used in "production", you would want to include these 
#          steps in your host build that would be used to deploy your worker nodes.

# Clean up the SSH Keys (note: this is REALLY not a secure practice - this is just for my lab)
for HOST in $HOSTS
do
  ssh-keygen -f "/home/mansible/.ssh/known_hosts" -R "$HOST"
  ssh-keygen -f "/home/mansible/.ssh/known_hosts.kubernerdes.lab" -R "$HOST"
  ssh -oStrictHostKeyChecking=accept-new -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "uptime"
done

##
# Install iSCSI
##
for HOST in $HOSTS
do
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST " 
    sudo apt-get update
    sudo apt-get install -y open-iscsi
    sudo systemctl enable --now iscsid"
done

# Check status of iSCSI
for HOST in $HOSTS
do
  echo "#################################################"
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "
    uname -n
    sudo systemctl status iscsid"
done

## 
# Create a fileystem on spare disk (specific to my lab)
# NOTE:  This is where things start to occur that are irreversible 
# TODO:  Perhaps I could make this dynamically figure out which disk/device is free
## 
EBS_DEVICE_NAME="nvme0n1"
export EBS_DEVICE="/dev/$EBS_DEVICE_NAME"
case $EBS_DEVICE_NAME in
  nvme0n1)
    export EBS_DEVICE_PARTITION="${EBS_DEVICE}p1"
  ;;
  sda)
    export EBS_DEVICE_PARTITION="${EBS_DEVICE}1"
esac
 
echo "Disk: $EBS_DEVICE"
echo "Partition: $EBS_DEVICE_PARTITION"

# Wipe the Disk (THIS IS DESTRUCTIVE - like, for real)
# NOTE: This needs some cleanup still - and to be clear, this section exists because 
#       I reuse the lab resources to deploy my cluster repeatedly.
for HOST in $HOSTS
do
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "
    sudo umount /var/openebs
    sudo lvremove --force /dev/mapper/vg_localstorage-lv_openebs
    sudo vgremove --force vg_localstorage
    sudo pvremove --force ${EBS_DEVICE_PARTITION}
    sudo wipefs -a $EBS_DEVICE" 
done

# Review devices - they should have no partitions now
for HOST in $HOSTS
do
  echo "######################################################"
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "lsblk"
  echo ""
done

######################################################
# BEGINNING OF FOR-LOOP
# Configure the devices
for HOST in $HOSTS
do
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "
    sudo parted -s $EBS_DEVICE mklabel gpt mkpart pri ext4 2048s 100%FREE set 1 lvm on
    sudo partprobe $EBS_DEVICE
    sudo pvcreate -f ${EBS_DEVICE_PARTITION}
    sudo vgcreate vg_localstorage ${EBS_DEVICE_PARTITION}
    sudo lvcreate -L300G -nlv_openebs vg_localstorage
    sudo mkfs.ext4 /dev/mapper/vg_localstorage-lv_openebs 
    sudo mkdir /var/openebs

# Initial tests of using systemd-mnt look good (2024-06-06)
# https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html
# https://www.freedesktop.org/software/systemd/man/systemd.automount.html

sudo mkdir -p /var/openebs

cat <<'EOF' | sudo tee /etc/systemd/system/var-openebs.mount
[Unit]
Description=Mount OpenEBS Volume
Documentation=https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html
 
[Mount]
What=/dev/mapper/vg_localstorage-lv_openebs
Where=/var/openebs
Type=ext4
Options=defaults
DirectoryMode=0770
#TimeoutSec=10
 
[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl enable --now var-openebs.mount"

done
# END OF FOR-LOOP
######################################################

# Make sure the volume/fileystem is created/mounted
for HOST in $HOSTS
do
  echo "################################################"
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "
    uname -n 
    sudo vgs
    sudo pvs
    echo 
    lsblk
    echo 
    df -h | grep openebs"
  echo
done

##
# Install OpenEBS via helm
##
helm repo add openebs https://openebs.github.io/charts
helm repo update

helm upgrade openebs openebs/openebs \
--install \
--namespace openebs \
--create-namespace \
--set jiva.enabled=true

# Watch the pods until there is no longer a "ContainerCreating" output, then show ALL pods in the openebs namespace
while sleep 2; do echo; kubectl get pods -n openebs | grep ContainerCreating || break; done
kubectl get pods -n openebs

# Make openEBS your default storage class
kubectl patch storageclass openebs-jiva-csi-default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl get sc

exit 0

## Code Snippet to run a command on the nodes

for HOST in $HOSTS
do
  echo "################################################"
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "
    uname -n
    # Your code goes here
    #sudo lvresize -L+300G /dev/mapper/vg_localstorage-lv_openebs
    #sudo resize2fs /dev/mapper/vg_localstorage-lv_openebs 400G
    df -h | grep openebs"
  echo
done
