locals {
  remote_kernel = "https://builds.coreos.fedoraproject.org/prod/streams/${var.os_stream}/builds/${var.os_version}/x86_64/fedora-coreos-${var.os_version}-live-kernel-x86_64"
  remote_initrd = "https://builds.coreos.fedoraproject.org/prod/streams/${var.os_stream}/builds/${var.os_version}/x86_64/fedora-coreos-${var.os_version}-live-initramfs.x86_64.img"
  remote_args = [
    "ip=dhcp",
    "rd.neednet=1",
    "initrd=fedora-coreos-${var.os_version}-live-initramfs.x86_64.img",
    "coreos.inst.image_url=https://builds.coreos.fedoraproject.org/prod/streams/${var.os_stream}/builds/${var.os_version}/x86_64/fedora-coreos-${var.os_version}-metal.x86_64.raw.xz",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "console=tty0",
    "console=ttyS0",
  ]

  cached_kernel = "/assets/fedora-coreos/fedora-coreos-${var.os_version}-live-kernel-x86_64"
  cached_initrd = "/assets/fedora-coreos/fedora-coreos-${var.os_version}-live-initramfs.x86_64.img"
  cached_args = [
    "ip=dhcp",
    "rd.neednet=1",
    "initrd=fedora-coreos-${var.os_version}-live-initramfs.x86_64.img",
    "coreos.inst.image_url=${var.matchbox_http_endpoint}/assets/fedora-coreos/fedora-coreos-${var.os_version}-metal.x86_64.raw.xz",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "console=tty0",
    "console=ttyS0",
  ]

  kernel = var.cached_install ? local.cached_kernel : local.remote_kernel
  initrd = var.cached_install ? local.cached_initrd : local.remote_initrd
  args   = concat(var.cached_install ? local.cached_args : local.remote_args, var.accept_insecure_images ? ["coreos.inst.insecure"] : [])
}


// Fedora CoreOS controller profile
resource "matchbox_profile" "controllers" {
  count = length(var.controllers)
  name  = format("%s-controller-%s", var.cluster_name, var.controllers.*.name[count.index])

  kernel = local.kernel
  initrd = [
    local.initrd
  ]
  args = concat(local.args, var.kernel_args, ["coreos.inst.install_dev=${var.controllers[count.index]["install_disk"]}"])

  raw_ignition = data.ct_config.controller-ignitions.*.rendered[count.index]
}

data "ct_config" "controller-ignitions" {
  count = length(var.controllers)

  content  = data.template_file.controller-configs.*.rendered[count.index]
  strict   = true
  snippets = lookup(var.snippets, var.controllers.*.name[count.index], [])
}

data "template_file" "controller-configs" {
  count = length(var.controllers)

  template = file("${path.module}/fcc/controller.yaml")
  vars = {
    domain_name            = var.controllers.*.domain[count.index]
    etcd_name              = var.controllers.*.name[count.index]
    etcd_initial_cluster   = join(",", formatlist("%s=https://%s:2380", var.controllers.*.name, var.controllers.*.domain))
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
    apiserver_vip          = var.apiserver_vip
    etcd_cluster_exists    = var.etcd_cluster_exists
    kubelet_image          = split(":", var.container_images["kubelet"])[0]
    kubelet_tag            = split(":", var.container_images["kubelet"])[1]
    enable_rbd_nbd         = var.enable_rbd_nbd
    node_labels            = join(",", lookup(var.controller_node_labels, var.controllers.*.name[count.index], []))
    node_taints            = join(",", lookup(var.controller_node_taints, var.controllers.*.name[count.index], []))
  }
}

// Fedora CoreOS worker profile
resource "matchbox_profile" "workers" {
  count = length(var.workers)
  name  = format("%s-worker-%s", var.cluster_name, var.workers.*.name[count.index])

  kernel = local.kernel
  initrd = [
    local.initrd
  ]
  args = concat(local.args, var.kernel_args, ["coreos.inst.install_dev=${var.workers[count.index]["install_disk"]}"])

  raw_ignition = data.ct_config.worker-ignitions.*.rendered[count.index]
}

data "ct_config" "worker-ignitions" {
  count = length(var.workers)

  content  = data.template_file.worker-configs.*.rendered[count.index]
  strict   = true
  snippets = lookup(var.snippets, var.workers.*.name[count.index], [])
}

data "template_file" "worker-configs" {
  count = length(var.workers)

  template = file("${path.module}/fcc/worker.yaml")
  vars = {
    domain_name            = var.workers.*.domain[count.index]
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
    kubelet_image          = split(":", var.container_images["kubelet"])[0]
    kubelet_tag            = split(":", var.container_images["kubelet"])[1]
    enable_rbd_nbd         = var.enable_rbd_nbd
    node_labels            = join(",", lookup(var.worker_node_labels, var.workers.*.name[count.index], []))
    node_taints            = join(",", lookup(var.worker_node_taints, var.workers.*.name[count.index], []))
  }
}
