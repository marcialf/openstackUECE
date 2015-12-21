#!/bin/bash

ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"

GLANCE_DB_PASSWORD="openstack"
KEYSTONE_USER_GLANCE_PASSWORD="openstack"

EMAIL_GLANCE="glance@example.com"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_glance_database {	
	#cp "templates/glance.sql" "temp/glance.sql"	
	#sed -i'' -e"s/GLANCE_DBPASS/$GLANCE_DB_PASSWORD/" "temp/glance.sql"
	mysql -u root "-p${MARIADB_PASSWORD}" < "glance.sql"
}

function register_in_keystone {
	source "/home/stack/admin-openrc2.sh"

	openstack user create --name glance --password $KEYSTONE_USER_GLANCE_PASSWORD 

	openstack role add --project service --user glance admin

	openstack service create --name glance --description "Openstack Image Service" image

	openstack endpoint create --publicurl http://localhost:9292 --internalurl http://localhost:9292 --adminurl http://localhost:9292 --region RegionOne  image


}

function install_glance_packages {
	apt-get install -y glance python-glanceclient
}


function configure_glance {

	sed -i'' -e"s~DB_CONNECTION_PLACE~mysql://glance:$GLANCE_DB_PASSWORD@localhost/glance~" "/home/stack/glance-api.conf"
	sed -i'' -e"s/KEYSTONE_USER_GLANCE_PASSWORD_PLACE/${KEYSTONE_USER_GLANCE_PASSWORD}/" "/home/stack/glance-api.conf"
	rm "/etc/glance/glance-api.conf"
	cp "/home/stack/glance-api.conf" "/etc/glance/glance-api.conf"

	sed -i'' -e"s~DB_CONNECTION_PLACE~mysql://glance:$GLANCE_DB_PASSWORD@controller/glance~" "/home/stack/glance-registry.conf"
	sed -i'' -e"s/KEYSTONE_USER_GLANCE_PASSWORD_PLACE/${KEYSTONE_USER_GLANCE_PASSWORD}/" "/home/stack/glance-registry.conf"
	rm "/etc/glance/glance-registry.conf"
	cp "/home/stack/glance-registry.conf" "/etc/glance/glance-registry.conf"
}

function init_glance_database {
	su -s /bin/sh -c "glance-manage db_sync" glance
}

function restart_services {
	service glance-registry restart
	service glance-api restart
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}

function verify_operation
{
	source "/home/stack/admin-openrc2.sh"
	mkdir /tmp/images
	wget -P /tmp/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
	glance image-create --name "cirros-0.3.4-x86_64" --file /tmp/images/cirros-0.3.4-x86_64-disk.img \
		--disk-format qcow2 --container-format bare --visibility public --progress
	glance image-list
}


function main
{
	assert_superuser
	#create_glance_database
	#register_in_keystone
	#install_glance_packages
	#configure_glance
	#init_glance_database
	#restart_services
	#remove_if_exists "/var/lib/glance/glance.sqlite"
	verify_operation
}

main
