#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function main {
	assert_superuser
	apt-get install ubuntu-cloud-keyring -y
	echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/kilo main" > /etc/apt/sources.list.d/cloudarchive-kilo.list
	apt-get update && apt-get dist-upgrade -y
	#reboot now
}

main