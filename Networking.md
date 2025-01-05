# Networking

## CIDR Definition

| CIDR              | Item    | Account | Purpose |
|:------------------|:--------|:-----------|:-----|
| 172.16.0.0/12     | AWS     | N/A        |
| 172.16.0.0/12     | VpcCidr | networking | Owns Transit Gateway |
| 172.17.0.0/16     | VpcCidr | kubernetes | Run EKS, manage EKS-Hybrid |
| 172.18.0.0/16     | VpcCidr | openshift  | |
| 172.19.0.0/16     | VpcCidr | rancher    | |
| 10.10.12.0/22     | Cidr    | N/A        | on-premesis network |

## Kubernetes CIDR

| ClusterName        | machineNetworkCidr | PodCidr/clusterNetwork | prefix | ServiceNetwork | 
|:-------------------|:-------------------|:-----------------------|:-------|:---------------|
| kubernerdes-eksa   | 10.10.12.0/22      | 192.168.0.0/16         | /24    | 10.96.0.0/12   |
| eksdemo            | 172.17.0.0/16      | 192.168.0.0/16         | N/A    | 10.96.0.0/12   |
| openshift          | 172.18.0.0/16      | 10.128.0.0/14          | /23    | 172.30.0.0/16  |
| rancher            | 172.18.0.0/16      | 10.128.0.0/14          | /23    | 172.30.0.0/16  |

machineCidr: Network for Nodes primary (public) interfaces
PodCidr:  Network subnet 
ServiceCidr:  Network for Service IPs
