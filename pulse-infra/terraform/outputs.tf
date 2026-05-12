output "managedidentity_id" {
  value = module.managedidentity.principal_id
}

output "aks_clientid" {
  value = module.aks_cluster.kubelet_identity.clientId
}