#!/bin/bash

# ==================================
# Configure strongSwan from Metadata
# ==================================

exports=$(curl -s -H Metadata-Flavor:Google 169.254.169.254/computeMetadata/v1/instance/attributes/ipsec | yq -r '. | to_entries[] | "export " + .key + "=" + (.value | tostring)')
eval $exports
envsubst < /usr/local/etc/swanctl-conf.tpl > /etc/swanctl/conf.d/swanctl.conf
envsubst < /usr/local/etc/strongswan-conf.tpl > /etc/strongswan.conf
systemctl restart strongswan
