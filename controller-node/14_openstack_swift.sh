#!/bin/bash

ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"

SWIFT_DB_PASSWORD="openstack"
KEYSTONE_USER_SWIFT_PASSWORD="openstack"
EMAIL_SWIFT="swift@example.com"

function register_in_keystone
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	openstack user create --password-prompt swift $KEYSTONE_USER_SWIFT_PASSWORD$
	openstack role add --project service --user swift admin
	openstack service create --name swift --description "OpenStack Object Storage" object-store
	openstack endpoint create --publicurl 'http://controller:8080/v1/AUTH_%(tenant_id)s' \
		--internalurl 'http://controller:8080/v1/AUTH_%(tenant_id)s' \
		--adminurl http://controller:8080 \
		--region RegionOne \
		object-store
}

function install_packages
{
	apt-get install swift swift-proxy python-swiftclient python-keystoneclient \
		python-keystonemiddleware memcached
}

function configure_swift
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/conf/proxy-server.conf" "/etc/swift/proxy-server.conf"
}

function main
{
	register_in_keystone
	install_packages
	mkdir /etc/swift
	curl -o /etc/swift/proxy-server.conf \
		https://git.openstack.org/cgit/openstack/swift/plain/etc/proxy-server.conf-sample?h=stable/kilo
	configure_swift
	

}
main

