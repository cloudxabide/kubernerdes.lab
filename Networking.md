# Networking

Since I will have multiple disparate environments that may communicate between each of them, I need to keep track of the CIDR(s) each environment will be using.


## CIDR Definition

| CIDR              | Item    | Account | Purpose |
|:------------------|:--------|:-----------|:-----|
| 172.16.0.0/12     | AWS (SuperNet) | N/A        | This is the overall CIDR which my others will be carved out of |
| 172.16.0.0/16     | VpcCidr | networking | Owns Transit Gateway |
| 172.17.0.0/16     | VpcCidr | kubernetes | Run EKS (eksdemo), host EKS-Hybrid |
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

## Definitions

The following table provides some generic definition of some of the parameters referenced on this page.  One challenge is that different products may refer to things slightly differently, or have definitions specific to their own stack (i.e. Red Hat has a parameter "prefix" that you have to declare)

| Item | Definition |
|:-----|:-----------|
| machineCidr/machineNetworkCidr |  Network for Nodes primary (public) interfaces  
| PodCidr |   Network subnet for Pods to be deployed - shared on each node  
| ServiceCidr |   Service IPs are used to expose one to several pods.  I.e. you make a request to the serviceIp rather than each individual pod providing the service.
| prefix | This is the CIDR carved out of the PodCidr for each node in your cluster, which is assigned to each node.  (i.e. For my EKS Anywhere cluster, each node will get a /24 of the 192.168.0.0/16 - starting with 192.168.0.0/2)
