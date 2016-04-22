#!/bin/bash

ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"

NOVA_DB_PASSWORD="openstack"
KEYSTONE_USER_NEUTRON_PASSWORD="openstack"
EMAIL_NEUTRON="neutron@example.com"


function assert_superuser
{
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_neutron_database 
{	
	mysql -u root "-p${MARIADB_PASSWORD}" < "/home/openstack/Documentos/openstackUECE/controller-node/sql/neutron.sql"
}

function register_in_keystone
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	
	keystone user-create --name neutron --pass $KEYSTONE_USER_NEUTRON_PASSWORD --email $EMAIL_NEUTRON

	keystone user-role-add --user neutron --tenant service --role admin

	keystone service-create --name neutron --type network --description "OpenStack Network Service"

	keystone endpoint-create \
	  --service-id $(keystone service-list | awk '/ image / {print $2}') \
	  --publicurl http://controller:9696 \
	  --internalurl http://controller:9696 \
	  --adminurl http://controller:9696 \
	  --region regionOne
}

function install_network_components
{
	apt-get install -y neutron-server neutron-plugin-ml2 python-neutronclient

}

function configure_neutron
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/neutron/conf/neutron.conf" "/etc/neutron/neutron.conf"
	cp "/home/openstack/Documentos/openstackUECE/controller-node/neutron/conf/nova.conf" "/etc/nova/nova.conf"

}

function configure_modular_layer
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/neutron/conf/ml2_conf.ini" "/etc/neutron/plugins/ml2/ml2_conf.ini"
}

function connect_database
{
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
}

function restart_services
{
	service nova-api restart
	service nova-scheduler restart
	service nova-conductor restart
	service neutron-server restart
        remove_if_exists "/var/lib/glance/glance.sqlite"
}

function remove_if_exists {
        [[ -f "$1" ]] && rm -f "$1"
}

function verify_operation
{
	#source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	neutron ext-list
}

function main
{
	assert_superuser
	create_neutron_database
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	#register_in_keystone
	#install_network_components
	configure_neutron
	configure_modular_layer
	connect_database	
	restart_services
	verify_operation
}
main
