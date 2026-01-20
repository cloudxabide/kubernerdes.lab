I can use 802.3ad (LACP) - remember to check the LACP enabled box when creating the LAG

# ***************************
NIC closest to CPU
GE7  asus-pc01-pci1-0 - port away from mobo
GE8  asus-pc01-pci2-0 - port away from mobo

NIC closest to power supply
GE9  asus-pc01-pci1-1 - port closest to mobo
GE10 asus-pc01-pci2-1 - port closest to mobo

LAG1 asus-pc-01-0 (GE7/9)
LAG2 asus-pc-01-1 (GE8/10)

# ***************************
NIC closest to CPU
GE12  asus-pc-02-pci1-0 - port away from mobo
GE13  asus-pc-02-pci2-0 - port away from mobo

NIC closest to power supply
GE14  asus-pc-02-pci1-1 - port closest to mobo
GE15  asus-pc-02-pci2-1 - port closest to mobo

LAGt asus-pc-02-0 (GE12/13)
LAG4 asus-pc-02-1 (GE14/15)

# ***************************
NIC closest to CPU
GE7  asus-pc-01-pci1-0 - port away from mobo
GE9  asus-pc-01-pci1-1 - port closest to mobo

NIC closest to power supply
GE8  asus-pc-01-pci2-0 - port away from mobo
GE10 asus-pc-01-pci2-1 - port closest to mobo

LAG1 asus-pc-01-0 (GE7/9)
LAG2 asus-pc-01-1 (GE8/10)
