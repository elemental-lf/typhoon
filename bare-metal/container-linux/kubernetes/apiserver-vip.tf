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

resource "null_resource" "apiserver-vip-add-permanently" {
  count = "${var.apiserver_vip != "" ? length(var.controller_domains) : 0}"
  depends_on = ["null_resource.bootkube-start"]

  connection {
    type    = "ssh"
    host    = "${element(var.controller_domains, count.index)}"
    user    = "core"
    timeout = "30m"
  }

  provisioner "file" {
    content     = <<EOF
[Match]
Name=lo
[Network]
Address=${var.apiserver_vip}/32
EOF
    destination = "$HOME/10-lo.network"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv 10-lo.network /etc/systemd/network/10-lo.network",
      "sudo systemctl restart systemd-networkd.service"
    ]
  }
}
