
output "kube_config_raw" {
  value     = module.aks.kube_config_raw
  sensitive = true
}