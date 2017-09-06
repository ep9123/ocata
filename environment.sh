#
# setup environment
echo " " >> /etc/hosts
echo "10.0.2.15 controller" >> /etc/hosts
echo "10.0.2.15 compute" >> /etc/hosts

apt-get -y install software-properties-common
add-apt-repository cloud-archive:ocata

apt -y update && apt -y dist-upgrade

apt -y install python-openstackclient crudini
