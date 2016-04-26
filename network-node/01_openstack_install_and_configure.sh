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

function configure_neutron
{
	cp "/home/Documentos/openstackUECE/network-node/conf/neutron.conf" "/etc/neutron/neutron.conf"
	cp "/home/Documentos/openstackUECE/network-node/conf/ml2_conf.ini" "/etc/neutron/plugins/ml2/ml2_conf.ini"
	cp "/home/Documentos/openstackUECE/network-node/conf/13_agent.ini" "/etc/neutron/13_agent.ini"
	cp "/home/Documentos/openstackUECE/network-node/conf/dhcp_agent.ini" "/etc/neutron/dhcp_agent.ini"
	cp "/home/Documentos/openstackUECE/network-node/conf/dnsmasq-neutron.conf" "/etc/neutron/dnsmasq-neutron.conf"
	pkill dnsmasq
	cp "/home/Documentos/openstackUECE/network-node/conf/metadata_agent.ini" "/etc/neutron/metadata_agent.ini"
	
}

function verify_operation
{
	source "/home/Documentos/openstackUECE/network-node/admin-demo/admin-openrc.sh"
	neutron agent-list
}

function main
{
	configure_prerequisites
	install_packages	
	configure_neutron
	service openvswitch-switch restart
	ovs-vsctl add-br br-ex
	ovs-vsctl add-port br-ex eth0
	service neutron-plugin-openvswitch-agent restart
	service neutron-13-agent restart
	service neutron-dhcp-agent restart
	service neutron-metadata-agent restart
	verify_operation
}
main
