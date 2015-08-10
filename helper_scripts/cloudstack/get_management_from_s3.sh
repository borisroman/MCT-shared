cd /data/git/cs1.cloud.lan/cloudstack/client/target/cloud-client-ui-4.5.2-SNAPSHOT/WEB-INF/lib/

for FILE in $(ls *.jar); do
  wget -O $FILE http://cloudstack-dev.o.auroraobjects.eu/4.5.2-SNAPSHOT/$FILE
done

cd /root
