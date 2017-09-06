# ocata
OpenStack ocata build allinone

Scripts are based on the following link
https://docs.openstack.org/ocata/install-guide-ubuntu/index.html# 

Since doing all in one installation I will not be setting up NTP

Lets start with a fresh vm build of ubuntu-serve-16.04.3
4 cpus
20 gb memory
Nat network with port forwarding for ssh and http
Example: 
http TCP 127.0.0.1 8080 10.0.2.15 80 
ssh  TCP 127.0.0.1 2222 10.0.2.15 22

Login and sudo -i  (become root)

export http_proxy=http://one.proxy.att.com:8080
export https_proxy=http://one.proxy.att.com:8080
export no_proxy=127.0.0.1,10.0.2.15,localhost

git clone https://github.com/ep9123/ocata

cd ocata
environment.sh  
sql.sh
message.sh
memcache.sh
identity.sh
image.sh
compute.sh
network.sh
dashboard.sh
cinder.sh
swift.sh
heat.sh
magnum.sh
trove.sh

