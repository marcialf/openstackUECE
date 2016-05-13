#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function edit_network
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/interfaces" "/etc/network/interfaces"
	cp "/home/stack/Documentos/openstackUECE/compute-node/interfaces" "/etc/network/interfaces"
	cp "/home/cinder/Documentos/openstackUECE/storage-node/interfaces" "/etc/network/interfaces"
	cp "/home/swift/Documentos/openstackUECE/object-storage-node/node-1/interfaces" "/etc/network/interfaces"


}

function copy_hosts
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/hosts" "/etc/hosts"
	cp "/home/stack/Documentos/openstackUECE/compute-node/hosts" "/etc/hosts"
	cp "/home/cinder/Documentos/openstackUECE/storage-node/hosts" "/etc/hosts"
	cp "/home/swift/Documentos/openstackUECE/object-storage-node/node-1/hosts" "/etc/hosts"

}

function main
{
	assert_superuser
	apt-get -y upgrade && apt-get -y dist-upgrade
	edit_network
	copy_hosts	
#	nano /etc/network/interfaces
	ufw disable
}

main
