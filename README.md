# Terraform Module: zsel-eip-tf-module-ad-network-ad

Provider: `terraform-routeros/routeros` v1.92.1

## Description

Active Directory for network devices (57 MikroTik)

## Usage

```hcl
module "network-ad" {
  source = "github.com/ZSEL-OPOLE/=v0.1.0"
  
  # Variables
  mikrotik_host     = "https://192.168.88.1"
  mikrotik_username = "admin"
  mikrotik_password = var.mikrotik_password
}
```

## Inputs

See `variables.tf` for all available inputs.

## Outputs

See `outputs.tf` for all available outputs.

## Requirements

- Terraform >= 1.5
- Provider: terraform-routeros/routeros >= 1.92

## Testing

```bash
terraform init
terraform test
```

## Versioning

This module follows [Semantic Versioning](https://semver.org/):
- `v0.x.x` - Initial development
- `v1.x.x` - Stable releases
- `v2.x.x` - Breaking changes

## License

MIT

## Authors

ZSEL Opole IT Team
