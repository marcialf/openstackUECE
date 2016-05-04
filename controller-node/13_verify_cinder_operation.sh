#!/bin/sh

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function verify_operation_admin
{
        source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	cinder service-list
}

function verify_operation_demo
{
        source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/demo-openrc.sh"
	cinder create --name demo-volume1 1
}

function main
{
	assert_superuser
	echo "export OS_VOLUME_API_VERSION=2" | tee -a admin-openrc.sh demo-openrc.sh
	#verify_operation_admin
#	verify_operation_demo
}

main
