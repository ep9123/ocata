#
. ~/.profile
set -x
#####################################################
# install identity service and configure
#####################################################

mysql -e "create database keystone;" 
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${OSPASSWD}';"
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${OSPASSWD}';"

apt -y install keystone

crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:${OSPASSWD}@controller/keystone
crudini --set /etc/keystone/keystone.conf token provider fernet

su -s /bin/sh -c "keystone-manage db_sync" keystone

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

keystone-manage bootstrap --bootstrap-password ${OSPASSWD} \
  --bootstrap-admin-url http://controller:35357/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne

echo "ServerName controller" >> /etc/apache2/apache2.conf

service apache2 restart
rm -f /var/lib/keystone/keystone.db

export OS_USERNAME=admin
export OS_PASSWORD=${OSPASSWD}
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password demo demo
openstack user create --password demo demo
openstack role create user
openstack role add --project demo --user demo user

#####################
# Validation
#####################
#crudini --set /etc/keystone/keystone-paste.ini pipeline:public_api pipeline "healthcheck cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension public_service"
#crudini --set /etc/keystone/keystone-paste.ini pipeline:admin_api pipeline "healthcheck cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension public_service"
#crudini --set /etc/keystone/keystone-paste.ini pipeline:api_v3 pipeline "healthcheck cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension public_service"
#unset OS_AUTH_URL OS_PASSWORD
#openstack --os-auth-url http://controller:35357/v3 \
#  --os-project-domain-name default --os-user-domain-name default \
#  --os-project-name admin --os-username admin --os-password ${OSPASSWD} token issue
#openstack --os-auth-url http://controller:5000/v3 \
#  --os-project-domain-name default --os-user-domain-name default \
#  --os-project-name demo --os-username demo --os-password demo token issue

echo "export OS_PROJECT_DOMAIN_NAME=Default" >> ~/admin-openrc
echo "export OS_USER_DOMAIN_NAME=Default" >> ~/admin-openrc
echo "export OS_PROJECT_NAME=admin" >> ~/admin-openrc
echo "export OS_USERNAME=admin" >> ~/admin-openrc
echo "export OS_PASSWORD=${OSPASSWD}" >> ~/admin-openrc
echo "export OS_AUTH_URL=http://controller:35357/v3" >> ~/admin-openrc
echo "export OS_IDENTITY_API_VERSION=3" >> ~/admin-openrc
echo "export OS_IMAGE_API_VERSION=2" >> ~/admin-openrc

echo "export OS_PROJECT_DOMAIN_NAME=Default" >> ~/demo-openrc
echo "export OS_USER_DOMAIN_NAME=Default" >> ~/demo-openrc
echo "export OS_PROJECT_NAME=demo" >> ~/demo-openrc
echo "export OS_USERNAME=demo" >> ~/demo-openrc
echo "export OS_PASSWORD=demo" >> ~/demo-openrc
echo "export OS_AUTH_URL=http://controller:5000/v3" >> ~/demo-openrc
echo "export OS_IDENTITY_API_VERSION=3" >> ~/demo-openrc
echo "export OS_IMAGE_API_VERSION=2" >> ~/demo-openrc


