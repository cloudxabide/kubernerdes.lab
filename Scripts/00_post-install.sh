#!/bin/bash

# For my nodes that are built using DHCP, I need to statically configure the network


## THIS SHOULD BE PART OF THE INSTALLATION USING "userdata" NOW
exit 0

# SUDO SU to root  (This assumes all nodes will be SLES
sudo su -

# Task: configure static IP address
case $(uname -n) in
  harvester-dc-lb) IPADDR='10.10.12.92/22' ;;
  harvester-edge-lb) IPADDR='10.10.12.92/22' ;;
  rancher-01) IPADDR='10.10.12.211/22' ;;
  rancher-02) IPADDR='10.10.12.212/22' ;;
  rancher-03) IPADDR='10.10.12.213/22' ;;
  observability-01) IPADDR='10.10.12.221/22' ;;
  observability-02) IPADDR='10.10.12.222/22' ;;
  observability-03) IPADDR='10.10.12.223/22' ;;
esac
echo "Note: using $IPADDR"

cp /etc/sysconfig/network/ifcfg-eth0 /etc/sysconfig/network/ifcfg-eth0.orig
cat << EOF >> /etc/sysconfig/network/ifcfg-eth0
IPADDR=$IPADDR
GATEWAY=10.10.12.1
EOF
sed -i -e 's/dhcp4/static/g' /etc/sysconfig/network/ifcfg-eth0
sdiff /etc/sysconfig/network/ifcfg-eth0 /etc/sysconfig/network/ifcfg-eth0.orig | egrep '<|\|'
echo "default 10.10.12.1 - eth0" > /etc/sysconfig/network/ifroute-eth0

# Task: configure DNS and NTP settings
update_dns_and_ntp() {
cp /etc/sysconfig/network/config /etc/sysconfig/network/config.orig
sed -i -e 's/NETCONFIG_DNS_STATIC_SEARCHLIST=""/NETCONFIG_DNS_STATIC_SEARCHLIST="kubernerdes.lab"/g' /etc/sysconfig/network/config
sed -i -e 's/NETCONFIG_DNS_STATIC_SERVERS=""/NETCONFIG_DNS_STATIC_SERVERS="10.10.12.8 10.10.12.9 8.8.8.8"/g' /etc/sysconfig/network/config
sed -i -e 's/NETCONFIG_NTP_STATIC_SERVERS=""/NETCONFIG_NTP_STATIC_SERVERS="0.pool.suse.ntp.org 1.pool.suse.ntp.org 2.pool.suse.ntp.org"/g' /etc/sysconfig/network/config
sdiff /etc/sysconfig/network/config.orig /etc/sysconfig/network/config | egrep '<|\|'
}

# disable IPv6 (doesn't work in my setup)
cat << EOF | tee /etc/sysctl.d/10-disable_ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

# Disable firewalld (revisit this)
systemctl disable firewalld --now

shutdown now -r

