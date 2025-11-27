# Contributing to ZSEL-EIP Infrastructure

Thank you for contributing! This document provides guidelines to ensure high-quality, secure contributions.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Security Guidelines](#security-guidelines)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Commit Message Convention](#commit-message-convention)

## 🤝 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other contributors

## 🚀 Getting Started

### Prerequisites

```powershell
# Required tools
winget install Git.Git
winget install Microsoft.PowerShell
winget install Python.Python.3.11
winget install Hashicorp.Terraform
winget install WinBox

# Development dependencies
pip install pre-commit pytest black flake8 bandit
Install-Module -Name PSScriptAnalyzer -Force
Install-Module -Name Pester -Force
```

### Setup Development Environment

```bash
# 1. Fork the repository
# 2. Clone your fork
git clone https://github.com/YOUR-USERNAME/zsel-eip-infra.git
cd zsel-eip-infra

# 3. Add upstream remote
git remote add upstream https://github.com/ZSEL-OPOLE/zsel-eip-infra.git

# 4. Install pre-commit hooks
pip install pre-commit
pre-commit install
pre-commit install --hook-type commit-msg

# 5. Create feature branch
git checkout -b feature/my-awesome-feature
```

## 🔄 Development Workflow

### Branching Strategy

```
main (production)
  ├── develop (pre-production)
      ├── feature/network-automation
      ├── feature/k8s-deployment
      ├── fix/dhcp-pool-issue
      └── docs/update-readme
```

**Branch Naming:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions
- `ci/` - CI/CD changes

### Sync with Upstream

```bash
# Update your local main
git checkout main
git fetch upstream
git merge upstream/main

# Update your feature branch
git checkout feature/my-feature
git rebase main
```

## 📝 Code Standards

### PowerShell

```powershell
# ✅ GOOD - Follow these rules:

# 1. Use Verb-Noun naming
function Get-NetworkTopology { }

# 2. Use approved verbs
Get-Verb | Where-Object { $_.Verb -eq 'Start' }

# 3. Parameter validation
function Deploy-K3sCluster {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateRange(1, 9)]
        [int]$NodeCount,
        
        [ValidateSet('Development', 'Production')]
        [string]$Environment = 'Development'
    )
}

# 4. Error handling
try {
    Invoke-DangerousOperation
}
catch {
    Write-Error "Operation failed: $_"
    throw
}

# 5. Documentation
<#
.SYNOPSIS
    Brief description
.DESCRIPTION
    Detailed description
.PARAMETER NodeCount
    Number of nodes to deploy
.EXAMPLE
    Deploy-K3sCluster -NodeCount 3
.NOTES
    Author: Your Name
    Version: 1.0
#>
```

### Python

```python
# ✅ GOOD - Follow PEP 8:

"""Module docstring describing purpose."""

from typing import List, Optional
import os


class NetworkValidator:
    """Validates network topology configuration.
    
    Attributes:
        switches: List of switch configurations
        vlans: VLAN assignments
    """
    
    def __init__(self, switches: List[dict]) -> None:
        """Initialize validator with switch list.
        
        Args:
            switches: List of switch configuration dicts
            
        Raises:
            ValueError: If switches list is empty
        """
        if not switches:
            raise ValueError("Switches list cannot be empty")
        self.switches = switches
    
    def validate_topology(self) -> bool:
        """Validate network topology against expected schema.
        
        Returns:
            True if topology is valid, False otherwise
        """
        # Implementation
        pass


def calculate_subnet(ip: str, prefix: int) -> Optional[str]:
    """Calculate subnet from IP and prefix.
    
    Args:
        ip: IP address string (e.g., '192.168.1.1')
        prefix: Subnet prefix length (e.g., 24)
        
    Returns:
        Subnet string in CIDR notation, or None if invalid
        
    Example:
        >>> calculate_subnet('192.168.1.1', 24)
        '192.168.1.0/24'
    """
    # Implementation
    pass
```

### Terraform

```hcl
# ✅ GOOD - Follow HashiCorp style:

# 1. Resource naming: <resource_type>_<descriptive_name>
resource "mikrotik_interface_vlan" "k3s_cluster" {
  name      = "vlan-110"
  vlan_id   = 110
  interface = mikrotik_interface_bridge.main.name
  
  comment = "K3s Cluster VLAN"
}

# 2. Use variables for reusable values
variable "management_vlan_id" {
  type        = number
  description = "VLAN ID for management network"
  default     = 600
  
  validation {
    condition     = var.management_vlan_id > 0 && var.management_vlan_id < 4096
    error_message = "VLAN ID must be between 1 and 4095"
  }
}

# 3. Output important values
output "core_switch_ip" {
  value       = mikrotik_ip_address.core_mgmt.address
  description = "Management IP of core switch"
}

# 4. Use locals for computed values
locals {
  k3s_subnet    = "192.168.10.0/24"
  mgmt_subnet   = "192.168.255.0/28"
  vlans         = {
    k3s        = 110
    management = 600
  }
}

# 5. Document with comments
# This firewall rule allows SSH access from management VLAN only
resource "mikrotik_firewall_filter" "allow_ssh" {
  # ...
}
```

### Markdown

```markdown
<!-- ✅ GOOD - Follow these rules: -->

# Main Title (H1 - only one per document)

Brief introduction paragraph.

## Section (H2)

### Subsection (H3)

- Use **bold** for emphasis
- Use `code` for inline code/commands
- Use proper code blocks with language

​```powershell
# PowerShell example
Get-Process | Where-Object { $_.CPU -gt 100 }
​```

**Tables:**

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |

**Links:**
- [Descriptive text](https://example.com)
- Internal: [See Section](#section)

**Images:**
![Alt text](path/to/image.png)
```

## 🔒 Security Guidelines

### 1. **Never Commit Secrets**

```powershell
# ❌ BAD
$apiKey = "sk-1234567890abcdef"
$password = "MyPassword123"

# ✅ GOOD
$apiKey = $env:API_KEY
if (-not $apiKey) {
    throw "API_KEY environment variable not set"
}

$password = Get-AzKeyVaultSecret -VaultName "MyVault" -Name "AdminPassword"
```

### 2. **Validate All Inputs**

```powershell
# ✅ GOOD
param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^[a-zA-Z0-9\-]+$')]
    [string]$SwitchName,
    
    [ValidateScript({Test-Path $_})]
    [string]$ConfigFile
)
```

### 3. **Use Principle of Least Privilege**

```routeros
# ✅ GOOD - Restrictive firewall
/ip firewall filter
add chain=input connection-state=established,related action=accept
add chain=input src-address=192.168.255.0/28 dst-port=22 action=accept
add chain=input action=drop comment="Drop all other traffic"
```

### 4. **Sanitize File Paths**

```python
# ✅ GOOD
import os

def safe_read_file(base_dir: str, filename: str) -> str:
    """Safely read file preventing path traversal."""
    file_path = os.path.realpath(os.path.join(base_dir, filename))
    
    if not file_path.startswith(os.path.realpath(base_dir)):
        raise ValueError(f"Invalid path: {filename}")
    
    with open(file_path, 'r') as f:
        return f.read()
```

## 🧪 Testing Requirements

### PowerShell Tests (Pester)

```powershell
# tests/Network.Tests.ps1

Describe "Network Topology Validation" {
    Context "When checking switch connectivity" {
        It "Should connect to all 5 switches" {
            $switches = @('192.168.255.1', '192.168.255.11', '192.168.255.12', 
                          '192.168.255.13', '192.168.255.14')
            
            foreach ($switch in $switches) {
                Test-Connection -ComputerName $switch -Count 1 -Quiet | Should -Be $true
            }
        }
    }
    
    Context "When validating VLAN configuration" {
        It "Should have VLAN 110 and 600 configured" {
            # Test implementation
        }
    }
}
```

### Python Tests (pytest)

```python
# tests/test_topology.py

import pytest
from network_validator import NetworkValidator


def test_validator_initialization():
    """Test validator initializes with valid data."""
    switches = [{'name': 'CORE-01', 'ip': '192.168.255.1'}]
    validator = NetworkValidator(switches)
    assert validator.switches == switches


def test_validator_rejects_empty_list():
    """Test validator rejects empty switch list."""
    with pytest.raises(ValueError, match="Switches list cannot be empty"):
        NetworkValidator([])


@pytest.mark.parametrize("ip,prefix,expected", [
    ("192.168.1.1", 24, "192.168.1.0/24"),
    ("10.0.0.1", 8, "10.0.0.0/8"),
    ("172.16.0.1", 16, "172.16.0.0/16"),
])
def test_subnet_calculation(ip, prefix, expected):
    """Test subnet calculation with various inputs."""
    result = calculate_subnet(ip, prefix)
    assert result == expected
```

### Run Tests

```bash
# PowerShell tests
Invoke-Pester -Path tests/ -OutputFormat NUnitXml -OutputFile test-results.xml

# Python tests
pytest tests/ --cov=. --cov-report=html

# All pre-commit checks
pre-commit run --all-files
```

## 🔍 Pull Request Process

### 1. Before Creating PR

```bash
# Ensure tests pass
pre-commit run --all-files
Invoke-Pester -Path tests/
pytest tests/

# Update documentation
# Update CHANGELOG.md
# Rebase on latest main
git fetch upstream
git rebase upstream/main
```

### 2. PR Title Convention

```
<type>(<scope>): <description>

Examples:
feat(network): add LLDP topology verification
fix(dhcp): correct IP pool range for K3s cluster
docs(readme): update installation instructions
refactor(scripts): improve error handling in deployment script
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting (no code change)
- `refactor` - Code refactoring
- `perf` - Performance improvement
- `test` - Adding tests
- `build` - Build system changes
- `ci` - CI/CD changes
- `chore` - Maintenance tasks
- `revert` - Revert previous commit

### 3. PR Description Template

```markdown
## Description
Brief description of changes

## Changes
- Change 1
- Change 2
- Change 3

## Testing
- [ ] All tests pass locally
- [ ] Pre-commit hooks pass
- [ ] Manual testing completed

Describe testing performed:
...

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] No hardcoded secrets

## Related Issues
Closes #123
Relates to #456
```

### 4. Review Process

1. **Automated checks** run (security, quality, tests)
2. **Code owner** automatically assigned as reviewer
3. **At least 1 approval** required (free tier limitation)
4. **All conversations resolved**
5. **Merge** when approved

### 5. After Merge

```bash
# Update your local repository
git checkout main
git pull upstream main

# Delete feature branch
git branch -d feature/my-feature
git push origin --delete feature/my-feature
```

## 📝 Commit Message Convention

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Examples

```
feat(network): add automated topology verification

Implements PowerShell script to validate network topology using LLDP.
Includes connectivity checks, port mapping validation, and HTML reporting.

Closes #42
```

```
fix(dhcp): correct K3s cluster IP pool range

Changed DHCP pool from 192.168.10.200-250 to 192.168.10.200-220
to avoid conflicts with static assignments.

Fixes #58
```

```
docs(readme): add quick start guide for topology verification

Added QUICKSTART-TOPOLOGY-CHECK.md with step-by-step instructions
for network verification automation.
```

### Rules

- **Subject line:**
  - Max 72 characters
  - Lowercase (except proper nouns)
  - No period at end
  - Imperative mood ("add" not "added")

- **Body:**
  - Wrap at 72 characters
  - Explain WHAT and WHY, not HOW
  - Separate from subject with blank line

- **Footer:**
  - Reference issues: `Closes #123`, `Fixes #456`, `Relates to #789`
  - Breaking changes: `BREAKING CHANGE: description`

## 🏆 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Invited to join ZSEL-OPOLE organization (after 3+ quality PRs)

## 📞 Getting Help

- **Questions:** Create [Discussion](https://github.com/ZSEL-OPOLE/zsel-eip-infra/discussions)
- **Bugs:** Create [Issue](https://github.com/ZSEL-OPOLE/zsel-eip-infra/issues)
- **Security:** Email security@zsel.opole.pl (see SECURITY.md)

## 📚 Additional Resources

- [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)
- [PEP 8 Style Guide](https://pep8.org/)
- [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**Thank you for contributing to ZSEL-EIP Infrastructure!** 🎉
