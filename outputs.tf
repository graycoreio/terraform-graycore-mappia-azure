output "ip_address" {
  value = module.mappia_aks.public_ip_address
}

output "full_qualified_domain_name" {
  value = module.mappia_aks.fqdn
}

output "kube_config_host" {
  value     = module.mappia_aks.kube_config_host
  sensitive = true
}

output "kube_config_client_cert" {
  value     = module.mappia_aks.kube_config_client_cert
  sensitive = true
}

output "kube_config_client_key" {
  value     = module.mappia_aks.kube_config_client_key
  sensitive = true
}

output "kube_config_ca_cert" {
  value     = module.mappia_aks.kube_config_ca_cert
  sensitive = true
}
