#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_ring
{
	swift-ring-builder account.builder create 10 3 1
	swift-ring-builder account.builder add r1z1-10.129.64.91:6002/sdb1 100
	swift-ring-builder account.builder add r1z1-10.129.64.91:6002/sdc1 100
	swift-ring-builder account.builder add r1z1-10.129.64.92:6002/sdb1 100
	swift-ring-builder account.builder add r1z1-10.129.64.92:6002/sdc1 100
	swift-ring-builder account.builder
	swift-ring-builder account.builder rebalance

}

function container_ring
{
	swift-ring-builder container.builder create 10 3 1
	swift-ring-builder container.builder add r1z1-10.129.64.91:6001/sdb1 100
	swift-ring-builder container.builder add r1z1-10.129.64.91:6001/sdc1 100
	swift-ring-builder container.builder add r1z1-10.129.64.92:6001/sdb1 100
	swift-ring-builder container.builder add r1z1-10.129.64.92:6001/sdbc 100
	swift-ring-builder account.builder

}

function object_ring
{
	swift-ring-builder object.builder create 10 3 1
	swift-ring-builder object.builder add r1z1-10.129.64.91:6000/sdb1 100
	swift-ring-builder object.builder add r1z1-10.129.64.91:6000/sdc1 100
	swift-ring-builder object.builder add r1z1-10.129.64.92:6000/sdb1 100
	swift-ring-builder object.builder add r1z1-10.129.64.92:6000/sdc1 100
	swift-ring-builder account.builder
	swift-ring-builder account.builder rebalance


}

function main
{
	assert_superuser
	cp "/home/openstack/Documentos/openstackUECE/controller-node/15_openstack_swift_rings.sh" "/etc/swift"
#	create_ring
#	container_ring
#	object_ring
}

main
