#!/bin/bash

ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"

CINDER_DB_PASSWORD="openstack"
KEYSTONE_USER_CINDER_PASSWORD="openstack"

EMAIL_CINDER="cinder@example.com"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_cinder_database
{
	mysql -u root "-p${MARIADB_PASSWORD}" < "/home/openstack/Documentos/openstackUECE/controller-node/sql/cinder.sql"
}

function register_in_keystone
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"

	keystone user-create --name cinder --pass $KEYSTONE_USER_CINDER_PASSWORD --email $EMAIL_CINDER

	keystone user-role-add --user cinder --tenant service --role admin

	keystone service-create --name cinder --type volume --description "OpenStack Block Storage"

	keystone service-create --name cinderv2 --type volumev2 --description "OpenStack Block Storage"

	keystone endpoint-create \
	  --service-id $(keystone service-list | awk '/ volume / {print $2}') \
	  --publicurl http://controller:8776/v1/%\(tenant_id\)s \
	  --internalurl http://controller:8776/v1/%\(tenant_id\)s \
	  --adminurl http://controller:8776/v1/%\(tenant_id\)s \
	  --region regionOne

	keystone endpoint-create \
          --service-id $(keystone service-list | awk '/ volumev2 / {print $2}') \
          --publicurl http://controller:8776/v2/%\(tenant_id\)s \
          --internalurl http://controller:8776/v2/%\(tenant_id\)s \
          --adminurl http://controller:8776/v2/%\(tenant_id\)s \
          --region regionOne
}

function install_cinder_packages
{
	apt-get install -y cinder-api cinder-scheduler python-cinderclient
}

function configure_cinder
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/conf/cinder.conf" "/etc/cinder/cinder.conf"
}

function connect_database
{
	su -s /bin/sh -c "cinder-manage db sync" cinder
}

function restart_services
{
	service cinder-scheduler restart
	service cinder-api restart
	remove_if_exists "/var/lib/glance/cinder.sqlite"
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}


function main
{
	assert_superuser
#	create_cinder_database
#	register_in_keystone
#	install_cinder_packages
	configure_cinder
	connect_database
	restart_services
}

main
