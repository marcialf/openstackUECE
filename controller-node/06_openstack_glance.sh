#!/bin/bash

ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"

GLANCE_DB_PASSWORD="openstack"
KEYSTONE_USER_GLANCE_PASSWORD="openstack"

EMAIL_GLANCE="glance@example.com"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_glance_database
{
	mysql -u root "-p${MARIADB_PASSWORD}" < "/home/openstack/Documentos/openstackUECE/sql/glance.sql"
}

function register_in_keystone
{
	source "/home/openstack/Documentos/openstackUECE/admin-demo/admin-openrc.sh"

	keystone user-create --name glance --pass $GLANCE_PASS --email $EMAIL_GLANCE

	keystone user-role-add --user glance --tenant service --role admin

	keystone service-create --name glance --type image --description "OpenStack Image Service"

	keystone endpoint-create \
	  --service-id $(keystone service-list | awk '/ image / {print $2}') \
	  --publicurl http://controller:9292 \
	  --internalurl http://controller:9292 \
	  --adminurl http://controller:9292 \
	  --region regionOne
}

function install_glance_packages
{
	apt-get install glance python-glanceclient
}

function configure_glance
{
	cp "/home/openstack/Documentos/glance-api.conf" "/etc/glance/glance-api.conf"
	cp "/home/openstack/Documentos/glance-registry.conf" "/etc/glance/glance-registry.conf"

}

function connect_database
{
	su -s /bin/sh -c "glance-manage db_sync" glance
}

function restart_services
{
	service glance-registry restart
	service glance-api restart
	remove_if_exists "/var/lib/glance/glance.sqlite"
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}

function verify_operation
{
	source "/home/openstack/Documentos/openstackUECE/admin-demo/admin-openrc.sh"
	mkdir /tmp/images
	wget -P /tmp/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

	glance image-create --name "cirros-0.3.4-x86_64" --file /tmp/images/cirros-0.3.4-x86_64-disk.img 		--disk-format qcow2 --container-format bare --is-public True --progress 
	
	glance image-list
}


function main
{
	assert_superuser
	#create_glance_database
	#register_in_keystone
	#install_glance_packages
	#configure_glance
	#connect_database
	#restart_services
	verify_operation
}

main
