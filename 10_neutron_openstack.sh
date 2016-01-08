#!/bin/bash
MARIADB_PASSWORD="openstack"
KEYSTONE_USER_NEUTRON_PASSWORD="openstack"
EMAIL_NEUTRON="neutron@example.com"

function create_neutron_database
{
	mysql -u root "-p${MARIADB_PASSWORD}" < "neutron.sql"
}

function register_in_keystone
{
	source admin-openrc.sh
	keystone user-create --name neutron --pass $KEYSTONE_USER_NEUTRON_PASSWORD --email $EMAIL_NEUTRON
	keystone user-add-role --user neutron --tenant service --role admin
	keytone service-create --name neutron --type network \
  		--description "OpenStack Networking"

  	keystone endpoint-create \
	    --service-id $(keystone service-list | awk '/ network / {print $2}') \
	    --publicurl http://controller:9696 \
	    --adminurl http://controller:9696 \
	    --internalurl http://controller:9696 \
	    --region regionOne
}


function install_neutron_packages
{
	apt-get install neutron-server neutron-plugin-ml2 python-neutronclient
}

function configure_neutron
{
	#neutron.conf ak

	#neutron ml2_conf.ini ak

	#nova.conf ak

}


function init_neutron_database
{
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
}

function restart_services
{
	service nova-api restart
	service neutron-server restart
}


function verify_operation
{
	source admin-openrc.sh

	neutron ext-list
}