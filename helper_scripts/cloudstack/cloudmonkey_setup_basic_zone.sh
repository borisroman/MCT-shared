#!/bin/bash

###########################################
# Register api keys for the admin user,   #
# and store them in ~/.cloudmonkey/config #
###########################################

# Get user id.
user_uuid=$(cloudmonkey -d default list users username=admin filter=id | grep 'id' | awk {'print $3'})

# Generate the user keys.
cloudmonkey register userkeys id=$user_uuid

api_key=$(cloudmonkey list accounts name=admin | grep 'apikey' | awk {'print $3'})
secret_key=$(cloudmonkey list accounts name=admin | grep 'secretkey' | awk {'print $3'})

# Add the keys to cloudmonkey
cloudmonkey set apikey `echo $api_key`
cloudmonkey set secretkey `echo $secret_key`

#####################
# Setup Basic Zone  #
#####################

# Create zone.
zone_uuid=$(cloudmonkey -d default create zone networktype=Basic securitygroupenabled=true name=z01 dns1=93.180.70.22 dns2=93.180.70.30 internaldns1=93.180.70.22 internaldns2=93.180.70.30 | grep 'id =' | awk {'print $3'})

# Create physical network
cloudmonkey -d default create physicalnetwork zoneid=`echo $zone_uuid` name="Physical Network 1"

# Get the physical network id
physical_network_uuid=$(cloudmonkey -d default list physicalnetworks filter=id | grep 'id =' | awk {'print $3'})

# Add traffic type Guest
cloudmonkey -d default add traffictype traffictype=Guest physicalnetworkid=`echo $physical_network_uuid` kvmnetworklabel=cloudbr0

# Add traffic type Management
cloudmonkey -d default add traffictype traffictype=Management physicalnetworkid=`echo $physical_network_uuid` kvmnetworklabel=cloudbr1

# Add traffic type Storage
cloudmonkey -d default add traffictype traffictype=Storage physicalnetworkid=`echo $physical_network_uuid` kvmnetworklabel=cloudbr1

# Enable network
cloudmonkey -d default update physicalnetwork state=Enabled id=`echo $physical_network_uuid`

# List network service providers
network_service_provider_uuid=$(cloudmonkey -d default list networkserviceproviders name=VirtualRouter physicalnetworkid=`echo $physical_network_uuid` filter=id | grep 'id' | awk {'print $3'})

# List virtual router elements
virtual_router_element=$(cloudmonkey -d default list virtualrouterelements nspid=`echo $network_service_provider_uuid` filter=id | grep 'id' | awk {'print $3'})

# Configure router element
cloudmonkey -d default configure virtualrouterelement enabled=true id=`echo $virtual_router_element`

# Update network service provider
cloudmonkey -d default update networkserviceprovider state=Enabled id=`echo $network_service_provider_uuid`

# List security group providers
security_group_provider_uuid=$(cloudmonkey -d default list networkserviceproviders name=SecurityGroupProvider physicalnetworkid=`echo $physical_network_uuid` filter=id | grep 'id' | awk {'print $3'})

# Enable securitygroupprovider
cloudmonkey -d default update networkserviceprovider state=Enabled id=`echo $security_group_provider_uuid`

# Get networkoffering id.
network_offering_uuid=$(cloudmonkey -d default list networkofferings name=DefaultSharedNetworkOfferingWithSGService filter=id | grep 'id' | awk {'print $3'})

# Create network
cloudmonkey -d default create network zoneid=`echo $zone_uuid` name=defaultGuestNetwork displaytext=defaultGuestNetwork networkofferingid=`echo $network_offering_uuid` filter=id

# Get the network uuid
network_uuid=$(cloudmonkey -d default list networks filter=id | grep 'id' | awk {'print $3'})

# Create pod
cloudmonkey -d default create pod zoneid=`echo $zone_uuid` name=p01 gateway=192.168.23.1 netmask=255.255.255.0 startip=192.168.23.150 endip=192.168.23.200

# Get pod id
pod_uuid=$(cloudmonkey -d default list pods filter=id | grep 'id' | awk {'print $3'})

# Create vlan ip range
cloudmonkey -d default create vlaniprange podid=`echo $pod_uuid` networkid=`echo $network_uuid` gateway=192.168.22.1 netmask=255.255.255.0 startip=192.168.22.150 endip=192.168.22.200 forvirtualnetwork=false

# Add cluster
cloudmonkey -d default add cluster zoneid=`echo $zone_uuid` hypervisor=KVM clustertype=CloudManaged podid=`echo $pod_uuid` clustername=c01

# Get the cluster id
cluster_uuid=$(cloudmonkey -d default list clusters filter=id | grep 'id' | awk {'print $3'})

# Add a host
cloudmonkey -d default add host zoneid=`echo $zone_uuid` podid=`echo $pod_uuid` clusterid=`echo $cluster_uuid` hypervisor=KVM username=root password=installer url="http://192.168.23.21"

# Add primary storage
cloudmonkey -d default create storagepool zoneid=`echo $zone_uuid` podid=`echo $pod_uuid` clusterid=`echo $cluster_uuid` name=primstor scope=cluster url=nfs://192.168.23.1/data/storage/primary

# Add secondary storage
cloudmonkey -d default add imagestore name=secstor provider=NFS zoneid=`echo $zone_uuid` url=nfs://192.168.23.1/data/storage/secondary

