# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "../../../../terraform-render-bootkube"

  cluster_name                    = var.cluster_name
  api_servers                     = [var.k8s_domain_name]
  apiserver_vip                   = var.apiserver_vip
  etcd_servers                    = var.controllers.*.domain
  asset_dir                       = var.asset_dir
  networking                      = var.networking
  network_mtu                     = var.network_mtu
  network_ip_autodetection_method = var.network_ip_autodetection_method
  network_encapsulation           = var.network_encapsulation
  pod_cidr                        = var.pod_cidr
  service_cidr                    = var.service_cidr
  cluster_domain_suffix           = var.cluster_domain_suffix
  apiserver_extra_arguments       = var.apiserver_extra_arguments
  apiserver_extra_secrets         = var.apiserver_extra_secrets
  enable_reporting                = var.enable_reporting
  enable_aggregation              = var.enable_aggregation
  container_images                = var.container_images
}

