#!/bin/bash

function assert_superuser {
        [[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && e$
}

function configure_swift
{
        cp "/home/swift2/Documentos/openstackUECE/object-storage-node/conf/fstab" "/etc/fstab"
	cp "/home/swift2/Documentos/openstackUECE/object-storage-node/conf/rsyncd2.conf" "/etc/rsyncd.conf"
        cp "/home/swift2/Documentos/openstackUECE/object-storage-node/conf/rsync" "/etc/default/rsync"
}


function main
{
        assert_superuser
#        apt-get install -y xfsprogs rsync
#        mkfs.xfs /dev/sdb1
#        mkfs.xfs /dev/sdc1

        mkdir -p /srv/node/sdb1
        mkdir -p /srv/node/sdc1

        mount /srv/node/sdb1
        mount /srv/node/sdc1

        configure_swift
        service rsync start
}
main

