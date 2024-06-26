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
    calico                  = "quay.io/calico/node:v3.27.3"
    calico_cni              = "quay.io/calico/cni:v3.27.3"
    cilium_agent            = "quay.io/cilium/cilium:v1.15.5"
    cilium_operator         = "quay.io/cilium/operator-generic:v1.15.5"
    coredns                 = "registry.k8s.io/coredns/coredns:v1.9.4"
    flannel                 = "docker.io/flannel/flannel:v0.25.1"
    flannel_cni             = "quay.io/poseidon/flannel-cni:v0.4.4"
    kube_apiserver          = "registry.k8s.io/kube-apiserver:v1.29.5"
    kube_controller_manager = "registry.k8s.io/kube-controller-manager:v1.29.5"
    kube_scheduler          = "registry.k8s.io/kube-scheduler:v1.29.5"
    kube_proxy              = "registry.k8s.io/kube-proxy:v1.29.5"
    kubelet                 = "ghcr.io/elemental-lf/kubelet:v1.29.5"

    keepalived_vip          = "ghcr.io/elemental-lf/docker-keepalived:v2.3.1"
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

variable "enable_kube_proxy" {
  description = "Enable kube-proxy daemon set"
  type        = bool
  default     = true
}

variable "apiserver_cert_dns_names" {
  description = "List of additional DNS names to add to the kube-apiserver TLS certificate"
  type        = list(string)
  default     = []
}

variable "apiserver_cert_ip_addresses" {
  description = "List of additional IP addresses to add to the kube-apiserver TLS certificate"
  type        = list(string)
  default     = []
}

variable "components" {
  description = "Configure pre-installed cluster components"
  type = object({
    enable = optional(bool, true)
    coredns = optional(
      object({
        enable = optional(bool, true)
      }),
      {
        enable = true
      }
    )
    kube_proxy = optional(
      object({
        enable = optional(bool, true)
      }),
      {
        enable = true
      }
    )
    # CNI providers are enabled for pre-install by default, but only the
    # provider matching var.networking is actually installed.
    flannel = optional(
      object({
        enable = optional(bool, true)
      }),
      {
        enable = true
      }
    )
    calico = optional(
      object({
        enable = optional(bool, true)
      }),
      {
        enable = true
      }
    )
    cilium = optional(
      object({
        enable = optional(bool, true)
      }),
      {
        enable = true
      }
    )
  })
  default = {
    enable     = true
    coredns    = null
    kube_proxy = null
    flannel    = null
    calico     = null
    cilium     = null
  }
  # Set the variable value to the default value when the caller
  # sets it to null.
  nullable = false
}
