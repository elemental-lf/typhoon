locals {
  kubelet_env = <<-EOT
  KUBELET_IMAGE_URL=${split(":", var.container_images["kubelet"])[0]}
  KUBELET_IMAGE_TAG=${split(":", var.container_images["kubelet"])[1]}
  EOT
}
