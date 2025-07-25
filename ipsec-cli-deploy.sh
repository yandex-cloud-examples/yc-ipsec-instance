#!/bin/bash

# ======================================
# Deploy Yandex Cloud IPsec Instance
# image family_id: ipsec-instance-ubuntu
# ======================================

# =========================
# IPsec Instance parameters
# =========================
VM_NAME=ipsec-gateway
SG_NAME=ipsec-gateway-sg
RT_NAME=ipsec-gateway-rt

ZONE=ru-central1-d
PLATFORM=standard-v3
CORES=2
MEMORY=4G
IMAGE_FAMILY=ipsec-instance-ubuntu

INSIDE_NET_NAME=inside-net
INSIDE_SUBNET=subnet-1
INSIDE_IP=192.168.1.5

OUTSIDE_SUBNET=outside-subnet
OUTSIDE_IP=192.168.0.5
PUB_IP_NAME=ipsec-pub-ip

export USER_NAME=oper
export USER_SSH_KEY=$(cat ~/.ssh/id_ed25519.pub)

# ===========================
# IPsec Connection parameters
# ===========================
export POLICY_NAME=yc-ipsec
export REMOTE_IP=158.160.186.7
export PRESHARED_KEY="Sup@385paS4"
export LOCAL_SUBNETS=192.168.1.0/24
export REMOTE_SUBNETS=10.10.11.0/24,10.10.12.0/24
# https://docs.strongswan.org/docs/latest/config/proposals.html
export IKE_PROPOSAL=aes128gcm16-prfsha256-ecp256
export ESP_PROPOSAL=aes128gcm16
# https://docs.strongswan.org/docs/latest/config/retransmission.html
export R_TIMEOUT=3.0
export R_TRIES=3
export R_BASE=1.0

# Create VPC Route table with remote subnets CIDR's
INSIDE_NET_ID=$(yc vpc network get $INSIDE_NET_NAME --jq .id)
RT_CLI="yc vpc route-table create --name $RT_NAME --network-id $INSIDE_NET_ID"
PFX_LIST=$(grep remote_subnets ipsec.yml | cut -d' ' -f2- | tr "," " ")
for PFX in $PFX_LIST; do 
  RT_CLI+=" --route destination=$PFX,next-hop=$INSIDE_IP"; 
done
eval $RT_CLI

# Reserve Public static IP address for Outside interface
OUTSIDE_PUB_IP=$(yc vpc address create --name $PUB_IP_NAME --external-ipv4 zone $ZONE --jq .external_ipv4_address.address)

# Create Security Group for the Outside interface
OUTSIDE_NET_ID=$(yc vpc subnet get $OUTSIDE_SUBNET --jq .network_id)
yc vpc security-group create --name $SG_NAME --network-id $OUTSIDE_NET_ID \
  --rule "description=ipsec,direction=ingress,port=4500,protocol=udp,v4-cidrs=[0.0.0.0/0]" \
  --rule "description=ssh,direction=ingress,port=22,protocol=tcp,v4-cidrs=[0.0.0.0/0]" \
  --rule "description=icmp,direction=ingress,protocol=icmp,v4-cidrs=[0.0.0.0/0]" \
  --rule "description=permit-any,direction=egress,port=any,protocol=any,v4-cidrs=[0.0.0.0/0]"
SG_ID=$(yc vpc security-group get $SG_NAME --jq .id)

# Create IPsec instance VM
yc compute instance create --name $VM_NAME --hostname $VM_NAME --zone $ZONE \
  --platform-id $PLATFORM --cores=$CORES --memory=$MEMORY --core-fraction=100 \
  --create-boot-disk image-family=$IMAGE_FAMILY \
  --network-interface subnet-name=$OUTSIDE_SUBNET,ipv4-address=$OUTSIDE_IP,nat-ip-version=ipv4,nat-address=$OUTSIDE_PUB_IP,security-group-ids=$SG_ID \
  --network-interface subnet-name=$INSIDE_SUBNET,ipv4-address=$INSIDE_IP \
  --metadata-from-file user-data=vm-init.tpl \
  --metadata-from-file ipsec=ipsec.tpl
