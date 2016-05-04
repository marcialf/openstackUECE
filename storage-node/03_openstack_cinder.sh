#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function install_packages_manage_volume
{
	apt-get install -y qemu
	apt-get install -y lvm2
}

function manage_volume
{
	pvcreate /dev/sdb1
	vgcreate cinder-volumes /dev/sdb1
}

function install_cinder_packages
{
	apt-get install -y cinder-volume python-mysqldb
}

function configure_cinder
{
	cp "/home/cinder/Documentos/openstackUECE/storage-node/conf/cinder.conf" "/etc/cinder/cinder.conf"
}

function restart_services
{
	service tgt restart
	service cinder-volume restart
	remove_if_exists "/var/lib/glance/cinder.sqlite"
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}

function main
{
	assert_superuser
	install_packages_manage_volume
	manage_volume


#Falta a parte apos o manage_volumes que ta no tuto do openstack

	install_cinder_packages
	configure_cinder
	restart_services
}

main
