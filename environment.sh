#
##################################################
# setup environment
##################################################
set -x

# Password is passed 
export OSPASSWD=$1
echo " " 	>>  ~/.profile
echo "export OSPASSWD=${OSPASSWD}" 	>>  ~/.profile

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

##################################################
# set our hostnames
##################################################
echo "ocata" > /etc/hostname

# set name resolution in /etc/hosts
echo "127.0.0.1 locahost" 	> /etc/hosts
echo "10.0.2.15 ocata" 		>> /etc/hosts
echo "10.0.2.15 controller" 	>> /etc/hosts
echo "10.0.2.15 compute1" 	>> /etc/hosts
echo "10.0.2.15 block1" 	>> /etc/hosts
echo "10.0.2.15 object1" 	>> /etc/hosts
echo "10.0.2.15 object2" 	>> /etc/hosts

apt -y install software-properties-common
add-apt-repository -y cloud-archive:ocata

apt -y update && apt -y dist-upgrade

apt -y install python-openstackclient crudini pwgen

##################################################
# install mariadb and configure
##################################################

# MariaDB non default 
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository -y 'deb [arch=amd64,i386,ppc64el] http://mirrors.accretive-networks.net/mariadb/repo/10.2/ubuntu xenial main'
apt -y update
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< "mariadb-server mysql-server/root_password password ${OSPASSWD}"
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password ${OSPASSWD}" 

apt -y install mariadb-server mariadb-backup-10.2 python-pymysql

crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld bind-address 10.0.2.15 
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld default-storage-engine innodb 
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld innodb_file_per_table on 
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld max_connections 4096
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld collation-server utf8_general_ci
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld character-set-server utf8 
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld plugin-load-add auth_socket.so
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld plugin-load-add simple_password_check.so
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld simple_password_check_other_characters 0

#Secure installation 
mysql -p${OSPASSWD} -e "install plugin unix_socket soname 'auth_socket.so'; update mysql.user set plugin = 'unix_socket' where User='root';"

service mysql restart

# Remove Anonymous Accounts, if they exist
mysql -e "DELETE FROM mysql.user WHERE User='';" 
mysql -e "FLUSH PRIVILEGES;" 

# Removing root user accounts for IPv4, IPv6 and hostname of machine
mysql -e "DELETE FROM mysql.user WHERE User='root' and Host!='localhost';" 
mysql -e "FLUSH PRIVILEGES;" 

# Removing Test databases, if they exist
# DB_LIST=`echo "show databases like 'test%;"| ${MYSQL}`
mysql -e "DROP database if exists test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"

##################################################
# install rabbitmq and configure
##################################################

apt -y install rabbitmq-server
rabbitmqctl add_user openstack ${OSPASSWD}
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

##################################################
# install memcached and configure
##################################################

apt -y install memcached python-memcache
sed -i "s:127.0.0.1:10.0.2.15:g" /etc/memcached.conf
service memcached restart
