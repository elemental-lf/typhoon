# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "../../../../terraform-render-bootstrap"

  cluster_name                    = var.cluster_name
  api_servers                     = [var.k8s_domain_name]
  apiserver_vip                   = var.apiserver_vip
  apiserver_vip_interface         = var.apiserver_vip_interface
  apiserver_vip_vrrp_id           = var.apiserver_vip_vrrp_id
  etcd_servers                    = var.controllers.*.domain
  networking                      = var.install_container_networking ? var.networking : "none"
  network_mtu                     = var.network_mtu
  network_ip_autodetection_method = var.network_ip_autodetection_method
  network_encapsulation           = var.network_encapsulation
  pod_cidr                        = var.pod_cidr
  service_cidr                    = var.service_cidr
  cluster_domain_suffix           = var.cluster_domain_suffix
  apiserver_extra_arguments       = var.apiserver_extra_arguments
  enable_reporting                = var.enable_reporting
  enable_aggregation              = var.enable_aggregation
  container_images                = var.container_images
  apiserver_cert_dns_names        = var.apiserver_cert_dns_names
  apiserver_cert_ip_addresses     = var.apiserver_cert_ip_addresses
  components                      = var.components
}


