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
	#cp "templates/nova.sql" "temp/nova.sql"	
	#sed -i'' -e"s/NOVA_DBPASS/$NOVA_DB_PASSWORD/" "temp/nova.sql"
	mysql -u root "-p${MARIADB_PASSWORD}" < "/home/openstack/Documentos/openstackUECE/controller-node/sql/neutron.sql"
}

function register_in_keystone
{
	 source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	
	openstack user create --password-prompt neutron  $KEYSTONE_USER_NEUTRON_PASSWORD

	openstack role add --project service --user neutron admin

	openstack service create --name neutron --description "OpenStack Networking" network

	openstack endpoint create --publicurl http://controller:9696 \
		--adminurl http://controller:9696 \
		--internalurl http://controller:9696 \
		--region RegionOne network
}

function install_network_components
{
	apt-get install -y neutron-server neutron-plugin-ml2 python-neutronclient

}

function configure_neutron
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/neutron/conf/neutron.conf" "/etc/neutron/neutron.conf"
}

function configure_modular_layer
{
	cp "/home/openstack/Documentos/openstackUECE/controller-node/neutron/conf/ml2_conf.ini" "/etc/neutron/plugins/ml2/ml2_conf.ini"
}

function verify_operation
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	neutron ext-list
}

function finalize_installation
{
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
}

function verify_operation
{
	neutron ext-list
}

function main
{
	assert_superuser
	create_neutron_database
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	register_in_keystone
	install_network_components
	#configure neutron
	#configure_modular_layer
	#finalize_installation
	#service nova-api restart
	#service neutron-server restart
	#verify_operation
}
main
