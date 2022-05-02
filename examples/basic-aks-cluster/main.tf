provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-aks-lab"
  location = "eastus"
}

module "network" {
  source              = "git::https://github.com/ohkillsh/killsh-module-network.git"
  vnet_name           = "vnet-aks-lab"
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = "10.10.0.0/16"
  subnet_prefixes     = ["10.10.255.0/24", "10.10.0.0/20", "10.10.254.0/24"]
  subnet_names        = ["subnet-infra", "subnet-aks-pod", "subnet-bastion"]
  depends_on          = [azurerm_resource_group.aks]
}

module "aks" {
  source                           = "git::https://github.com/ohkillsh/killsh-modulo-aks"
  resource_group_name              = azurerm_resource_group.aks.name
  kubernetes_version               = "1.22.6"
  orchestrator_version             = "1.22.6"
  prefix                           = "killsh"
  cluster_name                     = "dev-killsh"
  os_disk_size_gb                  = 50
  enable_role_based_access_control = false
  enable_auto_scaling              = true
  agents_min_count                 = 1
  agents_max_count                 = 3
  agents_count                     = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 110
  agents_pool_name                 = "exnodepool"
  agents_availability_zones        = ["1", "2"]
  agents_type                      = "VirtualMachineScaleSets"

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


## Windows node pool
module "node_pool_win_1" {
  source             = "git::https://github.com/ohkillsh/killsh-module-aks-node-pool.git"
  name               = "win1"
  aks_cluster_id     = module.aks.aks_id
  kubernetes_version = "1.22.6"
  node_subnet_id     = module.network.vnet_subnets[1]
  vm_size            = "Standard_B2s"
  max_pods           = "110"
  os_type            = "Windows"
}

## Linux node pool
module "node_pool_linux_1" {
  source             = "git::https://github.com/ohkillsh/killsh-module-aks-node-pool.git"
  name               = "usrn1"
  aks_cluster_id     = module.aks.aks_id
  kubernetes_version = "1.22.6"
  node_subnet_id     = module.network.vnet_subnets[1]
  vm_size            = "Standard_B2s"
  max_pods           = "110"
  os_type            = "Linux"
}