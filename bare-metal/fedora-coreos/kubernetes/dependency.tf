variable "dependencies" {
  type = list(string)
  default = []
}

resource "null_resource" "external_dependencies" {
  triggers = {
    dependencies = "${join(",", var.dependencies)}"
  }
}

