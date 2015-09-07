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
cloudmonkey set apikey $api_key
cloudmonkey set secretkey $secret_key

#####################
# Setup Basic Zone  #
#####################

# Create zone.
zone_id=$(cloudmonkey -d default create zone networktype=Basic securitygroupenabled=true name=z01 dns1=93.180.70.22 dns2=93.180.70.30  internaldns1=93.180.70.22 internaldns2=93.180.70.30 | grep 'id' | awk {'print $3'})

# Create physical network
physical_network_id=$(cloudmonkey -d default create physicalnetwork zoneid=$zone_id name="Physical Network 1" | grep 'id' | awk {'print $3'})

# Add traffic type Guest
$(cloudmonkey -d default add traffictype traffictype=Guest physicalnetworkid=$physical_network_id)

# Add traffic type Management
$(cloudmonkey -d default add traffictype traffictype=Management physicalnetworkid=$physical_network_id)

# Enable network
$(cloudmonkey -d default update physicalnetwork state=Enabled id=$physical_network_id)

# List network service providers
nspid=$(cloudmonkey -d default list networkserviceproviders name=VirtualRouter physicalnetworkid=$physical_network_id filter=id | grep 'id' | awk {'print $3'})

# List virtual router elements
virtual_router_element=$(cloudmonkey -d default list virtualrouterelements nspid=$nspid filter=id | grep 'id' | awk {'print $3'})

# Configure router element
$(cloudmonkey -d default configure virtualrouterelement enabled=true id=$virtual_router_element)

# Update network service provider
$(cloudmonkey -d default update networkserviceprovider state=Enabled id=$nspid)

# List security group providers
security_group_provider_id=$(cloudmonkey -d default list networkserviceproviders name=SecurityGroupProvider physicalnetworkid=$physical_network_id filter=id | grep 'id' | awk {'print $3'})

# Enable securitygroupprovider
$(cloudmonkey -d default update networkserviceprovider state=Enabled id=$security_group_provider_id)

# Get networkoffering id.
network_offering_id=$(cloudmonkey -d default list networkofferings name=DefaultSharedNetworkOfferingWithSGService filter=id | grep 'id' | awk {'print $3'})

# Create network
network_id=$(cloudmonkey -d default create network zoneid=$zone_id name=defaultGuestNetwork displaytext=defaultGuestNetwork networkofferingid=$network_offering_id filter=id | grep 'id' | awk {'print $3'})

# Create pod
pod_id=$(cloudmonkey -d default create pod zoneid=$zone_id name=p01 gateway=192.168.23.1 netmask=255.255.255.0 startip=192.168.23.150 endip=192.168.23.200 filter=id | grep 'id' | awk {'print $3'})

# Create vlan ip range
$(cloudmonkey -d default create vlaniprange podid=$pod_id networkid=$network_id gateway=192.168.22.1 netmask=255.255.255.0 startip=192.168.22.150 endip=192.168.22.200 forvirtualnetwork=false)

# Add cluster
cluster_id=$(cloudmonkey -d default add cluster zoneid=$zone_id hypervisor=KVM clustertype=CloudManaged podid=$pod_id clustername=c01 filter=id | grep 'id' | awk {'print $3'})	
