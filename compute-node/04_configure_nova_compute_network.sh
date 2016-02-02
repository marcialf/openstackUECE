#!/bin/bash

function install_nova_network_packages
{
	apt-get install -y nova-network nova-api-metadata
}

function configure_nova_network
{
	cp "/home/stack/Documentos/openstackUECE/compute-node/conf2/nova.conf" "/etc/nova/nova.conf"
}

function restart_services
{
	service nova-network restart
	service nova-api-metadata restart
}

function main
{
	install_nova_network_packages
	configure_nova_network
	restart_services
}

main
