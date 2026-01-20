# Resource Requirements

Breakdown of Resources for my lab (available vs required)


| Virtualization Cluster | K8s Cluster        | Node Count | vCPU      | Memory | HDD0 | HDD1 | vCPU | Memory |
|:----------------------:|:------------------:|-----------:|----------:|-------:|-----:|-----:|-----:|-------:|
| harvester-dc           | rancher            | 3 | 2 | 8 | 50 | | 6 | 24 |
| harvester-dc           | observability      | 3 | 4|16|300||12|48 |
| harvester-dc           | rke2-harv-dc-01    | 3 | 2|16|100||6|48 |
| harvester-dc           | rke2-harv-dc-01-lb | 1  | 1|2|50 | | 1 | 2  |
| harvester-dc           | (total)            | 10 | | | | | 25 | 122 |

| Virtualization Cluster | Purpos e   | Node Count | CPU Cores | Memory | CPU total | Memory total |
|:----------------------:|:----------:|-----------:|----------:|-------:|----------:|-------------:|
| harvester-dc           | Hypervisor | 2          | 20        | 128    | 40        | 256 |
| harvester-edge         | Hypervisor | 3          | 12        | 64     | 36        | 192 |
| (total)                | --         | 5          |           |        | 76        | 448 |
