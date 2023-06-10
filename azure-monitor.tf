
resource "azurerm_monitor_diagnostic_setting" "aks_cluster" {
  count                      = var.enable_log_analytics_workspace ? 1 : 0
  name                       = "${azurerm_kubernetes_cluster.main.name}-audit"
  target_resource_id         = azurerm_kubernetes_cluster.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id

  enabled_log {
    category = "kube-apiserver"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "kube-controller-manager"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "cluster-autoscaler"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "kube-scheduler"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "kube-audit"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "kube-audit-admin"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "cloud-controller-manager"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "guard"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "csi-azuredisk-controller"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "csi-azurefile-controller"

    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "csi-snapshot-controller"

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
