#!/bin/bash

ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"

SWIFT_DB_PASSWORD="openstack"
KEYSTONE_USER_SWIFT_PASSWORD="openstack"
EMAIL_SWIFT="swift@example.com"


function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function register_in_keystone
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	keystone user-create --name swift --pass $KEYSTONE_USER_SWIFT_PASSWORD$
	keystone user-role-add --user swift --tenant service --role admin
	keystone service-create --name swift --type object-store --description "OpenStack Object Storage"
	keystone endpoint-create \
	  --service-id $(keystone service-list | awk '/ object-store / {print $2}') \
	  --publicurl 'http://controller:8080/v1/AUTH_%(tenant_id)s' \
	  --internalurl 'http://controller:8080/v1/AUTH_%(tenant_id)s' \
	  --adminurl http://controller:8080 \
	  --region regionOne
}

function install_packages
{
	apt-get install swift python-swiftclient python-keystoneclient \
		python-keystonemiddleware memcached
	dpkg dpkg -i "/home/openstack/Documentos/openstackUECE/swift-proxy_2.2.2-0ubuntu1.3~cloud0_all.deb"
}

function configure_swift
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/conf/proxy-server.conf" "/etc/swift/proxy-server.conf"
}

function main
{
	assert_superuser
#	register_in_keystone
	install_packages
	mkdir /etc/swift
	curl -o /etc/swift/proxy-server.conf \
		https://git.openstack.org/cgit/openstack/swift/plain/etc/proxy-server.conf-sample?h=stable/kilo
	configure_swift


}
main

