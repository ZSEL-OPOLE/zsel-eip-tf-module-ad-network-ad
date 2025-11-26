# =========================================================
# Network AD Module - Variables
# =========================================================

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "core-auth"
}

variable "ha_replicas" {
  description = "Number of AD DC replicas"
  type        = number
  default     = 2
}

variable "samba_image" {
  description = "Samba AD DC image"
  type        = string
  default     = "nowsci/samba-domain:latest"
}

variable "realm" {
  description = "Kerberos realm"
  type        = string
  default     = "NETWORK-AD.ZSEL.OPOLE.PL"
}

variable "domain_netbios" {
  description = "NetBIOS domain"
  type        = string
  default     = "ZSELNET"
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "radius_password" {
  description = "RADIUS bind password"
  type        = string
  sensitive   = true
}

variable "snmp_password" {
  description = "SNMP service account password"
  type        = string
  sensitive   = true
}

variable "prometheus_password" {
  description = "Prometheus bind password"
  type        = string
  sensitive   = true
}

variable "storage_class" {
  description = "Storage class"
  type        = string
  default     = "longhorn"
}

variable "storage_size" {
  description = "Storage size per replica"
  type        = string
  default     = "30Gi"
}

variable "loadbalancer_ip" {
  description = "MetalLB IP for Network AD"
  type        = string
  default     = "192.168.255.51"
}

variable "mikrotik_devices" {
  description = "List of MikroTik devices to create computer objects"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}
