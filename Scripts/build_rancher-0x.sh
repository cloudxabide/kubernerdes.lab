# This "script" was not intended to be run as a script, and instead cut-and-paste the pieces (hence no #!/bin/sh at the top ;-_

# Reference: https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/k3s-for-rancher

# Create 2 x VM with (4 vCPU, 16GB, 50GB HDD)
# Install SLE 15 text mode
# Enable Base + Containers Modules
# Add mansible user
# open SSH port

# ssh-key for rancher should exist (if you deployed VM on Harvester)

# SU to root
sudo su -

# Remove any existing host entry
sudo sed -i -e '/rancher/d' /etc/hosts
# Add all the Rancher Nodes to /etc/hosts
cat << EOF | tee -a  /etc/hosts

# Rancher Nodes
10.10.12.211    rancher-01.homelab.kubernerdes.com rancher-01
10.10.12.212    rancher-02.homelab.kubernerdes.com rancher-02
10.10.12.213    rancher-03.homelab.kubernerdes.com rancher-03
EOF

# Set some variables
export MY_K3S_VERSION=v1.32.6+k3s1
export MY_K3S_INSTALL_CHANNEL=v1.32
export MY_K3S_TOKEN=Waggoner
export MY_K3S_ENDPOINT=10.10.12.210
export MY_K3S_HOSTNAME=rancher.homelab.kubernerdes.com

# Make sure the proxy allows port 6443
# TODO write a test for this?

# Run the install process
case $(uname -n) in
  rancher-01)
    echo "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${MY_K3S_INSTALL_CHANNEL} sh -s - server --cluster-init --token ${MY_K3S_TOKEN} --tls-san ${MY_K3S_ENDPOINT},${MY_K3S_HOSTNAME}"
    curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${MY_K3S_INSTALL_CHANNEL} sh -s - server --cluster-init --token ${MY_K3S_TOKEN} --tls-san ${MY_K3S_ENDPOINT},${MY_K3S_HOSTNAME}
  ;;
  *)
    sleep 120 # allow time for the first node to complete install
    echo "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${MY_K3S_INSTALL_CHANNEL} sh -s - --server https://${MY_K3S_ENDPOINT}:6443 --token ${MY_K3S_TOKEN}"
    curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${MY_K3S_INSTALL_CHANNEL} sh -s - --server https://${MY_K3S_ENDPOINT}:6443 --token ${MY_K3S_TOKEN}
  ;;
esac

# Make a copy of the KUBECONFIG for non-root use
# TODO:  I need to 1/ decide if this script should run as root (probably: yes), figure out what user to store the kubeconfig with (probably: sles)
mkdir ~/.kube; sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config; sudo chown $(whoami) ~/.kube/config
mkdir ~sles/.kube; sudo cp /etc/rancher/k3s/k3s.yaml ~sles/.kube/config; sudo chown -R sles ~sles/.kube/config
export KUBECONFIG=~/.kube/config
openssl s_client -connect 127.0.0.1:6443 -showcerts </dev/null | openssl x509 -noout -text > cert.0
grep DNS cert.0

# Replace localhost IP with the HAproxy endpoint
sed -i -e "s/127.0.0.1/${MY_K3S_ENDPOINT}/g" $KUBECONFIG
openssl s_client -connect 127.0.0.1:6443 -showcerts </dev/null | openssl x509 -noout -text > cert.1

. /etc/*release*
case $VARIANT in 
  Micro)
    echo "Shutting down to ensure transactional update is committed"
    shutdown now -r
  ;;
esac

## RANCHER FOooo
# Run this from kubernerd
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

kubectl create namespace cattle-system

CERTMGR_VERSION=v1.18.0
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERTMGR_VERSION}/cert-manager.crds.yaml

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.homelab.kubernerdes.com \
  --set replicas=1 \
  --set bootstrapPassword=mypasswordis3l33t

echo https://rancher.homelab.kubernerdes.com/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')
BOOTSTRAP_PASSWORD=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}')

exit 
## Troubleshooting
kubectl -n cattle-system get pods -l app=rancher -o wide
kubectl -n cattle-system logs -l app=cattle-agent
kubectl -n cattle-system logs -l app=cattle-cluster-agentA
kubectl -n cattle-system get deployment
kubectl -n cattle-system rollout status deploy/rancher
kubectl -n cattle-system rollout status deploy/rancher-webhook

See "systemctl status k3s.service" and "journalctl -xeu k3s.service" for details.
openssl s_client -connect 127.0.0.1:6443 -showcerts </dev/null | openssl x509 -noout -text > cert.0
openssl s_client -connect 10.10.12.121:6443 -showcerts </dev/null | openssl x509 -noout -text > cert.1
openssl s_client -connect 10.10.12.120:6443 -showcerts </dev/null | openssl x509 -noout -text > cert.2

# service ClusterIP CIDR
echo '{"apiVersion":"v1","kind":"Service","metadata":{"name":"tst"},"spec":{"clusterIP":"1.1.1.1","ports":[{"port":443}]}}' | kubectl apply -f - 2>&1 | sed 's/.*valid IPs is //'
# Pod CIDR
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'

##
kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide
kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh

kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl exec -i -t dnsutils -- nslookup kubernetes.default
