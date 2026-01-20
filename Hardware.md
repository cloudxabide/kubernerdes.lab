# Hardware

## Currently Used
| System         | Purpose           | Model            | CPU | CPU model       | Mem | Disk0 | Disk1 |
|:---------------|:------------------|:-----------------|:----|:----------------|:----|:------|:------|
| kubernerd      | Admin Host        | NUC13ANHi7       | 16  | i7-1360P        | 64  | 1024  | 1024  |
|----------------|-------------------|------------------|-----|-----------------|-----|-------|-------|
| nuc-01         | Harvester         | NUC13ANHi7       | 16  | i7-1360P        | 64  | 1024  | 1024  |
| nuc-02         | Harvester         | NUC13ANHi7       | 16  | i7-1360P        | 64  | 1024  | 1024  |
| nuc-03         | Harvester         | NUC13ANHi7       | 16  | i7-1360P        | 64  | 1024  | 1024  |
|----------------|-------------------|------------------|-----|-----------------|-----|-------|-------|
| nuc-04         | Harvester         | NUC10i7FNH       | 12  | i7-10710U       | 64  | 1024  | 2048  |
| nuc-05         | Harvester         | NUC10i7FNH       | 12  | i7-10710U       | 64  | 1024  | 2048  |
| nuc-06         | Harvester         | NUC10i7FNH       | 12  | i7-10710U       | 64  | 1024  | 2048  |
| nuc-07	 | Admin Host        | NUC10i7FNK       | 12  | i7-10710U       | 64  | 1024  | N/A   |
|----------------|-------------------|------------------|-----|-----------------|-----|-------|-------|
| asus-pc-01 	 | Harvester         | Asus Z490        | 20  | i9-10850K       | 128 | 256   | 1024  | 
| asus-pc-02	 | Harvester         | Asus Z490        | 20  | i9-10850K       | 128 | 256   | 1024  | 
| asus-pc-03	 | Harvester         | Asus Z490        | 20  | i9-10850K       | 128 | 256   | 1024  | 
|----------------|-------------------|------------------|-----|-----------------|-----|-------|-------|
| wheatley	 | SLES with SUSE AI | Dell XPS 15 9520 | 14  | i9-12900HK      | 32  | 1024 | 1024 | 
| spark-e        | DGX OS            | NVIDIA DGX Spark | 20  | Arm Cortex      | 128 | 4096 | - |
| blackmesa      | SLES 16           | Lenovo X1 Yoga   | 16  | i5-1250P        | 16  | 1024 | - | 
|----------------|-------------------|------------------|-----|-----------------|-----|-------|-------|
| cisco-sg300-28 | Mng Switch        | SG300-28         | X | X | X | X | X | X | 
| firewall       | Border Firewall   | Sophos XGS88     | ? | ? | ? | ? | ? |

## Unused
| System         | Purpose           | Model            | CPU | CPU model       | Mem | Disk0 (SSD) | Disk1 (NVMe) |
|:---------------|:------------------|:-----------------|:----|:----------------|:----|:------|:------|
| truenas        | NAS               | Asus X99-Pro     | 16  | Xeon E5-2630 v3 | 96  | 256   | 9216  | 


## AI workstation 
I had planned on building my own AI workstation with a 4060Ti 16GB card, but the component market is bonkers right now - so.... I got a NVIDIA DGX instead

## NUC version 1 (NUC10i7FN[HK])
| Cost | Qty | Total | Object       | Purpose                   | Link |
|:----:|:----|:------|:-------------|:--------------------------|:-----|
| 359  | 1   | 359   | Intel NUC    | Admin Host                | [Amazon - Intel NUC NUC10i7FNK1](https://www.amazon.com/gp/product/B083GGZ6TG/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&th=1) |
| 359  | 3   | 1077  | Intel NUC    | Kubernetes Host           | [Amazon - Intel NUC NUC10i7FNH](https://www.amazon.com/NUC10i7FNH-i7-10710U-Processor-Thunderbolt-Ethernet/dp/B0CNBGDXRM)  |
| 148  | 4   | 592   | Memory DIMM  | Host Memory               | [Corsair Vengeance Performance SODIMM Memory 64GB (2x32GB) DDR4 2933MHz CL19 Unbuffered for 8th Generation or Newer Intel Core™ i7, and AMD Ryzen 4000 Series Notebooks](https://www.amazon.com/gp/product/B08GSRD34Y/ref=ppx_od_dt_b_asin_title_s00?ie=UTF8&psc=1) | 
| 94   | 3   | 282    | 2TB SSD SATA | Host Storage (OS)         | [Crucial BX500 2TB 3D NAND](https://www.amazon.com/Crucial-BX500-NAND-2-5-Inch-Internal/dp/B07YD5F561) |
| 90   | 4   | 360   | 1TB SSD NVMe | Host Storage (containers) | [SAMSUNG 970 EVO Plus SSD 1TB NVMe M.2 Internal Solid State Hard Drive, V-NAND Technology, Storage and Memory Expansion for Gaming, Graphics w/ Heat Control, Max Speed, MZ-V7S1T0B/AM](https://www.amazon.com/gp/product/B07MFZY2F2/ref=ppx_od_dt_b_asin_title_s00?ie=UTF8&th=1) |
|======|=======|=======| | | 
|      | Totol | 2670   | | | 

## NUC version 2 (NUC13ANHi7)
| Cost | Qty | Total | Object       | Purpose                   | Link |
|:----:|:----|:------|:-------------|:--------------------------|:-----|
| 589 | 2 | 589 | Intel NUC INNUC13ANHI7 | VMware ESXi Host | https://www.bhphotovideo.com/c/product/1780655-REG/intel_rnuc13anhi7000u_nuc_13_pro_kit.html |
| 139 | 2 | 139 | Crucial Memory (2 x 32GB) | Memory for ESXi Host | https://www.bhphotovideo.com/c/product/1600343-REG/crucial_ct2k32g4sfd832a_2_32gb_ddr4_3200_sodimm_1_2v.html | 
| 75 | 2 | 75 | Crucial 2.5" SSD | OSDATA for ESXi Host | https://www.bhphotovideo.com/c/product/1512570-REG/crucial_ct1000bx500ssd1_1tb_bx500_sata_iii.html |
| 84 | 2 | 84 | 42mm SATA 1TB SSD | Data Store for ESXi Host | https://www.amazon.com/dp/B0BRSMW121?psc=1&smid=A3BTFWKGLBT0VA&ref_=chk_typ_imgToDp |
| 77 | 2 | 77 | 80mm NVMe 1TB SSD | Data Store for ESXi Host | https://www.amazon.com/dp/B09QV692XY?psc=1&smid=A3RXWDYTBSNEDO&ref_=chk_typ_imgToDp |
|======|=======|=======| | | 
|      | Totol | 1928 | | | 

## "SAN" Nodes (TrueNAS)
| Cost | Qty   | Total | Object       | Purpose                   | Link |
|:----:|:------|:------|:-------------|:--------------------------|:-----|
| ???  | 1     | 800 | Asus X99-PRO  - TrueNAS | Provide Storage for VMware and K8s | N/A |
|======|=======|=======| | | 
|      | Totol | 800 | | | 

## Misc Gear
I am not going to put a cost here as I assume that most people exploring this Repo would likely have this gear "just laying around"

| Cost | Qty | Total | Object      | Purpose | Link |
|:----:|:----|:------|:-------|:--------|:-----|
|      | 8   |   | Network Cables (3 ft) | |
|      | 1   |   | Power Strip | |
|      | 1   |   | Keyboard | |
|      | 1   |   | Mouse | |
|      | 1   |   | Monitor | |
|      | 2   |   | 4-port KVM Switch | |
|      | 1   |   | USB Stick (16GB) | Installing SLES 15 | |
|      | 1   |   | USB Stick (16GB) | Installing TrueNAS | |
|      | 1   |   | APC UPS | Battery Backup | | 

Note:  The Intel NUC come in 2 form factors (possibly more).  There is the "slim/sleek" version and the "MiniPC" version? ( NUC10i7FNK1 vs NUC10i7FNH - I believe the "H" is the "Tall" chassis designation)
