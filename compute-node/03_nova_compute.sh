#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}


function install_nova_packages {
	apt-get install nova-compute sysfsutils
	apt-get upgrade nova-compute sysfsutils
}

function configure_nova_packages
{
	cp "/home/stack/Documentos/openstackUECE/compute-node/nova.conf" "/etc/nova/nova.conf"
}

function restart_services
{
	service nova-compute restart
	remove_if_exists "/var/lib/glance/nova.sqlite"
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}

function main
{
	assert_superuser
	install_nova_packages
	configure_nova_packages
	restart_services
}

main
