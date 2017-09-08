#
set -x
# setup environment
# As root

# should be handled with os build
#echo 'Acquire::http::proxy "http://one.proxy.att.com:8080/";' >> /etc/apt/apt.conf
#echo 'Acquire::https::proxy "http://one.proxy.att.com:8080/";' >> /etc/apt/apt.conf

# proxy.sh
#echo "export http_proxy=http://one.proxy.att.com:8080"          >> /etc/profile.d/proxy.sh
#echo "export https_proxy=http://one.proxy.att.com:8080"         >> /etc/profile.d/proxy.sh
#echo "export no_proxy=127.0.0.1,10.0.2.15,localhost"            >> /etc/profile.d/proxy.sh

# environment
#echo "export http_proxy=http://one.proxy.att.com:8080"          >> /etc/environment
#echo "export https_proxy=http://one.proxy.att.com:8080"         >> /etc/environment
#echo "export no_proxy=127.0.0.1,10.0.2.15,localhost"            >> /etc/environment

#export http_proxy=http://one.proxy.att.com:8080
#export https_proxy=http://one.proxy.att.com:8080
#export no_proxy=127.0.0.1,10.0.2.15,localhost

# set our hostname
echo "ocata" > /etc/hostname

# set name resolution in /etc/hosts
echo "127.0.0.1 locahost" 	> /etc/hosts
echo "10.0.2.15 ocata" 		>> /etc/hosts
echo "10.0.2.15 controller" 	>> /etc/hosts
echo "10.0.2.15 compute1" 	>> /etc/hosts
echo "10.0.2.15 block1" 	>> /etc/hosts
echo "10.0.2.15 object1" 	>> /etc/hosts
echo "10.0.2.15 object2" 	>> /etc/hosts

echo " " 	>>  ~/.profile
echo "export OSPASSWD=OpenStack4u" 	>>  ~/.profile


apt -y install software-properties-common
add-apt-repository -y cloud-archive:ocata

apt -y update && apt -y dist-upgrade

apt -y install python-openstackclient crudini pwgen

# restart to make sure we are running latest updates
init 6
