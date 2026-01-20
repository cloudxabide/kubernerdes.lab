cd Developer/Projects/
git clone https://github.com/cloudxabide/HexGL.git
cd HexGL

APPARCH=x86_64

kubectl create namespace hexgl
kubectl config set-context --current --namespace=hexgl
kubectl create -f Deployments/hexgl-deployment-${APPARCH}.yaml

kubectl expose deployment.apps/hexgl-deployment --type="ClusterIP" --port 8080

cat << EOF | tee ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hexgl-ingress
spec:
  rules:
  - host: hexgl.apps.rke2-harv.kubernerdes.lab
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hexgl-deployment
            port:
              number: 8080
EOF
kubectl apply -f ingress.yaml
