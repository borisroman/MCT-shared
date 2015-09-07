#!/bin/bash

mkdir -p /etc/cloudstack/management/

cp /data/git/cs1.cloud.lan/cloudstack/client/target/cloud-client-ui-4.6.0-SNAPSHOT/WEB-INF/classes/db.properties /etc/cloudstack/management/

/data/git/cs1.cloud.lan/cloudstack/client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /data/storage/secondary -u http://jenkins.buildacloud.org/job/build-systemvm64-master/lastSuccessfulBuild/artifact/tools/appliance/dist/systemvm64template-master-4.6.0-kvm.qcow2.bz2 -h kvm -F
