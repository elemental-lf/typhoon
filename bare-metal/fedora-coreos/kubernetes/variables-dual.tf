# Variables specific to the dual fork

variable "network_encapsulation" {
  description = "Network encapsulation mode ipip, vxlan or never (only applies to calico)"
  type        = string
  default     = "ipip"
}

variable "apiserver_vip" {
  description = "VIP to use for apiserver HA via keepalived"
  type        = string
  default     = ""
}

variable "apiserver_vip_interface" {
  description = "Interface to use for apiserver HA via keepalived"
  type        = string
}

variable "apiserver_vip_vrrp_id" {
  description = "VRRP id to use for apiserver HA via keepalived"
  type        = number
}

variable "etcd_cluster_exists" {
  type        = string
  description = "Wheter it should be assumed that the etcd cluster already exists or not"
  default     = "false"
}

variable "apiserver_extra_arguments" {
  description = "List of extra arguments for the kube-apiserver"
  type        = list(string)
  default     = []
}

variable "container_images" {
  description = "Container images to use"
  type = map(string)

  default = {
    calico      = "quay.io/calico/node:v3.13.1"
    calico_cni  = "quay.io/calico/cni:v3.13.1"
    flannel     = "quay.io/coreos/flannel:v0.12.0-amd64"
    flannel_cni = "quay.io/coreos/flannel-cni:v0.3.0"
    kube_router = "cloudnativelabs/kube-router:v0.3.2"
    kube_apiserver            = "k8s.gcr.io/kube-apiserver:v1.18.1"
    kube_controller_manager   = "k8s.gcr.io/kube-controller-manager:v1.18.1"
    kube_scheduler            = "k8s.gcr.io/kube-scheduler:v1.18.1"
    kube_proxy                = "k8s.gcr.io/kube-proxy:v1.18.1"
    kubelet                   = "quay.io/poseidon/kubelet:v1.18.1"
    coredns     = "k8s.gcr.io/coredns:1.6.7"
    keepalived_vip = "osixia/keepalived:2.0.17"
    tiller         = "gcr.io/kubernetes-helm/tiller:v2.16.1"
  }
}

variable "enable_rbd_nbd" {
  description = "Enable rbd-nbd by blacklisting the KRBD driver inside the kubelet container"
  type        = string
  default     = "false"
}

variable "asset_overrides" {
  description = "User supplied asset overrides and additions"
  type        = map(string)
  default     = {}
}
