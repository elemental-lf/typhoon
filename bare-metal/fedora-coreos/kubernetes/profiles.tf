locals {
  all_nodes = concat(var.controllers[*].name, var.workers[*].name)
  os_streams = {for node in local.all_nodes: node => lookup(var.os_overrides, node, null) != null ? lookup(var.os_overrides, node).os_stream : var.os_stream}
  os_versions = {for node in local.all_nodes: node => lookup(var.os_overrides, node, null) != null ? lookup(var.os_overrides, node).os_version : var.os_version}

  remote_kernel = {for node in local.all_nodes: node => "https://builds.coreos.fedoraproject.org/prod/streams/${local.os_versions[node]}/builds/${local.os_streams[node]}/x86_64/fedora-coreos-${local.os_streams[node]}-live-kernel-x86_64"}
  remote_initrd = {for node in local.all_nodes: node => [
    "--name main https://builds.coreos.fedoraproject.org/prod/streams/${local.os_versions[node]}}/builds/${local.os_streams[node]}/x86_64/fedora-coreos-${local.os_streams[node]}-live-initramfs.x86_64.img"
  ]}

  remote_args = {for node in local.all_nodes: node => concat([
    "initrd=fedora-coreos-${local.os_versions[node]}-live-initramfs.x86_64.img",
    "coreos.live.rootfs_url=https://builds.coreos.fedoraproject.org/prod/streams/${local.os_streams[node]}/builds/${local.os_versions[node]}/x86_64/fedora-coreos-${local.os_versions[node]}-live-rootfs.x86_64.img",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "console=tty0",
    "console=ttyS0",
  ], var.accept_insecure_images ? ["coreos.inst.insecure"] : [])}

  cached_kernel = {for node in local.all_nodes: node => "/assets/fedora-coreos/fedora-coreos-${local.os_versions[node]}-live-kernel-x86_64"}
  cached_initrd = {for node in local.all_nodes: node => [
    "--name main /assets/fedora-coreos/fedora-coreos-${local.os_versions[node]}-live-initramfs.x86_64.img"
  ]}

  cached_args = {for node in local.all_nodes: node => concat([
    "initrd=fedora-coreos-${local.os_versions[node]}-live-initramfs.x86_64.img",
    "coreos.live.rootfs_url=${var.matchbox_http_endpoint}/assets/fedora-coreos/fedora-coreos-${local.os_versions[node]}-live-rootfs.x86_64.img",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "console=tty0",
    "console=ttyS0",
  ], var.accept_insecure_images ? ["coreos.inst.insecure"] : [])}

  kernel = var.cached_install ? local.cached_kernel : local.remote_kernel
  initrd = var.cached_install ? local.cached_initrd : local.remote_initrd
  args   = var.cached_install ? local.cached_args : local.remote_args
}


// Fedora CoreOS controller profile
resource "matchbox_profile" "controllers" {
  count = length(var.controllers)
  name  = format("%s-controller-%s", var.cluster_name, var.controllers.*.name[count.index])

  kernel = local.kernel[var.controllers[count.index].name]
  initrd = local.initrd[var.controllers[count.index].name]
  args = concat(local.args[var.controllers[count.index].name], var.kernel_args, ["coreos.inst.install_dev=${var.controllers[count.index]["install_disk"]}"])

  raw_ignition = data.ct_config.controllers.*.rendered[count.index]
}

# Fedora CoreOS controllers
data "ct_config" "controllers" {
  count = length(var.controllers)
  content = templatefile("${path.module}/butane/controller.yaml", {
    domain_name            = var.controllers.*.domain[count.index]
    etcd_name              = var.controllers.*.name[count.index]
    etcd_initial_cluster   = join(",", formatlist("%s=https://%s:2380", var.controllers.*.name, var.controllers.*.domain))
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
    apiserver_vip                      = var.apiserver_vip
    etcd_cluster_exists                = var.etcd_cluster_exists
    kubelet_image                      = split(":", var.container_images["kubelet"])[0]
    kubelet_tag                        = split(":", var.container_images["kubelet"])[1]
    enable_rbd_nbd                     = var.enable_rbd_nbd
    node_labels                        = join(",", lookup(var.controller_node_labels, var.controllers.*.name[count.index], []))
    node_taints                        = join(",", lookup(var.controller_node_taints, var.controllers.*.name[count.index], []))
    kubelet_controller_extra_arguments = indent(10, join("\n", formatlist("%s \\", var.kubelet_controller_extra_arguments)))
  })
  strict   = true
  snippets = lookup(var.snippets, var.controllers.*.name[count.index], [])
}

// Fedora CoreOS worker profile
resource "matchbox_profile" "workers" {
  count = length(var.workers)
  name  = format("%s-worker-%s", var.cluster_name, var.workers.*.name[count.index])

  kernel = local.kernel[var.workers[count.index].name]
  initrd = local.initrd[var.workers[count.index].name]
  args = concat(local.args[var.workers[count.index].name], var.kernel_args, ["coreos.inst.install_dev=${var.workers[count.index]["install_disk"]}"])

  raw_ignition = data.ct_config.workers.*.rendered[count.index]
}

# Fedora CoreOS workers
data "ct_config" "workers" {
  count = length(var.workers)
  content = templatefile("${path.module}/butane/worker.yaml", {
    domain_name            = var.workers.*.domain[count.index]
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
    kubelet_image                  = split(":", var.container_images["kubelet"])[0]
    kubelet_tag                    = split(":", var.container_images["kubelet"])[1]
    enable_rbd_nbd                 = var.enable_rbd_nbd
    node_labels            = join(",", lookup(var.worker_node_labels, var.workers.*.name[count.index], []))
    node_taints            = join(",", lookup(var.worker_node_taints, var.workers.*.name[count.index], []))
    kubelet_worker_extra_arguments = indent(10, join("\n", formatlist("%s \\", var.kubelet_worker_extra_arguments)))
  })
  strict   = true
  snippets = lookup(var.snippets, var.workers.*.name[count.index], [])
}

