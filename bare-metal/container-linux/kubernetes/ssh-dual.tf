resource "null_resource" "copy-extra-assets" {
  count = length(var.controllers)

  depends_on = [
    null_resource.copy-controller-secrets,
  ]

  connection {
    type    = "ssh"
    host    = var.controllers.*.domain[count.index]
    user    = "core"
    timeout = "60m"
  }

  provisioner "remote-exec" {
    inline = [
      # This is for the migration scenario from bootkube to bootstrap.
      # Terraform will create this resource because it is missing but due to the fact that the nodes are not
      # reinstalled yet this would fail.
      "[[ -d /opt/bootstrap/assets/extra-assets ]] || exit 0",
      "sudo mkdir -p /etc/kubernetes/extra-assets",
      "sudo cp -r /opt/bootstrap/assets/extra-assets/* /etc/kubernetes/extra-assets/",
      "sudo chmod a+x /etc/kubernetes/extra-assets/apiserver-vip/*.sh",
      "sudo cp /opt/bootstrap/assets/auth/kubeconfig-localhost /etc/kubernetes/bootstrap-secrets/",
    ]
  }
}
