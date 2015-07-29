service cloudstack-agent stop

rm /var/log/cloudstack/agent/*

cd /usr/share/cloudstack-agent/lib/

for FILE in $(ls *.jar); do
  wget -O $FILE http://cloudstack-dev.o.auroraobjects.eu/4.5.2-SNAPSHOT/$FILE
done

cd /root

service cloudstack-agent start
