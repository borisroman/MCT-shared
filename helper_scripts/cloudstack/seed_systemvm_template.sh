#!/bin/bash

# We work from here
cd /data/git/$HOSTNAME/cloudstack

mkdir -p /etc/cloudstack/management/
cp ./client/target/cloud-client-ui-4.6.0-SNAPSHOT/WEB-INF/classes/db.properties /etc/cloudstack/management/
./client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /data/storage/secondary -u http://jenkins.buildacloud.org/job/build-systemvm64-master/lastSuccessfulBuild/artifact/tools/appliance/dist/systemvm64template-master-4.6.0-kvm.qcow2.bz2 -h kvm -F
