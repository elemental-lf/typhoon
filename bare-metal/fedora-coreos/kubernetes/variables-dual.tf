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

variable "kubelet_controller_extra_arguments" {
  description = "List of extra arguments for the kubelet on controller nodes"
  type        = list(string)
  default     = []
}

variable "kubelet_worker_extra_arguments" {
  description = "List of extra arguments for the kubelet on worker nodes"
  type        = list(string)
  default     = []
}

variable "container_images" {
  description               = "Container images to use"
  type                      = map(string)

  default = {
    calico                  = "quay.io/calico/node:v3.20.0"
    calico_cni              = "quay.io/calico/cni:v3.20.0"
    cilium_agent            = "quay.io/cilium/cilium:v1.10.3"
    cilium_operator         = "quay.io/cilium/operator-generic:v1.10.3"
    coredns                 = "k8s.gcr.io/coredns/coredns:v1.8.4"
    flannel                 = "quay.io/coreos/flannel:v0.13.0"
    flannel_cni             = "quay.io/poseidon/flannel-cni:v0.4.2"
    kube_apiserver          = "k8s.gcr.io/kube-apiserver:v1.22.1"
    kube_controller_manager = "k8s.gcr.io/kube-controller-manager:v1.22.1"
    kube_scheduler          = "k8s.gcr.io/kube-scheduler:v1.22.1"
    kube_proxy              = "k8s.gcr.io/kube-proxy:v1.22.1"
    #
    kubelet                 = "ghcr.io/elemental-lf/kubelet:v1.22.2"
    keepalived_vip          = "osixia/keepalived:2.0.17"
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

variable "accept_insecure_images" {
  description = "Disable image signature checking"
  type        = bool
  default     = false
}

variable "os_overrides" {
  description = "Fedora CoreOS version overrides for individual hosts"
  type        = map(object({
    os_stream = string
    os_version = string
  }))
  default     = {}
}
