from os import environ as env
import keystoneclient.v2_0.client as ksclient
keystone = ksclient.Client(auth=env['OS_AUTH_URL'],
                           username=env['OS_USERNAME'],
                           password=env['OS_PASSWORD'],
                           tenant_name=env['OS_TENANT_NAME'],
                           region_name=env['OS_REGION_NAME'])

print keystone.auth_token