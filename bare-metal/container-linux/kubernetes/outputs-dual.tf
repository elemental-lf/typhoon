output "helm_ca" {
  value     = module.bootstrap.helm_ca
  sensitive = true
}

output "helm_client_key" {
  value     = module.bootstrap.helm_client_key
  sensitive = true
}

output "helm_client_cert" {
  value     = module.bootstrap.helm_client_cert
  sensitive = true
}
