# =========================================================
# Active Directory - Network Domain Module
# Domain: network-ad.zsel.opole.pl (57 MikroTik devices)
# =========================================================
# Cel: Samba AD DC dla autentykacji urządzeń sieciowych (RADIUS/SNMP)
# Ostatnia aktualizacja: 2025-11-25
# =========================================================

terraform {
  required_version = ">= 1.6"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
  }
}

# =========================================================
# StatefulSet - Samba Network AD DC
# =========================================================

resource "kubernetes_stateful_set" "samba_network_ad" {
  metadata {
    name      = "samba-network-ad"
    namespace = var.namespace
    
    labels = {
      app        = "samba-network-ad"
      domain     = "network-ad.zsel.opole.pl"
      tier       = "core"
      managed-by = "terraform"
    }
  }
  
  spec {
    service_name = "samba-network-ad"
    replicas     = var.ha_replicas
    
    selector {
      match_labels = {
        app = "samba-network-ad"
      }
    }
    
    template {
      metadata {
        labels = {
          app    = "samba-network-ad"
          domain = "network-ad.zsel.opole.pl"
        }
      }
      
      spec {
        security_context {
          fs_group    = 0
          run_as_user = 0
        }
        
        # ==================== INIT - Domain Provisioning ====================
        init_container {
          name  = "provision-network-domain"
          image = var.samba_image
          
          command = ["/bin/bash", "-c"]
          args = [
            <<-EOT
              set -e
              if [ ! -f /var/lib/samba/private/sam.ldb ]; then
                echo "Provisioning Network AD domain..."
                samba-tool domain provision \
                  --realm=${var.realm} \
                  --domain=${var.domain_netbios} \
                  --adminpass='${var.admin_password}' \
                  --server-role=dc \
                  --dns-backend=SAMBA_INTERNAL \
                  --use-rfc2307 \
                  --function-level=2008_R2
                
                echo "Creating OUs for network devices..."
                samba-tool ou create "OU=NetworkDevices,DC=network-ad,DC=zsel,DC=opole,DC=pl"
                samba-tool ou create "OU=NetworkAdmins,DC=network-ad,DC=zsel,DC=opole,DC=pl"
                samba-tool ou create "OU=ServiceAccounts,DC=network-ad,DC=zsel,DC=opole,DC=pl"
                
                echo "Creating service accounts for network services..."
                samba-tool user create radius '${var.radius_password}' \
                  --ou="OU=ServiceAccounts,DC=network-ad,DC=zsel,DC=opole,DC=pl"
                samba-tool user create snmp '${var.snmp_password}' \
                  --ou="OU=ServiceAccounts,DC=network-ad,DC=zsel,DC=opole,DC=pl"
                samba-tool user create prometheus '${var.prometheus_password}' \
                  --ou="OU=ServiceAccounts,DC=network-ad,DC=zsel,DC=opole,DC=pl"
                
                echo "Creating computer objects for MikroTik devices..."
                ${join("\n", [for device in var.mikrotik_devices : 
                  "samba-tool computer create ${device.name} --ou='OU=NetworkDevices,DC=network-ad,DC=zsel,DC=opole,DC=pl'"
                ])}
                
                echo "Creating network admin groups..."
                samba-tool group add NetworkAdmins
                samba-tool group add MikroTikAdmins
                samba-tool group add MonitoringUsers
                
                echo "Network domain provisioning complete!"
              else
                echo "Network domain already provisioned."
              fi
            EOT
          ]
          
          volume_mount {
            name       = "samba-data"
            mount_path = "/var/lib/samba"
          }
          
          volume_mount {
            name       = "samba-config"
            mount_path = "/etc/samba/smb.conf"
            sub_path   = "smb.conf"
          }
        }
        
        # ==================== MAIN CONTAINER ====================
        container {
          name  = "samba"
          image = var.samba_image
          
          command = ["/bin/bash", "-c"]
          args    = ["samba --foreground --no-process-group"]
          
          port {
            name           = "ldap"
            container_port = 389
          }
          
          port {
            name           = "ldaps"
            container_port = 636
          }
          
          port {
            name           = "kerberos"
            container_port = 88
          }
          
          port {
            name           = "dns"
            container_port = 53
          }
          
          volume_mount {
            name       = "samba-data"
            mount_path = "/var/lib/samba"
          }
          
          volume_mount {
            name       = "samba-config"
            mount_path = "/etc/samba/smb.conf"
            sub_path   = "smb.conf"
          }
          
          resources {
            requests = {
              cpu    = "1"
              memory = "2Gi"
            }
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
          }
          
          liveness_probe {
            exec {
              command = ["/bin/bash", "-c", "smbclient -L localhost -N"]
            }
            initial_delay_seconds = 60
            period_seconds        = 30
          }
          
          readiness_probe {
            exec {
              command = ["/bin/bash", "-c", "wbinfo -p"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
        
        volume {
          name = "samba-config"
          
          config_map {
            name = kubernetes_config_map.samba_network_config.metadata[0].name
          }
        }
      }
    }
    
    volume_claim_template {
      metadata {
        name = "samba-data"
      }
      
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.storage_class
        
        resources {
          requests = {
            storage = var.storage_size
          }
        }
      }
    }
  }
}

# =========================================================
# ConfigMap - Samba Network AD Configuration
# =========================================================

resource "kubernetes_config_map" "samba_network_config" {
  metadata {
    name      = "samba-network-ad-config"
    namespace = var.namespace
  }
  
  data = {
    "smb.conf" = <<-EOT
      [global]
        realm = ${var.realm}
        workgroup = ${var.domain_netbios}
        netbios name = ZSEL-NET-AD
        server role = active directory domain controller
        dns forwarder = 8.8.8.8
        ldap server require strong auth = no
        server signing = mandatory
        log level = 1
        
      [netlogon]
        path = /var/lib/samba/sysvol/${var.realm}/scripts
        read only = No
        
      [sysvol]
        path = /var/lib/samba/sysvol
        read only = No
    EOT
  }
}

# =========================================================
# Service - LoadBalancer (MetalLB)
# =========================================================

resource "kubernetes_service" "samba_network_ad" {
  metadata {
    name      = "samba-network-ad"
    namespace = var.namespace
    
    annotations = {
      "metallb.universe.tf/allow-shared-ip" = "samba-network-ad"
    }
  }
  
  spec {
    type             = "LoadBalancer"
    load_balancer_ip = var.loadbalancer_ip
    
    selector = {
      app = "samba-network-ad"
    }
    
    port {
      name = "ldap"
      port = 389
    }
    
    port {
      name = "ldaps"
      port = 636
    }
    
    port {
      name = "kerberos"
      port = 88
    }
    
    port {
      name = "dns"
      port = 53
    }
  }
}
