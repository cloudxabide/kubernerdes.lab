#!/bin/bash

sudo su -

# This script assumes you have already registered your node (using post_install.sh)
reg_node() {

SUSEConnect -e <reg_email> -r <reg_code>
SUSEConnect --product sle-module-basesystem/15.7/x86_64
SUSEConnect --product sle-module-server-applications/15.7/x86_64
# TODO - add a check to see whether HA is enabled and if not, enable it
#SUSEConnect --product sle-ha/15.7/x86_64 -r (add reg code for HA Extension)
}

# using Keepalived for floating/VIP (and to future proof)
zypper -n in haproxy keepalived

# Allow keepalive to attach before interface is up/available
echo "net.ipv4.ip_nonlocal_bind = 1" | sudo tee -a /etc/sysctl.d/20_keepalive.conf
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.orig
curl -o  /etc/keepalived/keepalived.conf https://raw.githubusercontent.com/jradtke-suse/kubernerdes.lab/refs/heads/main/Files/etc_keepalived_keepalived-$(uname -n).conf 
sdiff /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.orig
sudo systemctl enable keepalived --now
sleep 15; ip a s

cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.$(uuidgen | tr -d '-' | head -c 6)
curl -o /etc/haproxy/haproxy.cfg https://raw.githubusercontent.com/jradtke-suse/kubernerdes.lab/refs/heads/main/Files/etc_haproxy_haproxy-$(uname -n).cfg
sudo systemctl enable haproxy --now

