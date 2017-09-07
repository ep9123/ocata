#
set -x
# install mariadb and configure

# MariaDB non default 
apt -y install software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository -y 'deb [arch=amd64,i386,ppc64el] http://mirrors.accretive-networks.net/mariadb/repo/10.2/ubuntu xenial main'
apt -y update

apt -y install mariadb-server python-pymysql

crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld bind-address 10.0.2.15 
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld default-storage-engine innodb 
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld innodb_file_per_table on 
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld max_connections 4096
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld collation-server utf8_general_ci
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld character-set-server utf8 

service mysql restart

#mysql_secure_installation

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

# set password for root account even though we have authentication plugin assigned
# need to add pwgen and generate a password
# this method locks down so only root user can access root;
mysql -e "set password for 'root'@'localhost' = password('openstack');"
mysql -e "FLUSH PRIVILEGES;" 
