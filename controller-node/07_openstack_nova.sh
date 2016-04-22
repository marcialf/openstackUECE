#!/bin/bash

ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"

NOVA_DB_PASSWORD="openstack"
KEYSTONE_USER_NOVA_PASSWORD="openstack"
EMAIL_NOVA="nova@example.com"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_nova_database
{
	mysql -u root "-p${MARIADB_PASSWORD}" < "/home/openstack/Documentos/openstackUECE/controller-node/sql/nova.sql"
}

function register_in_keystone
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"

	keystone user-create --name nova --pass $KEYSTONE_USER_NOVA_PASSWORD --email $EMAIL_NOVA
	
	keystone user-role-add --user nova --tenant service --role admin
	
	keystone service-create --name nova --type compute --description "OpenStack Compute"
	
	keystone endpoint-create \
	  --service-id $(keystone service-list | awk '/ compute / {print $2}') \
	  --publicurl http://controller:8774/v2/%\(tenant_id\)s \
	  --internalurl http://controller:8774/v2/%\(tenant_id\)s \
	  --adminurl http://controller:8774/v2/%\(tenant_id\)s \
	  --region regionOne
}

function install_nova_packages
{
	apt-get install -y nova-api nova-cert nova-conductor nova-consoleauth nova-scheduler python-novaclient

	apt-get install -y novnc


#	dpkg -i "/home/openstack/Documentos/openstackUECE/nova-novncproxy_2015.1.2-0ubuntu2~cloud0_all.deb"
	dpkg -i "/home/openstack/Documentos/openstackUECE/nova-novncproxy_2015.1.3-0ubuntu1_all.deb"

}

function configure_nova
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/conf/nova.conf" "/etc/nova/nova.conf"
}

function connect_database
{
	su -s /bin/sh -c "nova-manage db sync" nova
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}

function restart_services
{
	service nova-api restart
	service	nova-cert restart
	service nova-consoleauth restart
	service nova-scheduler restart
	service nova-conductor restart
	service nova-novncproxy restart
	remove_if_exists "/var/lib/glance/nova.sqlite"
}



function main
{
	assert_superuser
	create_nova_database
	register_in_keystone
	install_nova_packages
	configure_nova
	connect_database
	restart_services
}

main
