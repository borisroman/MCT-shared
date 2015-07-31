#!/bin/bash

# Disable apparmor
ln -s /etc/apparmor.d/usr.sbin.libvirtd /etc/apparmor.d/disable/
ln -s /etc/apparmor.d/usr.lib.libvirt.virt-aa-helper /etc/apparmor.d/disable/
apparmor_parser -R /etc/apparmor.d/usr.sbin.libvirtd
apparmor_parser -R /etc/apparmor.d/usr.lib.libvirt.virt-aa-helper

# Install dependencies for KVM on Cloudstack
echo deb http://cloudstack.apt-get.eu/ubuntu trusty 4.5 > /etc/apt/sources.list.d/cloudstack.list
wget -O - http://cloudstack.apt-get.eu/release.asc|apt-key add -
apt-get update
pt-get install cloudstack-agent -y


# Cloudstack agent.properties settings
cp -pr /etc/cloudstack/agent/agent.properties /etc/cloudstack/agent/agent.properties.orig
echo "guest.cpu.mode=host-model" >> /etc/cloudstack/agent/agent.properties

# Set the logging to DEBUG
sed -i 's/INFO/DEBUG/g' /etc/cloudstack/agent/log4j-cloud.xml

# Libvirtd parameters for Cloudstack
echo 'listen_tls = 0' >> /etc/libvirt/libvirtd.conf
echo 'listen_tcp = 1' >> /etc/libvirt/libvirtd.conf
echo 'tcp_port = "16509"' >> /etc/libvirt/libvirtd.conf
echo 'mdns_adv = 0' >> /etc/libvirt/libvirtd.conf
echo 'auth_tcp = "none"' >> /etc/libvirt/libvirtd.conf

sed -i 's/-d/-d -l/g' /etc/default/libvirt-bin

# Restart the libvirt service.
service libvirt-bin restart

# Network
# Device
echo "# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto cloudbr0
iface cloudbr0 inet dhcp
	bridge_ports eth0
	bridge_fd 5
	bridge_stp off
	bridge_maxwait 1
	dns-nameservers 93.180.70.22 93.180.70.30

auto cloudbr1
iface cloudbr1 inet dhcp
	bridge_ports eth1
	bridge_fd 5
	bridge_maxwait 1
	bridge_stp off
	dns-nameservers 93.180.70.22 93.180.70.30
" > /etc/network/interfaces


# Reboot
reboot
