#!/bin/bash

ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"

NOVA_DB_PASSWORD="openstack"
KEYSTONE_USER_NOVA_PASSWORD="openstack"
EMAIL_NOVA="nova@example.com"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_nova_database {	
	#cp "templates/nova.sql" "temp/nova.sql"	
	#sed -i'' -e"s/NOVA_DBPASS/$NOVA_DB_PASSWORD/" "temp/nova.sql"
	mysql -u root "-p${MARIADB_PASSWORD}" < "/home/stack/nova.sql"
}

function register_in_keystone {
	source "/home/stack/admin-openrc2.sh"
	openstack user create --password $KEYSTONE_USER_NOVA_PASSWORD nova

	openstack role add --project service --user nova admin

	openstack service create --name nova --description "OpenStack Computing Service" compute

	openstack endpoint create \
		--publicurl http://localhost:8774/v2/%\(tenant_id\)s \
		--internalurl http://localhost:8774/v2/%\(tenant_id\)s \
		--adminurl http://localhost:8774/v2/%\(tenant_id\)s \
		--region regionOne compute
}

function install_nova_packages {
	apt-get install -y nova-api nova-cert nova-conductor \
		nova-consoleauth nova-scheduler python-novaclient
	apt-get install -y novnc
	dpkg -i /home/stack/nova-novncproxy_2015.1.1-0ubuntu1~cloud2_all.deb
}

function configure_nova {

	#Rabbit_Default
	sed -i'' -e '$a\' -e 'rpc_backend = rabbit' "/home/stack/nova.conf"
	
	#Keystone_Default
	sed -i'' -e '$a\' -e 'auth_strategy = keystone' "/home/stack/nova.conf"

	#IP_Default
	sed -i'' -e '$a\' -e 'my_ip = 10.129.64.1'					"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'vncserver_listen =10.129.64.1'				"/home/stack/nova.conf"	
	sed -i'' -e '$a\' -e 'vncserver_proxyclient_address = 10.129.64.1'		"/home/stack/nova.conf"

	#Database
	echo -e "\n[database]" >> "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'connection = mysql://nova:openstack@localhost/nova' "/home/stack/nova.conf"
	
	#Rabbit
	echo -e "\n[oslo_messaging_rabbit]" >> "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'rabbit_host = localhost' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'rabbit_userid = openstack' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'rabbit_password = openstack' "/home/stack/nova.conf"

	#Keystone
	echo -e "\n[keystone_authtoken]" >> "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'auth_uri = http://localhost:5000' 	"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'auth_url = http://localhost:35357' 	"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'auth_plugin = password' 			"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'project_domain_id = default' 		"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'user_domain_id = default' 		"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'project_name = service' 			"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'username = nova' 				"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'password = openstack' 			"/home/stack/nova.conf"	


	#Glance
	echo -e "\n[glance]" >> "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'host = localhost' 	"/home/stack/nova.conf"


	#Lock_Path
	echo -e "\n[oslo_concurrency]" >> "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'lock_path = /var/lib/nova/tmp' "/home/stack/nova.conf"
	
	
	#Copiando e Removendo Arquivo
	rm -f /etc/nova/nova.conf
	cp "/home/stack/nova.conf" "/etc/nova/nova.conf"

	

	#Permissao para o arquivo
	#chmod 755 /etc/nova/*

}


function init_nova_database {
	su -s /bin/sh -c "nova-manage db sync" nova
}

function restart_services {
	service nova-api restart
	service	nova-cert restart
	service	nova-consoleauth restart
	service	nova-scheduler restart
	service	nova-conductor restart
	service	nova-novncproxy restart
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}

function main
{
	assert_superuser
	create_nova_database
	register_in_keystone
	install_nova_packages
	configure_nova
	init_nova_database	
	restart_services
	remove_if_exists "/var/lib/nova/nova.sqlite"
}

main
