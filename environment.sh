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

# set our hostname
echo "ocata" > /etc/hostname

# set name resolution in /etc/hosts
echo " " >> /etc/hosts
echo "10.0.2.15 controller" 	>> /etc/hosts
echo "10.0.2.15 compute1" 	>> /etc/hosts
echo "10.0.2.15 block1" 	>> /etc/hosts
echo "10.0.2.15 object1" 	>> /etc/hosts
echo "10.0.2.15 object2" 	>> /etc/hosts

#export http_proxy=http://one.proxy.att.com:8080
#export https_proxy=http://one.proxy.att.com:8080
#export no_proxy=127.0.0.1,10.0.2.15,localhost

apt -y install software-properties-common
add-apt-repository -y cloud-archive:ocata

apt -y update && apt -y dist-upgrade

apt -y install python-openstackclient crudini

# restart to make sure we are running latest updates
init 6
