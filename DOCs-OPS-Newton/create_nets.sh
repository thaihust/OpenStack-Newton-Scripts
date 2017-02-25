#!/bin/bash

source network_params.sh

# Create provider network and it's subnet

openstack network create  --share \
  --provider-physical-network $PROVIDER_PHYSICAL_NETWORK \
  --provider-network-type flat $PROVIDER_NET_NAME
  
  
openstack subnet create --network $PROVIDER_NET_NAME \
  --allocation-pool start=$PROVIDER_SUBNET_START_IP_ADDRESS,end=$PROVIDER_SUBNET_END_IP_ADDRESS \
  --dns-nameserver $PROVIDER_DNS_RESOLVER --gateway $PROVIDER_NETWORK_GATEWAY \
  --subnet-range $PROVIDER_NETWORK_CIDR $PROVIDER_SUBNET_NAME
  
# Create selfservice networks

openstack network create $SELF_SERVICE_NET_NAME
openstack subnet create --network $SELF_SERVICE_NET_NAME \
  --dns-nameserver $SELFSERVICE_DNS_RESOLVER --gateway $SELFSERVICE_NETWORK_GATEWAY \
  --subnet-range $SELFSERVICE_NETWORK_CIDR $SELF_SERVICE_SUBNET_NAME
  
# Create router 

neutron net-update $PROVIDER_NET_NAME --router:external
openstack router create $TENANT_ROUTER_NAME
# add router interface for selfservice network subnet
neutron router-interface-add $TENANT_ROUTER_NAME $SELF_SERVICE_SUBNET_NAME
# set gateway for router
neutron router-gateway-set $TENANT_ROUTER_NAME $PROVIDER_NET_NAME
