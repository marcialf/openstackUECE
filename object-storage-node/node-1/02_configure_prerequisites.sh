#!/bin/bash

function assert_superuser {
        [[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && e$
}

function configure_swift
{
	cp "/home/swift/Documentos/openstackUECE/object-storage-node/conf/fstab" "/etc/fstab"
	cp "/home/swift/Documentos/openstackUECE/object-storage-node/conf/rsyncd.conf" "/etc/rsyncd.conf"
	cp "/home/swift/Documentos/openstackUECE/object-storage-node/conf/rsync" "/etc/default/rsync"
}

function install_swift_packages
{
	apt-get install -y xfsprogs rsync

}

function main
{
	assert_superuser
	install_swift_packages
	mkfs.xfs -f /dev/sdb1
	mkfs.xfs -f /dev/sdc1

	mkdir -p /srv/node/sdb1
	mkdir -p /srv/node/sdc1

	mount /srv/node/sdb1
	mount /srv/node/sdc1

	configure_swift
	service rsync start
}
main
