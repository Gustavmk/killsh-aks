provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "aks-resource-group2"
  location = "eastus"
}

module "network" {
  source              = "git@github.com:ohkillsh/killsh-module-network.git"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = "10.10.0.0/16"
  subnet_prefixes     = ["10.10.255.0/24", "10.10.0.0/20", "10.10.254.0/24"]
  subnet_names        = ["subnet-infra", "subnet-aks-pod", "subnet-bastion"]
  depends_on          = [azurerm_resource_group.example]
}

module "aks" {
  source               = "github.com/Gustavmk/killsh-modulo-aks"
  resource_group_name  = azurerm_resource_group.example.name
  kubernetes_version   = "1.22.6"
  orchestrator_version = "1.22.6"
  prefix               = "killsh"
  cluster_name         = "dev-killsh"

  os_disk_size_gb = 50
  #sku_tier                         = "Standard" # defaults to Free
  #private_cluster_enabled          = true  # default value
  enable_role_based_access_control = false

  /* TODO - Fix addons
  enable_ingress_application_gateway = false
  enable_http_application_routing    = false
  enable_azure_policy                = false
  enable_host_encryption             = false
  */

  enable_auto_scaling       = true
  agents_min_count          = 1
  agents_max_count          = 3
  agents_count              = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods           = 110
  agents_pool_name          = "exnodepool"
  agents_availability_zones = ["1", "2"]
  agents_type               = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  vnet_subnet_id                 = module.network.vnet_subnets[1] # POD network address
  network_plugin                 = "azure"
  net_profile_dns_service_ip     = "10.10.16.10"   # IP address of DNS service and should be the .10 of service CIDR
  net_profile_service_cidr       = "10.10.16.0/20" # A CIDR notation IP range from which to assign service cluster IPs.
  net_profile_docker_bridge_cidr = "10.10.32.0/20" # lets the AKS nodes communicate with the underlying management platform


  log_retention_in_days = 31

  depends_on = [module.network]
}
