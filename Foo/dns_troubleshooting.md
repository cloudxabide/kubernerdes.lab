kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl exec -it dnsutils -- nslookup stackstate.kubernerdes.lab



   export KUBECONFIG=/Users/jradtke/Developer/Projects/observability.kubernerdes.lab/local-harvester-dc.kubeconfig && kubectl logs -n suse-observability suse-observability-agent-cluster-agent-8577bcfd84-hgr6b --tail=30 | grep -E "(ERROR|successfully|Success|lookup observability)" || echo "No DNS errors found in recent logs"

