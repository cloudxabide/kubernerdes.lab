# Tips and Tricks

Status:  This doc is a mess - but has useful commands.  I'll clean it up at some point

## Helpful commands
```
for NS in $(kubectl get ns | grep -v ^NAME | awk '{ print $1 }'); do echo "Namespace: $NS"; kubectl top pods -n $NS --sort-by=memory; echo; done
```

## Installation Overview
### Installer Process
### Watch the logs of the last command until you see...
You will see 3 containers start and run (an ECR container, the KIND cluster, then "boots")
#   "Creating new workload cluster", then...
```
watch docker ps -a

docker logs -f $(docker ps -a | grep boots | awk '{ print $1 }')
```

### You can then start powering on your NUC and boot from the network and watch the Docker logs

### Cleanup
```
docker kill $(docker ps -a | awk '{ print $1 }' | grep -v CONTAINER)
docker rm $(docker ps -a | awk '{ print $1 }' | grep -v CONTAINER)
rm -rf kubernerdes-eksa eksa-cli-logs
```

##
```
kubectl debug node/mgmt-gm6m6 -it --image ubuntu
```

# You will see 3 containers start and run (an ECR container, the KIND cluster, then "boots")
```
watch docker ps -a

```
# Go back to the window where the "watch" command was running and kill the watch.  Then run
```
docker logs -f <container id of "boots" container>
docker logs -f $(docker ps -a | grep boots | awk '{ print $1 }')
```


# Random "shortcuts" that *I* can use to run Kubectl
```
export KUBECONFIG=${PWD}/${CLUSTER_NAME}/${CLUSTER_NAME}-eks-a-cluster.kubeconfig
export KUBECONFIG=$(find ~/DevOps/eksa -name '*kind.kubeconfig')
export KUBECONFIG=$(find ~/DevOps/eksa -name '*cluster.kubeconfig')

kubectl get nodes -A -o wide --show-labels
kubectl get nodes -A -o wide --show-labels=true
kubectl get hardware -n eksa-system --show-labels
```

##
# Deploy a Test App (To test the new storage class)
##
```
kubectl create namespace openebstest
kubectl config set-context --current --namespace=openebstest
curl -o busybox_example_app_persisent_storage.yaml https://raw.githubusercontent.com/GIT_OWNER/kubernerdes.lab/main/Files/busybox_example_app_persisent_storage.yaml
kubectl apply -f busybox_example_app_persisent_storage.yaml
# Watch the pods until the busybox pod is "Running", then exit
while sleep 1; do kubectl get pods -n openebstest | grep Running && break ; done

# Review hosts for new disk image file
HOSTS="eks-host01 eks-host02 eks-host03"
for HOST in $HOSTS
do
  echo ""
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "
    sudo iscsiadm -m session -o show
    find  /var/openebs/local -name 'volume-head*.img' -exec ls -lh {} \; "
done
```

# Clean up app
## ADD SECTION FOR REMOVING THE APP
```
kubectl delete namespace openebstest

```
# And check again for the storage block device images
```
for HOST in $HOSTS
do
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "
    sudo iscsiadm -m session -o show
    find  /var/openebs/local -name 'volume-head*.img' -exec ls -lh {} \; "
done
```

## Example code to run someone on each Host
```
HOSTS="eks-host01 eks-host02 eks-host03"
for HOST in $HOSTS
do
  echo ""
  ssh -i ~/.ssh/id_ecdsa-kubernerdes.lab ec2-user@$HOST "
    cat /etc/*release*
  "
done
```

1) Command to list pods running in which node and which availability zone:
```

kubectl get pods -A -o custom-columns="POD:metadata.name,NODE:spec.nodeName" | tail -n +2 | while read pod node
do
 echo -n "$pod $node "
 kubectl get node "$node" -o jsonpath="{.metadata.labels.topology\.kubernetes\.io/zone}"
 echo ""
done
```

2) List of nodes and how many pods running on them:
```
kubectl get pods -A -o json --all-namespaces | \
 jq '.items | group_by(.spec.nodeName) | map({"nodeName": .[0].spec.nodeName, "count": length}) | sort_by(.count)'
```

3) List pods using most of RAM and CPU:
For CPU:
```
kubectl top pods -A | sort --reverse --key 3 --numeric
```

For RAM:
```
kubectl top pods -A | sort --reverse --key 4 --numeric
```

4) Getting pods that are continuously restarting (sorting them):
```
kubectl get pods --all-namespaces -o json | jq -r '.items | sort_by(.status.containerStatuses[0].restartCount) | reverse[] | [.metadata.namespace, .metadata.name, .status.containerStatuses[0].restartCount] | @tsv' | column -t
```

5) Quickly check the pod limits:
```
kubectl get pods -A -o=custom-columns='NAME:spec.containers[*].name,MEMREQ:spec.containers[*].resources.requests.memory,MEMLIM:spec.containers[*].resources.limits.memory,CPUREQ:spec.containers[*].resources.requests.cpu,CPULIM:spec.containers[*].resources.limits.cpu'
```

6) Get all private IPs of nodes:
```
kubectl get nodes -o json | \
 jq -r '.items[].status.addresses[]? | select (.type == "InternalIP") | .address' | \
 paste -sd "\n" -
```

7) Checking logs:
Read logs with human readable timestamp:
```
kubectl logs -f my-pod --timestamps
```

Check 100 logs:
```
kubectl logs -f my-pod --tail=100
```

8) Check for events across all namespaces and filter for any errors,
```
kubectl get events --all-namespaces --field-selector type=Warning -o wide
```
or
```
kubectl get events --all-namespaces --field-selector type!=Normal -o wide
```

9) Tail the logs of all running containers

```
kubectl get pods -A | awk '{ print "kubectl logs --tail 5 " $2 " -n " $1  "; echo; echo" }' | sh - | more
```
