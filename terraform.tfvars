
vm_name = "ipsec-gateway"
sg_name = "ipsec-gateway-sg"
rt_name = "ipsec-gateway-rt"

vm_zone      = "ru-central1-a"
vm_platform  = "standard-v3"
vm_cores     = 2
vm_memory    = 4
image_family = "ipsec-instance-ubuntu"

inside_subnet = "subnet-1"
inside_ip     = "192.168.1.5"

outside_subnet = "outside-subnet"
outside_ip     = "192.168.0.5"
pub_ip_name    = "ipsec-pub-ip"

vm_user_name         = "oper"
vm_user_ssh_key_file = "~/.ssh/id_ed25519.pub"

ipsec = {
  policy_name    = "yc-ipsec"
  remote_ip      = "x.x.x.x"
  ike_proposal   = "aes128gcm16-prfsha256-ecp256"
  esp_proposal   = "aes128gcm16"
  preshared_key  = "Sup@385paS4"
  local_subnets  = ["192.168.1.0/24"]
  remote_subnets = ["10.10.11.0/24", "10.10.12.0/24"]
  r_timeout      = "3.0"
  r_tries        = "3"
  r_base         = "1.0"
}
