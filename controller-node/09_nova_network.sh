#!/bin/bash

function configure_nova_network
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/conf2/nova.conf" "/etc/nova/nova.conf"
}

function restart_services
{
	service nova-api restart
	service nova-scheduler restart
	service nova-conductor restart
}

function main
{
	configure_nova_network
	restart_services
}

main
