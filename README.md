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

---

## 🔒 Security & Code Quality

This repository implements enterprise-grade security with 4-layer defense:

1. **Local**: Pre-commit hooks (30+ checks)
2. **CI/CD**: GitHub Actions (18 jobs)  
3. **Branch**: Protection rules + required reviews
4. **Organization**: Global security policies

**Quick Start:**
```powershell
pip install pre-commit
pre-commit install
```

**Documentation:**
- [SECURITY.md](SECURITY.md) - Security policy
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development workflow
- [SECURITY-SETUP.md](SECURITY-SETUP.md) - Complete setup guide