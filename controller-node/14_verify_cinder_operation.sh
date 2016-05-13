#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function verify_admin_operation
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	cinder service-list
}

function verify_demo_operation
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	cinder create --display-name demo-volume1 1
}

function main
{
	assert_superuser
	verify_admin_operation
	cinder list
}


main
