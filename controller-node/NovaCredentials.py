from os import environ as env
import novaclient.v2.client as nvclient
nova = nvclient.Client(auth_url=env['OS_AUTH_URL'],
                       username=env['OS_USERNAME'],
                       api_key=env['OS_PASSWORD'],
                       project_id=env['OS_TENANT_NAME'])

 
