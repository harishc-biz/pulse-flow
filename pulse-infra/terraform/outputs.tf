
output "aks_clientid" {
  value = module.aks_cluster.kubelet_identity.clientId
}

output "aks_managed_identity" {
  value = module.aks_cluster.key_vault_secrets_provider_identity[*]
}
