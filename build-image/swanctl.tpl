# ================================================================
# StrongSwan Connection Configuration template file.
# Target config path: /etc/swanctl/conf.d/swanctl.conf
# 
# swanctl configuration file docs:
# https://docs.strongswan.org/docs/latest/swanctl/swanctlConf.html
# ================================================================

connections {
  ${policy_name} {
    remote_addrs = ${remote_ip}
    local {
      auth = psk
    }
    remote {
      auth = psk
    }
    version = 2 # IKEv2
    mobike = no
    proposals = ${ike_proposal}, default
    dpd_delay = 10s
    children {
      ${policy_name} {
        # Local IPv4 subnets
        local_ts = ${local_subnets}

        # Remote IPv4 subnets
        remote_ts = ${remote_subnets}

        start_action = start
        esp_proposals = ${esp_proposal}
        dpd_action = restart
      }
    }
  }
}

# Pre-Shared Key (PSK) for IPsec connection
secrets {
  ike-${policy_name} {
    id = %any
    secret = ${preshared_key}
  }
}
