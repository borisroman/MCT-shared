#!/bin/bash

# Disable selinux
setenforce permissive
sed -i "/SELINUX=enforcing/c\SELINUX=permissive" /etc/selinux/config

# Disable firewall
systemctl stop firewalld
systemctl disable firewalld

# Prepare CentOS7 bare box to compile CloudStack and run management server
sleep 5
yum -y install maven tomcat mkisofs python-paramiko jakarta-commons-daemon-jsvc jsvc ws-commons-util genisoimage gcc python MySQL-python openssh-clients wget git python-ecdsa bzip2 python-setuptools mariadb-server mariadb python-devel vim nfs-utils screen setroubleshoot openssh-askpass java-1.8.0-openjdk-devel.x86_64 rpm-build ntp

systemctl start mariadb.service
systemctl enable mariadb.service

mkdir -p /data
mount -t nfs 192.168.23.1:/data /data
echo "192.168.23.1:/data /data nfs rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0" >> /etc/fstab

mkdir -p /data/git
cd /root

wget https://raw.githubusercontent.com/remibergsma/dotfiles/master/.screenrc

curl "https://bootstrap.pypa.io/get-pip.py" | python 
pip install mysql-connector-python --allow-external mysql-connector-python requests
pip install cloudmonkey

easy_install nose
easy_install pycrypto

# Get source
BASEDIR=/data/git/${HOSTNAME}

mkdir -p ${BASEDIR}
cd ${BASEDIR}
if [ ! -d "cloudstack/.git" ]; then
  echo "No git repo found, cloning https://github.com/borisroman/cloudstack.git"
  git clone https://github.com/borisroman/cloudstack.git
  echo "Please use 'git checkout' to checkout the branch you need."
else
  echo "Git Apache CloudStack repo already found"
fi
cd cloudstack

echo "Checking out branch 4.5"
git checkout 4.5

# Set MVN compile options
export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=512m -Xdebug -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n -Djava.net.preferIPv4Stack=true"
pwd
echo "Done."

host_ip=`ip addr | grep 'inet 192' | cut -d: -f2 | awk '{ print $2 }' | awk -F\/24 '{ print $1 }'`

# Compile ACS
mvn clean install -P developer,systemvm -DskipTests
# Deploy DB
mvn -P developer -pl developer -Ddeploydb
# Configure the hostname properly - it doesn't exist if the deployeDB doesn't include devcloud
mysql -u cloud -pcloud cloud --exec "INSERT INTO cloud.configuration (instance, name, value) VALUE('DEFAULT', 'host', '$host_ip') ON DUPLICATE KEY UPDATE value = '$host_ip';"

# Adding the right SystemVMs, for KVM
# Adding the tiny linux VM templates for KVM
mysql -u cloud -pcloud cloud --exec "UPDATE cloud.vm_template SET url='http://cloudstack.apt-get.eu/systemvm/4.5/systemvm64template-4.5-kvm.qcow2.bz2' where id=1;"
mysql -u cloud -pcloud cloud --exec "UPDATE cloud.vm_template SET url='http://dl.openvm.eu/cloudstack/macchinina/x86_64/macchinina-kvm.qcow2.bz2', guest_os_id=140, name='tiny linux kvm', display_text='tiny linux kvm', hvm=1 where id=2;"

# Open ports for Cloudstack
#firewall-cmd --permanent --add-port=8080/tcp
#firewall-cmd --permanent --add-port=8081/tcp
#firewall-cmd --permanent --add-port=8787/tcp

# Reboot
reboot
