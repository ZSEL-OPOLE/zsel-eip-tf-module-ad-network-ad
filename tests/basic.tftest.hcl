# =============================================================================
# AD Network Module - Basic Tests
# =============================================================================

# Test 1: Basic Samba AD StatefulSet
run "basic_samba_ad" {
  command = plan
  
  variables {
    namespace   = "ad-network"
    ha_replicas = 2
    domain_name = "network-ad.zsel.opole.pl"
    realm       = "NETWORK-AD.ZSEL.OPOLE.PL"
  }
  
  assert {
    condition     = kubernetes_stateful_set.samba_network_ad.metadata[0].name == "samba-network-ad"
    error_message = "StatefulSet name should be samba-network-ad"
  }
  
  assert {
    condition     = kubernetes_stateful_set.samba_network_ad.spec[0].replicas == 2
    error_message = "Should have 2 replicas for HA"
  }
}

# Test 2: Namespace labels
run "namespace_labels" {
  command = plan
  
  variables {
    namespace   = "ad-network"
    ha_replicas = 1
    domain_name = "network-ad.zsel.opole.pl"
    realm       = "NETWORK-AD.ZSEL.OPOLE.PL"
  }
  
  assert {
    condition     = kubernetes_stateful_set.samba_network_ad.metadata[0].labels["tier"] == "core"
    error_message = "Should have tier=core label"
  }
  
  assert {
    condition     = kubernetes_stateful_set.samba_network_ad.metadata[0].labels["domain"] == "network-ad.zsel.opole.pl"
    error_message = "Should have domain label"
  }
}

# Test 3: Single replica mode
run "single_replica" {
  command = plan
  
  variables {
    namespace   = "ad-network"
    ha_replicas = 1
    domain_name = "network-ad.zsel.opole.pl"
    realm       = "NETWORK-AD.ZSEL.OPOLE.PL"
  }
  
  assert {
    condition     = kubernetes_stateful_set.samba_network_ad.spec[0].replicas == 1
    error_message = "Should support single replica"
  }
}

# Test 4: Custom domain name
run "custom_domain" {
  command = plan
  
  variables {
    namespace   = "ad-network"
    ha_replicas = 1
    domain_name = "test.example.com"
    realm       = "TEST.EXAMPLE.COM"
  }
  
  assert {
    condition     = can(regex("test\\.example\\.com", jsonencode(kubernetes_stateful_set.samba_network_ad)))
    error_message = "Should configure custom domain"
  }
}
