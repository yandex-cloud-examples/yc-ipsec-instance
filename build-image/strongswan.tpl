# ==================================================================
# strongSwan configuration: /etc/strongswan.conf
#
# https://docs.strongswan.org/docs/latest/config/strongswanConf.html
# ==================================================================

charon {
  start-scripts {
    configs = swanctl --load-all
  }

  # Interfaces
  interfaces_use = eth0

  # NAT keep alive interval in seconds
  keep_alive = 10s            

  # Retransmission
  # https://docs.strongswan.org/docs/latest/config/retransmission.html
  retransmit_timeout = ${r_timeout} # Timeout in seconds
  retransmit_tries = ${r_tries} # Number of retransmissions to send before giving up
  retransmit_base = ${r_base} # Base of exponential backoff

  plugins {
    socket-default {
      use_ipv4 = yes
      use_ipv6 = no
    }
    ## https://docs.strongswan.org/docs/latest/plugins/bypass-lan.html#_configuration    
    bypass-lan {
     interfaces_ignore = eth0, eth1
    }
  }

  filelog {
    charon {
      path = /var/log/strongswan.log
      time_format = "%Y-%m-%d-%H:%M:%S"
      ike_name = yes
      append = no
      default = 2
    }
    stderr {
      default = 1
      #ike = 2
      #knl = 3
    }      
  }
}
