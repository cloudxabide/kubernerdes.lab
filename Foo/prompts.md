# Prompts 

## Build an HAProxy Load Balancer
I have a single Load Balancer (haproxy and keepalived running on SLES 15sp7).  I would like the following: a single endpoint (a VIP on SLES node managed by keepalived) which will redirect ports 80,443,6443,8443 to 3 nodes. I would like you to create the haproxy.cfg and keepalived.conf I will provide the cluster name, VIP, 3 node IPs in a table

| harvester-dc | 10.10.12.110 | 10.10.12.111, 10.10.12.112, 10.10.12.113 |
| rancher | 10.10.12.210 | 10.10.12.211, 10.10.12.212, 10.10.12.213 |
| observability | 10.10.12.220 | 10.10.12.221, 10.10.12.222, 10.10.12.223 |
| rke2-harv-dc-01 | 10.10.12.230 | 10.10.12.231, 10.10.12.232, 10.10.12.233 |
