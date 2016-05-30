from NovaCredentials import nova
import novaclient.v2.client as nvclient

print (nova.servers.list())
print(nova.images.list())
