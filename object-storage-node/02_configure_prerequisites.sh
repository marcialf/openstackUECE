#!/bin/bash

function main
{
	apt-get instal -y install xfsprogs rsync
	mkfs.xfs /dev/sdb1
	mkfs.xfs /dev/sdc1

	mkdir -p /srv/node/sdb1
	mkdir -p /srv/node/sdc1

	#ponto e da pag 114, falta continuar
}
main
