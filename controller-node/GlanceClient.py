import urllib,os
import glanceclient.v2.client as glclient
from GlanceCredentials import glance

os.system('source /home/openstack/Documentos/openstackUECE/controller-node/admin-demo/admin-openrc.sh')



def list_images():
	print ("This is your images:\n") 
	images = glance.images.list()
	for image in images:
		print image 

list_images()
print ("\n\n\n\n")
ch = int(raw_input('What would you like to do?\n1 - Delete images by ID\n2 - Create an Image\n'))

if ch == 1:
	id = int(raw_input("Type Images's ID:\n")) 
	glance.delete(ID)
	print('Image has been deleted successfully\n')
	list_images()
elif ch == 2:
	namefile = raw_input("Give me the directory of the image for registering\n")
	imagename = raw_input("Give me the name of the image you want to create\n")
	disk = raw_input("Give me the format of the disk\n")
	cformar = raw_input("Now I need a format for the container\n")
	with open(namefile) as fimage:
		glance.images.create(name=imagename, is_public=True, disk_format=disk,
			container_format=cformat,data=namefile)
	print("Image has been created successfully\n")
	list_images()	
	
	
	
else:
	print ('Invalid Option.\n')
