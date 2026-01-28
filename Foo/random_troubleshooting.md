# Random Troubleshooting

## Force Delete a cluster
If you happen to login to your Rancher UI and click on Cluster and see there is a count of 2, but you only see 1 listed in the pane, you may want/need to delete the orphaned/phantom cluster

Make sure you are using the correct Kubeconfig/context

Review what clusters Rancher knows about
```bash
kubectl get clusters.management.cattle.io 
```

See if there are cluster still in "provisioning" status
```bash
kubectl -n fleet-default get clusters.provisioning.cattle.io
```

```bash
kubectl -n fleet-default delete cluster.provisioning.cattle.io <cluster-name>
```

## Networking 
```
echo "podCIDR: $(kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}') "
echo "Cluster-IP Range: $(kubectl cluster-info dump | grep -m 1 service-cluster-ip-range)"

### Networking: PXE
```
tcpdump -i <interface> -n -vv \ '(port 67 or port 68 or port 69 or port 80) and (host 10.10.12.101 or host 10.10.12.102 or host 10.10.12.111)' \ -w /tmp/pxe-boot.pcap
tail -f /var/log/apache2/access_log
```

## Cert review

```
HOST=observability.kubernerdes.lab
PORT=6443
openssl s_client \
  -servername "$HOST" \
  -showcerts \
  -connect "$HOST:$PORT" \
  < /dev/null 2>/dev/null
```

```
HOST=observability.kubernerdes.lab
PORT='443'; \
openssl s_client \
  -servername "$HOST" \
  -showcerts \
  -connect "$HOST:$PORT" \
  < /dev/null 2>/dev/null \
  | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; print}' \
  | {
    cert_text=""
    while IFS= read -r line; do
      case "$line" in
        *"END CERTIFICATE"*)
          cert_text="$cert_text$line
"
          printf '%s' "$cert_text" \
            | openssl x509 \
              -fingerprint \
              -sha1 \
              -noout
          cert_text=""
          ;;
        *)
          cert_text="$cert_text$line
"
          ;;
      esac
    done
  } \
  | awk -F'=' '{print $2}' \
  | sed 's/://g' \
  | tr '[:upper:]' '[:lower:]'
```

## Cluster Delete

If you manage to find yourself with a "stuck cluster delete"....
```
kubectl get clusters.management.cattle.io # find the cluster you want to delete
export CLUSTERID=“c-xxxxxxxxx” #
kubectl patch clusters.management.cattle.io $CLUSTERID -p ‘{“metadata”:{“finalizers”:}}’ --type=merge
kubectl delete clusters.management.cattle.io $CLUSTERID
```
