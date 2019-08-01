# Variables specific to the dual fork

variable "network_encapsulation" {
  description = "Network encapsulation mode ipip, vxlan or never (only applies to calico)"
  type        = "string"
  default     = "ipip"
}

variable "apiserver_vip" {
  description = "VIP to use for apiserver HA via keepalived"
  type        = "string"
  default     = ""
}

variable "controller_install_disks" {
  type        = "list"
  description = "Controller install disks"
  default     = []
}

variable "worker_install_disks" {
  type        = "list"
  description = "Worker install disks"
  default     = []
}

variable "etcd_cluster_exists" {
  type        = "string"
  description = "Wheter it should be assumed that the etcd cluster already exists or not"
  default     = "false"
}

variable "apiserver_extra_arguments" {
  description = "List of extra arguments for the kube-apiserver"
  type        = "list"
  default     = []
}

variable "apiserver_extra_secrets" {
  description = "Map of extra data to insert into the kube-apiserver Secrets (values must be BASE64 encoded)"
  type        = "map"
  default     = {}
}
