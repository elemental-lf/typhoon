# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/elemental-lf/terraform-render-bootkube.git?ref=ec9cc6308e0016d4ace372532631a8a784837c2c"

  cluster_name    = "${var.cluster_name}"
  api_servers     = ["${var.k8s_domain_name}"]
  etcd_servers    = ["${var.controller_domains}"]
  asset_dir       = "${var.asset_dir}"
  networking      = "${var.networking}"
  network_mtu     = "${var.network_mtu}"
  pod_cidr        = "${var.pod_cidr}"
  service_cidr    = "${var.service_cidr}"
  flannel_backend = "${var.flannel_backend}"
  flannel_iface   = "${var.flannel_iface}"
}
