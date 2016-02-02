#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function verify_operation
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	nova service-list
	nova endpoints
	nova image-list
}
