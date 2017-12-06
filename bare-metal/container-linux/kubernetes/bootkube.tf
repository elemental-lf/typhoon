# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/elemental-lf/terraform-render-bootkube.git?ref=fe506780202041f93269bcb4fc08af8627b087c2"

  cluster_name          = "${var.cluster_name}"
  api_servers           = ["${var.k8s_domain_name}"]
  etcd_servers          = ["${var.controller_domains}"]
  asset_dir             = "${var.asset_dir}"
  networking            = "${var.networking}"
  network_mtu           = "${var.network_mtu}"
  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
}
