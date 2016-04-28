#!/bin/bash

function install_packages
{
	apt-get install -y neutron-plugin-ml2 neutron-plugin-openvswitch-agent
}

function configure_neutron
{
	cp "/home/stack/Documentos/openstackUECE/compute-node/conf2/neutron.conf" "/etc/neutron/neutron.conf"
	cp "/home/stack/Documentos/openstackUECE/compute-node/nova.conf" "/etc/nova/nova.conf"
}

function configure modular_layer
{
	cp "/home/stack/Documentos/openstackUECE/compute-node/conf2/ml2_conf.ini" "/etc/neutron/plugins/ml2/ml2_conf.ini"
}

function verify_operation 
{
	source "admin-demo/admin-openrc.sh"
	neutron agent-list
}

function main
{
	install packages
	sysctl -p
	configure_neutron
	configure modular_layer
	service openvswitch-switch restart
	service nova-compute restart
	service neutron-plugin-openvswitch-agent restart
	verify_operation
}
main
