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

variable "container_images" {
  description = "Container images to use"
  type = map(string)

  default = {
    calico = "quay.io/calico/node:v3.9.2"
    calico_cni = "quay.io/calico/cni:v3.9.2"
    flannel = "quay.io/coreos/flannel:v0.11.0-amd64"
    flannel_cni = "quay.io/coreos/flannel-cni:v0.3.0"
    kube_router = "cloudnativelabs/kube-router:v0.3.1"
    hyperkube = "k8s.gcr.io/hyperkube:v1.15.5"
    coredns = "k8s.gcr.io/coredns:1.6.2"
    pod_checkpointer = "quay.io/coreos/pod-checkpointer:83e25e5968391b9eb342042c435d1b3eeddb2be1"
    keepalived_vip   = "osixia/keepalived:2.0.17"
    tiller           = "gcr.io/kubernetes-helm/tiller:v2.14.3"
    kubelet          = "k8s.gcr.io/hyperkube:v1.15.5"
  }
}

variable "enable_rbd_nbd" {
  description = "Enable rbd-nbd by blacklisting the KRBD driver inside the kubelet container"
  type        = "string"
  default     = "false"
}
