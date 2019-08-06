locals {
  remote_kernel = "https://builds.coreos.fedoraproject.org/prod/streams/${var.os_stream}/builds/${var.os_version}/x86_64/fedora-coreos-${var.os_version}-installer-kernel"
  remote_initrd = "https://builds.coreos.fedoraproject.org/prod/streams/${var.os_stream}/builds/${var.os_version}/x86_64/fedora-coreos-${var.os_version}-installer-initramfs.img"
  remote_args = [
    "ip=dhcp",
    "rd.neednet=1",
    "coreos.inst=yes",
    "coreos.inst.image_url=https://builds.coreos.fedoraproject.org/prod/streams/${var.os_stream}/builds/${var.os_version}/x86_64/fedora-coreos-${var.os_version}-metal.raw.xz",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.inst.install_dev=${var.install_disk}"
  ]

  cached_kernel = "/assets/fedora-coreos/fedora-coreos-${var.os_version}-installer-kernel"
  cached_initrd = "/assets/fedora-coreos/fedora-coreos-${var.os_version}-installer-initramfs.img"
  cached_args = [
    "ip=dhcp",
    "rd.neednet=1",
    "coreos.inst=yes",
    "coreos.inst.image_url=${var.matchbox_http_endpoint}/assets/fedora-coreos/fedora-coreos-${var.os_version}-metal.raw.xz",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.inst.install_dev=${var.install_disk}"
  ]

  kernel = var.cached_install == "true" ? local.cached_kernel : local.remote_kernel
  initrd = var.cached_install == "true" ? local.cached_initrd : local.remote_initrd
  args   = var.cached_install == "true" ? local.cached_args : local.remote_args
}


// Fedora CoreOS controller profile
resource "matchbox_profile" "controllers" {
  count = length(var.controller_names)
  name  = format("%s-controller-%s", var.cluster_name, var.controller_names[count.index])

  kernel = local.kernel
  initrd = [
    local.initrd
  ]
  args = concat(local.args, var.kernel_args)

  raw_ignition = data.ct_config.controller-ignitions.*.rendered[count.index]
}

data "ct_config" "controller-ignitions" {
  count = length(var.controller_names)

  content = data.template_file.controller-configs.*.rendered[count.index]
  strict  = true
}

data "template_file" "controller-configs" {
  count = length(var.controller_names)

  template = file("${path.module}/fcc/controller.yaml")
  vars = {
    domain_name            = var.controller_domains[count.index]
    etcd_name              = var.controller_names[count.index]
    etcd_initial_cluster   = join(",", formatlist("%s=https://%s:2380", var.controller_names, var.controller_domains))
    cluster_dns_service_ip = module.bootkube.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
  }
}

// Fedora CoreOS worker profile
resource "matchbox_profile" "workers" {
  count = length(var.worker_names)
  name  = format("%s-worker-%s", var.cluster_name, var.worker_names[count.index])

  kernel = local.kernel
  initrd = [
    local.initrd
  ]
  args = concat(local.args, var.kernel_args)

  raw_ignition = data.ct_config.worker-ignitions.*.rendered[count.index]
}

data "ct_config" "worker-ignitions" {
  count = length(var.worker_names)

  content = data.template_file.worker-configs.*.rendered[count.index]
  strict  = true
}

data "template_file" "worker-configs" {
  count = length(var.worker_names)

  template = file("${path.module}/fcc/worker.yaml")
  vars = {
    domain_name            = var.worker_domains[count.index]
    cluster_dns_service_ip = module.bootkube.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
  }
}

