locals {
  # format assets for distribution
  assets_bundle = [
    # header with the unpack location
    for key, value in merge(module.bootstrap.assets_dist, var.asset_overrides) :
    format("##### %s\n%s", key, value)
  ]
}

# Secure copy assets to controllers. Activates kubelet.service
resource "null_resource" "copy-controller-secrets" {
  count = length(var.controllers)

  # Without depends_on, remote-exec could start and wait for machines before
  # matchbox groups are written, causing a deadlock.
  depends_on = [
    matchbox_group.controller,
    matchbox_group.worker,
    module.bootstrap,
  ]

  # triggers = {
  #  trigger_1 = local.kubelet_env
  #  trigger_2 = module.bootstrap.kubeconfig-kubelet
  #  trigger_3 = join("\n", local.assets_bundle)
  # }

  connection {
    type    = "ssh"
    host    = var.controllers.*.domain[count.index]
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = local.kubelet_env
    destination = "/home/core/kubelet.env"
  }

  provisioner "file" {
    content     = module.bootstrap.kubeconfig-kubelet
    destination = "/home/core/kubeconfig"
  }

  provisioner "file" {
    content     = join("\n", local.assets_bundle)
    destination = "/home/core/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rsync -a $HOME/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo rsync -a $HOME/kubelet.env /etc/kubernetes/kubelet.env",
      "sudo touch /etc/kubernetes",
      "sudo /opt/bootstrap/layout",
    ]
  }
}

# Secure copy kubeconfig to all workers. Activates kubelet.service
resource "null_resource" "copy-worker-secrets" {
  count = length(var.workers)

  # Without depends_on, remote-exec could start and wait for machines before
  # matchbox groups are written, causing a deadlock.
  depends_on = [
    matchbox_group.controller,
    matchbox_group.worker,
  ]

  # triggers = {
  #   trigger_1 = local.kubelet_env
  #   trigger_2 = module.bootstrap.kubeconfig-kubelet
  # }

  connection {
    type    = "ssh"
    host    = var.workers.*.domain[count.index]
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = local.kubelet_env
    destination = "/home/core/kubelet.env"
  }

  provisioner "file" {
    content     = module.bootstrap.kubeconfig-kubelet
    destination = "/home/core/kubeconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rsync -a $HOME/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo rsync -a $HOME/kubelet.env /etc/kubernetes/kubelet.env",
      "sudo touch /etc/kubernetes",
    ]
  }
}

# Connect to a controller to perform one-time cluster bootstrap.
resource "null_resource" "bootstrap" {
  # Without depends_on, this remote-exec may start before the kubeconfig copy.
  # Terraform only does one task at a time, so it would try to bootstrap
  # while no Kubelets are running.
  depends_on = [
    null_resource.copy-controller-secrets,
    null_resource.copy-worker-secrets,
  ]

  triggers = {
    trigger_1 = join("\n", local.assets_bundle)
  }

  connection {
    type    = "ssh"
    host    = var.controllers[0].domain
    user    = "core"
    timeout = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start bootstrap",
    ]
  }
}


