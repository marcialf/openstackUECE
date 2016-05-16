#!/bin/bash

function assert_superuser {
        [[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && e$
}

function install_packages
{
	apt-get install -y swift swift-account swift-container swift-object
	curl -o /etc/swift/account-server.conf \
		https://git.openstack.org/cgit/openstack/swift/plain/etc/account-server.conf-sample?h=stable/kilo
	curl -o /etc/swift/container-server.conf \
		https://git.openstack.org/cgit/openstack/swift/plain/etc/container-server.conf-sample?h=stable/kilo
	curl -o /etc/swift/object-server.conf \
		https://git.openstack.org/cgit/openstack/swift/plain/etc/object-server.conf-sample?h=stable/kilo
	curl -o /etc/swift/container-reconciler.conf \
		https://git.openstack.org/cgit/openstack/swift/plain/etc/container-reconciler.conf-sample?h=stable/kilo
	curl -o /etc/swift/object-expirer.conf \
		https://git.openstack.org/cgit/openstack/swift/plain/etc/object-expirer.conf-sample?h=stable/kilo

}

function configure_swift
{
	cp "/home/swift2/Documentos/openstackUECE/object-storage-node/node-2/conf/account-server.conf" \
		"/etc/swift/account-server.conf"
	cp "/home/swift2/Documentos/openstackUECE/object-storage-node/node-2/conf/container-server.conf" \
		"/etc/swift/containar-server.conf"
	cp "/home/swift2/Documentos/openstackUECE/object-storage-node/node-2/conf/object-server.conf" \
		"/etc/swift/object-server.conf"
}

function main
{
	assert_superuser
	install_packages
	configure_swift
	chown -R swift:swift /srv/node
	mkdir -p /var/cache/swift
	chown -R swift:swift /var/cache/swift

}
main
