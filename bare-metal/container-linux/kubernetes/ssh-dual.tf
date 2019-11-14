resource "null_resource" "copy-extras-assets" {
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
      "sudo mkdir -p /etc/kubernetes/extra-assets",
      "sudo cp -r /opt/bootstrap/assets/extra-assets/* /etc/kubernetes/extra-assets/",
    ]
  }
}
