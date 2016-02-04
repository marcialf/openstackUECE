#!/bin/bash

NTP_SERVER="ntp.ubuntu.com"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function config_ntp_server {
	NTP_CONFIG_FILE="/etc/ntp.conf"			
	sed -i"" -e"s/server .*//" $NTP_CONFIG_FILE
	sed -i"" -e"s/nopeer//" $NTP_CONFIG_FILE
	sed -i"" -e"s/noquery//" $NTP_CONFIG_FILE
	echo "server $NTP_SERVER iburst" >> $NTP_CONFIG_FILE
}

function config_ntp_client {
	NTP_CONFIG_FILE="/etc/ntp.conf"
	sed -i"" -e"s/server .*//" $NTP_CONFIG_FILE
	echo "server controller iburst" >> $NTP_CONFIG_FILE	
}

function main {
	assert_superuser
	apt-get install ntp -y
	[[ -f "/var/lib/ntp/ntp.conf.dhcp" ]] && rm "/var/lib/ntp/ntp.conf.dhcp"
	[[ "$(hostname)" == "openstack" ]] && config_ntp_server		
	[[ "$(hostname)" == "stack" ]] && config_ntp_client
	service ntp restart
}

main
