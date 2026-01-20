#!/bin/bash
# -x


#set -euo pipefail

# Default kubeconfig location
KUBECONFIG="${HOME}/.kube/config"
NAMESPACE="default"
#insecure=--insecure-skip-tls-verify

# Parse command-line options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--config)
      KUBECONFIG="$2"
      shift 2
      ;;
    *)
      echo "Usage: $0 [-c|--config <kubeconfig>]"
      exit 1
      ;;
  esac
done

# Get all context names from kubeconfig
contexts=$(kubectl config --kubeconfig="$KUBECONFIG" get-contexts -o name)

for ctx in $contexts; do
  echo "=== Processing Cluster: $ctx ==="
  
  # Switch to current context
  kubectl config use-context "$ctx" --kubeconfig="$KUBECONFIG" >/dev/null
  
  # Get all nodes in the cluster, then run the commands
  for node in $(kubectl ${insecure} --kubeconfig="$KUBECONFIG" get nodes -o custom-columns=NAME:.metadata.name --no-headers);
  do 
      #POD_NAME="debug-${node//./-}-$(date +%s)"  # Node-safe unique name
      SOCKET_COUNT=$(kubectl ${insecure} --profile=general debug -q -it node/${node} -n $NAMESPACE --image=registry.suse.com/bci/bci-base:15.7  -- bash -c 'grep physical\ id /proc/cpuinfo | sort -u | wc -l')
      # kubectl --kubeconfig="$KUBECONFIG" wait --for=condition=Ready pod/$POD_NAME -n $NAMESPACE --timeout=30s >/dev/null 2>&1

      echo "Cluster: ${ctx} | Socket Count (${node}): ${SOCKET_COUNT}"; 
  done
  # Delete pod(s) -- this is done outside the for-loop as it takes a few cycles to complete each delete
  echo "# Note: we will now cleanup all debug pods in cluster: $ctx"
  kubectl ${insecure} delete pod $(kubectl ${insecure} get pods -n $NAMESPACE -o custom-columns=NAME:.metadata.name | grep node-debugger) > /dev/null;
done
echo 

exit 0


################3
# TODO:
notes {
would be nice to either 1/ name the pod when created, and only delete the single pod we create  2/ maybe create UUID-based namespace to place the debug pod in

# Cleanup ALL pods with "node-debugg" - kind of dangerous, but works for now
#   kubectl delete $(kubectl get pods --all-namespaces -o name | grep node-debugg)
}
