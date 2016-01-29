#!/bin/bash

MANAGEMENT_NETWORK_INTERFACE="eth1"
DB_PASSWORD="openstack"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function install_mariadb {
	debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_PASSWORD"
	debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_PASSWORD"
	apt-get install -y mariadb-server python-mysqldb
}

function config_mariadb {
	#IP=$(ip -f inet addr show $MANAGEMENT_NETWORK_INTERFACE | grep inet | awk {'print $2'} | cut -d/ -f1)	
	#sed -i'' -e"s/BIND_ADDRESS_PLACE/$IP/" "temp/mysqld_openstack.cnf"
	cp "/home/stack/mysqld_openstack.cnf" "/etc/mysql/conf.d/mysqld_openstack.cnf"
}

function main {
	assert_superuser
	install_mariadb
	config_mariadb
	service mysql restart
	mysql_secure_installation
}

main
