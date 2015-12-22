#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}


function nova_packages {
	apt-get install -y nova-compute sysfsutils
}


function configure_nova_Conf
{
	cp "/etc/nova/nova.conf" "/home/stack/nova.conf"
	
	#Rabbit_Default
	sed -i'' -e '$a\' -e 'rpc_backend = rabbit' "/home/stack/nova.conf"

	#Keystone_Default
	sed -i'' -e '$a\' -e 'auth_strategy = keystone' "/home/stack/nova.conf"


	#IP_Default
	sed -i'' -e '$a\' -e 'my_ip = 10.129.64.5'					"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'vnc_enabled = True'					"/home/stack/nova.conf"		
	sed -i'' -e '$a\' -e 'vncserver_listen = 0.0.0.0'				"/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'vncserver_proxyclient_address = 10.129.64.5'		"/home/stack/nova.conf"		
	sed -i'' -e '$a\' -e 'novncproxy_base_url = http://localhost:6080/vnc_auto.html'	"/home/stack/nova.conf"

	#Rabbit
	echo -e "\n[oslo_messaging_rabbit]" >> "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'rabbit_host = controller' "/home/stack/nova.conf"
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
	
	
	#rm -f /etc/nova/nova.conf
	cp "/home/stack/nova.conf"  "/etc/nova/nova.conf"
	

}


function configure_Nova_Compute_Conf
{
	cp "/etc/nova/nova-compute.conf" "/home/stack/nova-compute.conf"
	sed -i'' -e '/virt_type/s/=kvm/ = qemu/g' "/home/stack/nova-compute.conf"


	#rm -f /etc/nova/nova.conf
	cp "/vagrant/compute-node/nova-compute.conf"	"/etc/nova/nova-compute.conf" 
}


function main
{	
	assert_superuser
	nova_packages
	configure_nova_Conf
	#configure_Nova_Compute_Conf
	service nova-compute restart
	rm -f /var/lib/nova/nova.sqlite
}

main
