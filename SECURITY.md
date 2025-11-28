# Security Policy

## 🔒 Reporting Security Vulnerabilities

**DO NOT** create public GitHub issues for security vulnerabilities.

Instead, please report security issues to:
- **Email:** security@zsel.opole.pl
- **Subject:** [SECURITY] Brief description of issue
- **Encryption:** Use GPG key (see below) for sensitive data

### Expected Response Time
- **Critical:** 24 hours
- **High:** 72 hours  
- **Medium:** 1 week
- **Low:** 2 weeks

## 🛡️ Supported Versions

| Version | Supported          | Notes |
| ------- | ------------------ | ----- |
| main    | ✅ Yes             | Active development |
| develop | ✅ Yes             | Pre-production testing |
| < 1.0   | ❌ No              | Legacy, unmaintained |

## 🚨 Security Best Practices

### For Contributors

#### 1. **NO Secrets in Code**
- ❌ Never commit passwords, API keys, tokens
- ✅ Use environment variables
- ✅ Use Azure Key Vault / HashiCorp Vault
- ✅ Use `$env:VARIABLE` in PowerShell
- ✅ Use `os.getenv()` in Python

```powershell
# ❌ BAD
$password = "MySecretPassword123"

# ✅ GOOD
$password = $env:ADMIN_PASSWORD
if (-not $password) {
    throw "ADMIN_PASSWORD environment variable not set"
}
```

#### 2. **Validate All Inputs**
```powershell
# ✅ GOOD - Input validation
param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^[a-zA-Z0-9\-]+$')]
    [string]$Username,
    
    [ValidateRange(1, 65535)]
    [int]$Port = 22
)
```

#### 3. **Use Secure Connections**
```powershell
# ❌ BAD
Invoke-RestMethod -Uri "http://api.example.com"

# ✅ GOOD
Invoke-RestMethod -Uri "https://api.example.com" -UseBasicParsing
```

#### 4. **Sanitize File Paths**
```powershell
# ❌ BAD - Path traversal vulnerability
$filePath = Join-Path $baseDir $userInput

# ✅ GOOD
$filePath = Join-Path $baseDir $userInput
if (-not $filePath.StartsWith($baseDir)) {
    throw "Invalid path: potential traversal attack"
}
```

#### 5. **Principle of Least Privilege**
```routeros
# ✅ GOOD - MikroTik firewall
/ip firewall filter
add chain=input connection-state=established,related action=accept
add chain=input src-address=192.168.255.0/28 protocol=tcp dst-port=22 action=accept
add chain=input action=drop comment="Drop all other input"
```

### For Reviewers

#### PR Security Checklist

- [ ] No hardcoded secrets (passwords, keys, tokens)
- [ ] All user inputs are validated
- [ ] File operations use absolute paths
- [ ] Network connections use TLS/SSL
- [ ] Error messages don't leak sensitive info
- [ ] Logging doesn't contain secrets
- [ ] Dependencies are from trusted sources
- [ ] No SQL injection vulnerabilities
- [ ] No command injection vulnerabilities
- [ ] Authentication/authorization implemented correctly

## 🔐 Common Vulnerabilities

### 1. Command Injection

```powershell
# ❌ DANGEROUS
Invoke-Expression "ping $userInput"

# ✅ SAFE
$allowedHosts = @('192.168.1.1', 'google.com')
if ($userInput -in $allowedHosts) {
    Test-Connection -ComputerName $userInput -Count 1
}
```

### 2. Path Traversal

```python
# ❌ DANGEROUS
file_path = os.path.join(base_dir, user_input)
with open(file_path) as f:
    content = f.read()

# ✅ SAFE
file_path = os.path.realpath(os.path.join(base_dir, user_input))
if not file_path.startswith(os.path.realpath(base_dir)):
    raise ValueError("Invalid path")
with open(file_path) as f:
    content = f.read()
```

### 3. Insecure Deserialization

```python
# ❌ DANGEROUS
import pickle
data = pickle.loads(user_input)

# ✅ SAFE
import json
try:
    data = json.loads(user_input)
except json.JSONDecodeError:
    raise ValueError("Invalid JSON")
```

### 4. Weak Cryptography

```powershell
# ❌ WEAK
$password = "MyPassword" | ConvertTo-SecureString -AsPlainText -Force

# ✅ STRONG
$password = Read-Host -Prompt "Enter password" -AsSecureString
# Or from Azure Key Vault
$secret = Get-AzKeyVaultSecret -VaultName "MyVault" -Name "AdminPassword"
```

## 🔍 Security Tools

### Required Before Commit

1. **Pre-commit hooks** (automatic)
   ```bash
   pip install pre-commit
   pre-commit install
   ```

2. **Secret scanning**
   ```bash
   # GitLeaks
   gitleaks detect --source . --verbose
   
   # TruffleHog
   trufflehog filesystem . --only-verified
   ```

3. **Code analysis**
   ```powershell
   # PowerShell
   Invoke-ScriptAnalyzer -Path . -Recurse -Settings PSGallery
   
   # Python
   bandit -r . -ll
   
   # Terraform
   tfsec .
   checkov -d .
   ```

### CI/CD Automated Checks

All PRs automatically run:
- ✅ Secret scanning (GitLeaks, TruffleHog)
- ✅ Dependency vulnerability scanning
- ✅ Static code analysis (PSScriptAnalyzer, Bandit, TFSec)
- ✅ Syntax validation (YAML, JSON, Terraform)
- ✅ License compliance checking

## 🎯 Security Incidents Response Plan

### Phase 1: Detection (0-1 hour)
1. Security alert received
2. Incident severity assessed
3. Incident response team activated

### Phase 2: Containment (1-4 hours)
1. Affected systems isolated
2. Access credentials rotated
3. Attack vector identified

### Phase 3: Eradication (4-24 hours)
1. Vulnerability patched
2. Malicious artifacts removed
3. Security measures enhanced

### Phase 4: Recovery (24-72 hours)
1. Systems restored from clean state
2. Monitoring intensified
3. Functionality verified

### Phase 5: Post-Incident (1 week)
1. Root cause analysis documented
2. Lessons learned shared
3. Security policies updated

## 📞 Security Contacts

| Role | Contact | Availability |
|------|---------|--------------|
| Security Lead | security@zsel.opole.pl | 24/7 |
| Infrastructure Team | infra@zsel.opole.pl | Business hours |
| DevOps Team | devops@zsel.opole.pl | Business hours |

## 🔑 GPG Public Key

```
-----BEGIN PGP PUBLIC KEY BLOCK-----
[Your organization's GPG public key here]
-----END PGP PUBLIC KEY BLOCK-----
```

Import: `gpg --import security-public-key.asc`

## 📚 Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [Microsoft Security Best Practices](https://docs.microsoft.com/en-us/security/)

---

**Last Updated:** 2025-11-27  
**Version:** 1.0  
**Maintained by:** ZSE-BCU Security Team
