#!/bin/bash

function create_instance
{
	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/demo-openrc.sh"

	ssh-keygen

	nova keypair-add --pub-key ~/.ssh/id_rsa.pub demo-key
	verify_operation
	list_function

	source "/home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh"
	list_function2

}


function verify_operation
{
	nova keypair-list
}

function list_function
{
	nova flavor-list
	nova image-list
}

function list_function2
{
	nova net-list
	nova secgroup-list
}

function main
{
	create_instance
}

main
