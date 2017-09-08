#
set -x
# install memcached and configure

apt -y install memcached python-memcache

sed -i "s:127.0.0.1:10.0.2.15:g" /etc/memcached.conf

service memcached restart
