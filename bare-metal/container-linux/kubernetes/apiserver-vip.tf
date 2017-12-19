# Adding the VIP to the first controller makes sure that the API server is
# reachable during the bootstrapping process.  It is removed again when
# bootkube finishes.  The VIP is then provided by the kube-apiserver-vip
# DaemonSet.

resource "null_resource" "apiserver-vip-add" {
  count = "${var.apiserver_vip != "" ? 1 : 0}"

  connection {
    type    = "ssh"
    host    = "${element(var.controller_domains, 0)}"
    user    = "core"
    timeout = "30m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ip addr add ${var.apiserver_vip}/32 dev lo"
    ]
  }
}

resource "null_resource" "apiserver-vip-del" {
  count      = "${var.apiserver_vip != "" ? 1 : 0}"
  depends_on = ["null_resource.bootkube-start"]

  connection {
    type    = "ssh"
    host    = "${element(var.controller_domains, 0)}"
    user    = "core"
    timeout = "30m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ip addr del ${var.apiserver_vip}/32 dev lo"
    ]
  }
}
