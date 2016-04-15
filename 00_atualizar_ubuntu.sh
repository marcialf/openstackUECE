#!/bin/bash

NTP_SERVER="ntp.ubuntu.com"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function main
{
	assert_superuser
	apt-get install -y upgrade && apt-get install -y dist-upgrade
}

main
