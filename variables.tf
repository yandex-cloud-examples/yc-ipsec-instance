
variable "folder_id" {
  description = "Taken from environment variable"
  type        = string
}

variable "sg_name" {
  description = "IPsec Instance SG name for outside interface"
  type        = string
  default     = "ipsec-gateway-sg"
}

variable "rt_name" {
  description = "Route table name for route traffic via IPsec Instance to remote site"
  type        = string
  default     = "ipsec-gateway-rt"
}

variable "vm_name" {
  description = "IPsec Instance VM name"
  type        = string
  default     = "ipsec-gateway"
}

variable "vm_zone" {
  description = "Zone where IPsec Instance will be deployed"
  type        = string
  default     = "ru-central1-d"
}

variable "vm_platform" {
  description = "Compute platform type for the IPsec Instance"
  type        = string
  default     = "standard-v3"
}

variable "vm_cores" {
  description = "Number of vCPU cores for the IPsec Instance VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Amount of RAM for the IPsec Instance VM (in Gigabytes)"
  type        = number
  default     = 4
}

variable "image_family" {
  description = "The base image for the IPsec Instance VM deployment"
  type        = string
  default     = "ipsec-instance-ubuntu"
}

variable "inside_subnet" {
  description = "Subnet name for Inside network interface of IPsec Instance"
  type        = string
  default     = null
}

variable "inside_ip" {
  description = "IP address from INSIDE_SUBNET for the network interface of IPsec Instance"
  type        = string
  default     = null
}

variable "outside_subnet" {
  description = "Subnet name for Outside network interface of IPsec Instance"
  type        = string
  default     = null
}

variable "outside_ip" {
  description = "IP address from OUTSIDE_SUBNET for the network interface of IPsec Instance"
  type        = string
  default     = null
}

variable "pub_ip_name" {
  description = "Name for reserved static public IP address for Outside network interface of IPsec Instance"
  type        = string
  default     = "ipsec-pub-ip"
}

variable "vm_user_name" {
  description = "Name for the IPsec Instance VM admin user"
  type        = string
  default     = null
  validation {
    condition     = !contains(["root", "admin", "yc-user"], lower(var.vm_user_name))
    error_message = "This username is unusable! Please choose another name."
  }
}

variable "vm_user_ssh_key_file" {
  description = "Path to public SSH key of IPsec Instance VM admin user"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}


variable "ipsec" {
  description = "IPsec parameters"
  type = object(
    {
      policy_name    = string
      remote_ip      = string
      ike_proposal   = string
      esp_proposal   = string
      preshared_key  = string
      local_subnets  = list(string)
      remote_subnets = list(string)
      r_timeout      = string
      r_tries        = string
      r_base         = string
  })
  default = {
    policy_name    = null
    remote_ip      = null
    ike_proposal   = "aes128gcm16-prfsha256-ecp256"
    esp_proposal   = "aes128gcm16"
    preshared_key  = null
    local_subnets  = null
    remote_subnets = null
    r_timeout      = "3.0"
    r_tries        = "3"
    r_base         = "1.0"
  }
}
