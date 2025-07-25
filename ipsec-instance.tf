
// Get VM image Id for SGW deployment
data "yandex_compute_image" "instance_image" {
  folder_id = var.folder_id
  family    = var.image_family
}

// Get Outside subnet for references
data "yandex_vpc_subnet" "outside" {
  name = var.outside_subnet
}

// Get Inside subnet for references
data "yandex_vpc_subnet" "inside" {
  name = var.inside_subnet
}

// Create VPC Route Table for route traffic
// to remote subnets via IPsec instance (inside interface)
resource "yandex_vpc_route_table" "instance_rt" {
  folder_id  = var.folder_id
  name       = var.rt_name
  network_id = data.yandex_vpc_subnet.inside.network_id

  dynamic "static_route" {
    for_each = var.ipsec.remote_subnets
    content {
      destination_prefix = static_route.value
      next_hop_address   = var.inside_ip
    }
  }
}

// Reserve a static IP for the outside interface of IPsec instance
resource "yandex_vpc_address" "instance_pub_ip" {
  folder_id = var.folder_id
  name      = var.pub_ip_name
  external_ipv4_address {
    zone_id = var.vm_zone
  }
}

// Create Security Group for outside interface of IPsec instance
resource "yandex_vpc_security_group" "instance_sg" {
  folder_id   = var.folder_id
  name        = var.sg_name
  description = "IPsec instance outside interface SG"
  network_id  = data.yandex_vpc_subnet.outside.network_id

  ingress {
    description    = "icmp"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ssh"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ipsec"
    protocol       = "UDP"
    port           = "4500"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

// Create IPsec instance VM
resource "yandex_compute_instance" "ipsec_instance" {
  folder_id   = var.folder_id
  name        = var.vm_name
  hostname    = var.vm_name
  platform_id = var.vm_platform
  zone        = var.vm_zone
  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.instance_image.id
    }
  }

  // Outside interface (eth0)
  network_interface {
    subnet_id          = data.yandex_vpc_subnet.outside.id
    ip_address         = var.outside_ip
    nat                = true
    nat_ip_address     = yandex_vpc_address.instance_pub_ip.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.instance_sg.id]
  }

  // Inside interface (eth1)
  network_interface {
    subnet_id  = data.yandex_vpc_subnet.inside.id
    ip_address = var.inside_ip
    nat        = false
  }

  metadata = {
    user-data = templatefile("${path.module}/vm-init.tpl", {
      USER_NAME    = var.vm_user_name
      USER_SSH_KEY = file(var.vm_user_ssh_key_file)
    }),
    ipsec = templatefile("${path.module}/ipsec.tpl", {
      POLICY_NAME    = var.ipsec.policy_name
      REMOTE_IP      = var.ipsec.remote_ip
      IKE_PROPOSAL   = var.ipsec.ike_proposal
      ESP_PROPOSAL   = var.ipsec.esp_proposal
      PRESHARED_KEY  = var.ipsec.preshared_key
      LOCAL_SUBNETS  = replace(join(",", flatten(var.ipsec.local_subnets)), " ", "")
      REMOTE_SUBNETS = replace(join(",", flatten(var.ipsec.remote_subnets)), " ", "")
      R_TIMEOUT      = var.ipsec.r_timeout
      R_TRIES        = var.ipsec.r_tries
      R_BASE         = var.ipsec.r_base
    })
  }
}
