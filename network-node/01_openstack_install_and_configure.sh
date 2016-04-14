#!/bin/bash

function configure_prerequisites
{
	cp "/home/Documentos/openstackUECE/network-node/conf/sysctl.conf" "/etc/sysctl.conf"
	sysctl -p
}

function install_packages
{
	apt-get install -y neutron-plugin-ml2 neutron-plugin-openvswitch-agent \
neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent

}

function main
{
	configure_prerequisites
	install_packages	

}
main
