# #######################
# strongSwan provisioning
# #######################

# Global Ubuntu things
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
timedatectl set-timezone Europe/Moscow
timedatectl set-ntp True

apt-get update -yq && apt-get upgrade -yq

echo iptables-persistent iptables-persistent/autosave_v4 boolean false | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean false | debconf-set-selections

apt-get -q -y install yq isc-dhcp-client iptables iptables-persistent strongswan strongswan-swanctl libcharon-extra-plugins charon-systemd libstrongswan-extra-plugins libstrongswan-standard-plugins

# Move files to the places
mv $HOME_DIR/swanctl-conf.tpl /usr/local/etc/swanctl-conf.tpl
mv /etc/strongswan.conf /etc/strongswan.conf.bak
mv $HOME_DIR/strongswan-conf.tpl /usr/local/etc/strongswan-conf.tpl
mv $HOME_DIR/ipsec-config.sh /usr/local/bin/ipsec-config.sh

# Configure Kernel parameters
SYS_FILE=/etc/sysctl.conf
echo -e "net.ipv4.ip_forward = 1" >> $SYS_FILE
echo -e "net.ipv4.conf.all.accept_redirects = 0" >> $SYS_FILE
echo -e "net.ipv4.conf.all.send_redirects = 0" >> $SYS_FILE
echo -e "net.ipv4.conf.default.accept_redirects = 0" >> $SYS_FILE
echo -e "net.ipv4.conf.default.send_redirects = 0" >> $SYS_FILE
# Disable IPv6
echo -e "net.ipv6.conf.all.disable_ipv6 = 1" >> $SYS_FILE
echo -e "net.ipv6.conf.default.disable_ipv6 = 1" >> $SYS_FILE
echo -e "net.ipv6.conf.lo.disable_ipv6 = 1" >> $SYS_FILE

# Enable rc.local system daemon
cat <<EOF > /etc/systemd/system/rc-local.service
[Unit]
  Description=/etc/rc.local Compatibility
  ConditionPathExists=/etc/rc.local

[Service]
  Type=forking
  ExecStart=/etc/rc.local start
  TimeoutSec=0
  StandardOutput=tty
  RemainAfterExit=yes
  SysVStartPriority=99

[Install]
  WantedBy=multi-user.target
EOF

cat <<EOF > /etc/rc.local
#!/bin/bash

# Restore Kernel settings
sysctl -p
EOF

chmod +x /etc/rc.local
systemctl enable rc-local

# Disable unnecessary strongSwan service
systemctl stop strongswan-starter.service 
systemctl disable strongswan-starter.service
systemctl daemon-reload

# Clean up image
userdel -f ubuntu
rm -rf /home/ubuntu
userdel -f yc-user
rm -rf /home/yc-user
rm -rf /root/.ssh/
