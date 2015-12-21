#!/bin/bash

ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"
KEYSTONE_DB_PASSWORD="openstack"
USER_ADMIN_PASSWORD="openstack"
USER_DEMO_PASSWORD="openstack"
EMAIL_ADMIN="admin@example.com"
EMAIL_DEMO="demo@example.com"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_keystone_database {	
	#cp "/vagrant/templates/keystone.sql" "/vagrant/temp/keystone.sql"	
	#sed -i'' -e"s/KEYSTONE_DBPASS/$KEYSTONE_DB_PASSWORD/" "/vagrant/temp/keystone.sql"
	mysql -u root "-p${MARIADB_PASSWORD}" < "keystone.sql"
}


function disable_keystone_autostart {
	echo "manual" > /etc/init/keystone.override
}


function install_keystone_packages {
	apt-get install -y keystone python-openstackclient apache2 libapache2-mod-wsgi memcached python-memcache
}


function configure_keystone {	
	#cp "/vagrant/templates/keystone.conf" "/vagrant/temp/keystone.conf"	
	#sed -i'' -e"s/ADMIN_TOKEN_PLACE/admin_token = $ADMIN_TOKEN/" "/vagrant/temp/keystone.conf"
	#sed -i'' -e"s~DB_CONNECTION_PLACE~connection = mysql://keystone:$KEYSTONE_DB_PASSWORD@controller/keystone~"	"/vagrant/temp/keystone.conf"
	rm "/etc/keystone/keystone.conf"
	cp "/home/stack/keystone.conf" "/etc/keystone/keystone.conf"
}


function init_keystone_database {
	su -s /bin/sh -c "keystone-manage db_sync" keystone
}

function configure_apache {
	echo "ServerName $(hostname)" >> "/etc/apache2/apache2.conf"
	cp "/home/stack/wsgi-keystone.conf" "/etc/apache2/sites-available/wsgi-keystone.conf"
	chmod 755 /etc/apache2/sites-available/wsgi-keystone.conf
	ln -s "/etc/apache2/sites-available/wsgi-keystone.conf" "/etc/apache2/sites-enabled"
	mkdir -p "/var/www/cgi-bin/keystone"
	curl "http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo" | tee "/var/www/cgi-bin/keystone/main" "/var/www/cgi-bin/keystone/admin"
	chown -R keystone:keystone "/var/www/cgi-bin/keystone"
	chmod 755 /var/www/cgi-bin/keystone/*
	service apache2 restart
	remove_if_exists "/var/lib/keystone/keystone.db"
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}

function create_project_users_and_roles {
	export OS_SERVICE_TOKEN=$ADMIN_TOKEN	
	export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0
	
	keystone tenant-create --name admin --description "Admin Tenant"

	keystone user-create --name admin --pass $USER_ADMIN_PASSWORD --email $EMAIL_ADMIN

	keystone role-create --name admin

	keystone user-role-add --user admin --tenant admin --role admin

	keystone tenant-create --name demo --description "Demo Tenant"

	keystone user-create --name demo --tenant demo --pass $USER_DEMO_PASSWORD --email $EMAIL_DEMO

	keystone tenant-create --name service --description "Service Tenant"	 
}


function create_service_and_api_entrypoint {
	export OS_SERVICE_TOKEN=$ADMIN_TOKEN	
	export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0
	keystone service-create --name keystone --type identity \
		--description "OpenStack Identity"	

	keystone endpoint-create \
		--service-id $(keystone service-list | awk '/ identity / {print $2}') \
		--publicurl http://controller:5000/v2.0 \
		--internalurl http://controller:5000/v2.0 \
		--adminurl http://controller:35357/v2.0 \
		--region regionOne
}


function verify_operation
{
	unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT	

	keystone --os-tenant-name admin --os-username admin --os-password $USER_ADMIN_PASSWORD \
		--os-auth-url "http://controller:35357/v2.0" token-get
	
	keystone --os-tenant-name admin --os-username admin --os-password $USER_ADMIN_PASSWORD \
		--os-auth-url "http://controller:35357/v2.0" tenant-list

	keystone --os-tenant-name admin --os-username admin --os-password $USER_ADMIN_PASSWORD \
		--os-auth-url "http://controller:35357/v2.0" user-list
	
	keystone --os-tenant-name admin --os-username admin --os-password $USER_ADMIN_PASSWORD \
		--os-auth-url "http://controller:35357/v2.0" role-list

	keystone --os-tenant-name demo --os-username demo --os-password $USER_ADMIN_PASSWORD \
		--os-auth-url "http://controller:35357/v2.0" token-get

	keystone --os-tenant-name demo --os-username demo --os-password $USER_ADMIN_PASSWORD \
		--os-auth-url "http://controller:35357/v2.0" user-list

}



function main
{
	assert_superuser
#	create_keystone_database
#	disable_keystone_autostart	
#	install_keystone_packages
#	configure_keystone
#	init_keystone_database
	configure_apache
	create_project_users_and_roles
	create_service_and_api_entrypoint
	verify_operation
}

main
