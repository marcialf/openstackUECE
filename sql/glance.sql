CREATE database glance;

GRANT ALL PRIVILEGES ON glance.* TO 'keystone'@'localhost' IDENTIFIED BY 'openstack';

GRANT ALL PRIVILEGES ON glance.* TO 'keystone'@'%' IDENTIFIED BY 'openstack';


