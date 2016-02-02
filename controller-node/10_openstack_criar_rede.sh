#!/bin/bash

function create_initial_network
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	
	nova network-create demo-net --bridge br100 --multi-host T --fixed-range-v4 203.0.113.24/29
}

function verify_operation
{
	nova net-list
}

function main
{
	create_initial_network
	verify_operation
}

main
