# ===============================================================
# IPsec Security Gateway (SGW) image based on strongSwan solution
# https://docs.strongswan.org/docs/latest
# ===============================================================

variable "YC_FOLDER_ID" {
  type = string
  default = env("YC_FOLDER_ID")
}

variable "YC_ZONE" {
  type = string
  default = env("YC_ZONE")
}

variable "YC_SUBNET_ID" {
  type = string
  default = env("YC_SUBNET_ID")
}

variable "HOME_DIR" {
  type = string
  default = "/home/ubuntu"
}

source "yandex" "ipsec" {
  folder_id           = "${var.YC_FOLDER_ID}"
  platform_id         = "standard-v3"
  source_image_family = "ubuntu-2404-lts"
  ssh_username        = "ubuntu"
  use_ipv4_nat        = "true"
  image_description   = "strongSwan IPsec instance"
  image_family        = "ipsec-instance-ubuntu"
  image_name          = "ipsec-instance-ubuntu"
  subnet_id           = "${var.YC_SUBNET_ID}"
  disk_type           = "network-ssd"
  disk_size_gb        = "30"
  zone                = "${var.YC_ZONE}"
}

build {
  sources = ["source.yandex.ipsec"]
  provisioner "file" {
    source = "ipsec-setup.sh"
    destination = "ipsec-setup.sh"
  }
  provisioner "file" {
    source = "swanctl.tpl"
    destination = "${var.HOME_DIR}/swanctl-conf.tpl"
  }
  provisioner "file" {
    source = "strongswan.tpl"
    destination = "${var.HOME_DIR}/strongswan-conf.tpl"
  }
  provisioner "file" {
    source = "ipsec-config.sh"
    destination = "${var.HOME_DIR}/ipsec-config.sh"
  }

  provisioner "shell" {
    pause_before = "3s"
    environment_vars = [
      "HOME_DIR=${var.HOME_DIR}",
    ]
    execute_command = "sudo {{ .Vars }} bash '{{ .Path }}'"
    scripts = [
      "ipsec-setup.sh"
    ]
  }
}
