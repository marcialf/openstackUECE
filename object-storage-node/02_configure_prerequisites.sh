#!/bin/bash

function assert_superuser {
        [[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && e$
}

function configure_swift
{
	cp "/home/swift/Documentos/openstackUECE/conf/fstab" "/etc/fstab"
	cp "/home/swift/Documentos/openstackUECE/conf/rsyncd.conf" "/etc/rsyncd.conf"
	cp "/home/swift/Documentos/openstackUECE/conf/rsync" "/etc/default/rsync"
}


function main
{
	assert_superuser
	apt-get instal -y install xfsprogs rsync
	mkfs.xfs /dev/sdb1
	mkfs.xfs /dev/sdc1

	mkdir -p /srv/node/sdb1
	mkdir -p /srv/node/sdc1

	mount /srv/node/sdb1
	mount /srv/node/sdc1

	configure_swift
	service rsync start
}
main
