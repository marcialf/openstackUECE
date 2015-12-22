#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}


function nova_packages {
	apt-get install -y nova-network nova-api-metadata
}


function configure_nova_Conf
{
	cp "/etc/nova/nova.conf" "/home/stack/nova.conf"
	
	
	sed -i'' -e '$a\' -e 'network_api_class = nova.network.api.API' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'security_group_api = nova' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'firewall_driver = nova.virt.libvirt.firewall.IptablesFirewallDriver' "/home/stack/nova.conf"	
	sed -i'' -e '$a\' -e 'network_manager = nova.network.manager.FlatDHCPManager' "/home/stack/nova.conf"	
	sed -i'' -e '$a\' -e 'network_size = 254' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'allow_same_net_traffic = False' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'multi_host = True' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'send_arp_for_ha = True' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'share_dhcp_address = True' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'force_dhcp_release = True' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'flat_network_bridge = br100' "/home/stack/nova.conf"

	sed -i'' -e '$a\' -e 'flat_interface = eth0' "/home/stack/nova.conf"
	sed -i'' -e '$a\' -e 'public_interface = eth0' "/home/stack/nova.conf"




	#rm -f /etc/nova/nova.conf
	cp "/home/stack/nova.conf"  "/etc/nova/nova.conf"
	

}


function restart_services{
	service nova-network restart
	service nova-api-metadata restart

}


function main
{	
	assert_superuser
	nova_packages
	configure_nova_Conf
	restart_services
	rm -f /var/lib/nova/nova.sqlite
}

main
