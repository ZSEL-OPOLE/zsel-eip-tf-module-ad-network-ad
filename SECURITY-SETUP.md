# 🔐 GitHub Organization Security Setup Guide

**Maksymalne zabezpieczenia w FREE tier GitHub Organization**

---

## 📋 Wymagania Wstępne

- GitHub Organization (darmowy tier)
- Uprawnienia Owner w organizacji
- GitHub Teams (opcjonalne, ale zalecane)

---

## 🚀 Quick Setup (10 minut)

### 1. Zainstaluj Pre-commit Hooks Lokalnie

```powershell
# Windows (PowerShell)
pip install pre-commit
cd C:\Users\kolod\Desktop\LKP\05_BCU\INFRA\zsel-eip-infra
pre-commit install
pre-commit install --hook-type commit-msg

# Test
pre-commit run --all-files
```

### 2. Skonfiguruj Repository Settings

**Settings → General:**
- ✅ Disable "Allow merge commits" (force squash/rebase)
- ✅ Enable "Automatically delete head branches"
- ✅ Enable "Allow auto-merge"

**Settings → Branches → Add rule for `main`:**
```
Branch name pattern: main

Require a pull request before merging
  ✅ Require approvals: 1
  ✅ Dismiss stale PR approvals when new commits are pushed
  ✅ Require review from Code Owners

Require status checks to pass before merging
  ✅ Require branches to be up to date before merging
  ✅ Status checks that are required:
      - secret-scanning
      - powershell-security
      - python-security  
      - terraform-security
      - pr-validation

✅ Require conversation resolution before merging
✅ Require linear history
✅ Do not allow bypassing the above settings
```

### 3. Enable Security Features

**Settings → Code security and analysis:**
- ✅ Dependency graph (automatic)
- ✅ Dependabot alerts
- ✅ Dependabot security updates
- ✅ Secret scanning (if available in free tier)
- ✅ Push protection (if available)

### 4. Commit i Push Plików

```powershell
cd C:\Users\kolod\Desktop\LKP\05_BCU\INFRA\zsel-eip-infra

git add .
git commit -m "feat(security): add comprehensive security and quality framework"
git push origin main
```

---

## 🔐 Organizacja GitHub - Ustawienia

### Organization Settings

**Settings → Member privileges:**
```
Base permissions: Read
✅ Allow members to create repositories: No
✅ Allow members to delete or transfer repositories: No
✅ Allow members to change repository visibilities: No
```

**Settings → Actions → General:**
```
✅ Allow all actions and reusable workflows
✅ Allow GitHub Actions to create and approve pull requests: No

Artifact and log retention: 90 days
Fork pull request workflows: Require approval for first-time contributors
```

**Settings → Code security and analysis:**
```
✅ Dependency graph: Enable for all repositories
✅ Dependabot alerts: Enable for all repositories  
✅ Dependabot security updates: Enable for all repositories
✅ Secret scanning: Enable for all repositories
```

---

## 👥 Teams Setup (Zalecane)

### Utwórz Teams

```
@ZSEL-OPOLE/infrastructure-team (Owner privileges)
  └─ Role: Maintain
  └─ Members: Core infrastructure team

@ZSEL-OPOLE/network-team
  └─ Role: Write
  └─ Repositories: All network-related
  
@ZSEL-OPOLE/devops-team
  └─ Role: Write
  └─ Repositories: CI/CD and automation

@ZSEL-OPOLE/security-team
  └─ Role: Admin
  └─ Repositories: Security-sensitive repos
  
@ZSEL-OPOLE/documentation-team
  └─ Role: Write
  └─ Repositories: Documentation repos
```

### Przypisz Teams do CODEOWNERS

Plik `CODEOWNERS` automatycznie przypisuje odpowiednie teamy do review.

---

## 🔍 Weryfikacja Setupu

### Test 1: Pre-commit Hooks

```powershell
# Spróbuj commitować plik z secretem
echo 'password="MySecret123"' > test-secret.ps1
git add test-secret.ps1
git commit -m "test: secret detection"

# Oczekiwany rezultat: COMMIT ZABLOKOWANY
```

### Test 2: Branch Protection

```powershell
# Spróbuj push bezpośrednio do main
git checkout main
echo "test" > test.txt
git add test.txt
git commit -m "test"
git push origin main

# Oczekiwany rezultat: PUSH ZABLOKOWANY (wymaga PR)
```

### Test 3: GitHub Actions

```powershell
# Utwórz PR i sprawdź czy Actions uruchamiają się
git checkout -b test/security-checks
echo "# Test" > TEST.md
git add TEST.md
git commit -m "docs: add test file"
git push origin test/security-checks

# Utwórz PR na GitHubie
# Oczekiwany rezultat: 5+ checks uruchomionych automatycznie
```

---

## 📊 Co Jest Sprawdzane?

### Podczas Commit (Local Pre-commit Hooks)

| Check | Tool | Blocked |
|-------|------|---------|
| Secrets in code | detect-secrets, gitleaks | ✅ Yes |
| Large files (>10MB) | pre-commit | ✅ Yes |
| Private keys | pre-commit | ✅ Yes |
| Syntax errors (PS1, Python, Terraform) | Various | ✅ Yes |
| Code style (PEP8, PSScriptAnalyzer) | Various | ✅ Yes |
| YAML/JSON validity | yamllint, jsonschema | ✅ Yes |
| Trailing whitespace | pre-commit | ✅ Yes |
| Merge conflicts | pre-commit | ✅ Yes |

### Podczas PR (GitHub Actions)

| Check | Tool | Blocked |
|-------|------|---------|
| Secret scanning | TruffleHog, GitLeaks | ✅ Yes |
| PowerShell security | PSScriptAnalyzer | ✅ Yes |
| Python security | Bandit, Safety | ✅ Yes |
| Terraform security | TFSec, Checkov | ✅ Yes |
| Dependency vulnerabilities | Dependency Review | ✅ Yes |
| PR metadata (title, description) | Custom | ⚠️ Warning |
| Commit messages convention | Conventional Commits | ⚠️ Warning |
| Documentation updates | Custom | ⚠️ Warning |
| Large PRs (>1000 lines) | Custom | ⚠️ Warning |

---

## 🎯 Security Levels

### Level 1: Local (Pre-commit) ✅
**ZAIMPLEMENTOWANE**
- Blokuje commit z secretami
- Waliduje składnię
- Sprawdza style code
- Wykrywa large files

### Level 2: CI/CD (GitHub Actions) ✅
**ZAIMPLEMENTOWANE**
- Skanuje secrets (multiple tools)
- Analizuje security (5+ scanners)
- Testuje kod (if tests exist)
- Generuje raporty

### Level 3: Branch Protection ✅
**DO SKONFIGUROWANIA RĘCZNIE**
- Wymaga PR review (min 1)
- Wymaga passing checks
- Blokuje force push
- Wymaga linear history

### Level 4: Organization Policies ✅
**DO SKONFIGUROWANIA RĘCZNIE**
- Read-only default permissions
- No repository creation by members
- Dependabot enabled globally
- Secret scanning enabled globally

---

## 🔧 Troubleshooting

### Problem: Pre-commit hooks nie działają

```powershell
# Reinstall hooks
pre-commit uninstall
pre-commit install
pre-commit install --hook-type commit-msg

# Update hooks
pre-commit autoupdate

# Test
pre-commit run --all-files
```

### Problem: GitHub Actions failing

**Check logs:**
1. Otwórz PR
2. Kliknij "Details" przy failed check
3. Przeczytaj error message
4. Popraw issue lokalnie
5. Push fix

**Common issues:**
- PSScriptAnalyzer errors → Fix code style
- Secret detected → Remove secret, use env var
- Terraform syntax → Run `terraform fmt`
- Python linting → Run `black .` and `flake8 .`

### Problem: Nie mogę merge PR

**Checklist:**
- [ ] Wszystkie checks passed?
- [ ] Co najmniej 1 approval?
- [ ] Wszystkie conversations resolved?
- [ ] Branch up-to-date with main?
- [ ] No merge conflicts?

---

## 📚 Pliki w Systemie Zabezpieczeń

```
zsel-eip-infra/
├── .github/
│   ├── workflows/
│   │   ├── security-checks.yml       ← Główne security checks
│   │   └── pr-validation.yml         ← PR validation rules
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── security_vulnerability.md
│   └── PULL_REQUEST_TEMPLATE.md
├── .pre-commit-config.yaml            ← Local pre-commit hooks
├── .yamllint.yml                      ← YAML linting rules
├── .markdownlint.json                 ← Markdown linting rules
├── .markdown-link-check.json          ← Link checking config
├── .tflint.hcl                        ← Terraform linting rules
├── setup.cfg                          ← Python tools config
├── CODEOWNERS                         ← Auto-assign reviewers
├── SECURITY.md                        ← Security policy
├── CONTRIBUTING.md                    ← Contribution guidelines
└── SECURITY-SETUP.md                  ← This file
```

---

## 🎓 Best Practices

### 1. **Always Create Feature Branches**
```bash
git checkout -b feature/my-feature
# NEVER commit directly to main
```

### 2. **Write Descriptive Commit Messages**
```
feat(network): add LLDP topology verification

Implements automated network topology validation using LLDP discovery.
Includes PowerShell script with HTML reporting.

Closes #42
```

### 3. **Keep PRs Small**
- Max 50 files per PR
- Max 1000 lines changed
- Single logical change per PR

### 4. **Review Your Own PRs First**
- Read the diff carefully
- Check for debug code
- Verify no secrets
- Test manually

### 5. **Respond to Review Comments Promptly**
- Address all feedback
- Resolve conversations
- Re-request review when ready

---

## 📞 Support

**Questions:** Create [Discussion](https://github.com/ZSEL-OPOLE/zsel-eip-infra/discussions)  
**Bugs:** Create [Issue](https://github.com/ZSEL-OPOLE/zsel-eip-infra/issues)  
**Security:** Email security@zsel.opole.pl

---

## ✅ Setup Checklist

**Local Setup:**
- [ ] Pre-commit installed (`pip install pre-commit`)
- [ ] Hooks installed (`pre-commit install`)
- [ ] Commit-msg hook installed (`pre-commit install --hook-type commit-msg`)
- [ ] Test passed (`pre-commit run --all-files`)

**Repository Setup:**
- [ ] Branch protection enabled for `main`
- [ ] Required checks configured (5+)
- [ ] Code owners file committed
- [ ] Merge strategy set (squash/rebase only)
- [ ] Auto-delete head branches enabled

**Organization Setup:**
- [ ] Base permissions set to Read
- [ ] Dependabot enabled globally
- [ ] Secret scanning enabled (if available)
- [ ] Teams created and assigned
- [ ] Member repository creation disabled

**GitHub Actions:**
- [ ] `.github/workflows/security-checks.yml` committed
- [ ] `.github/workflows/pr-validation.yml` committed
- [ ] Actions enabled in repository settings
- [ ] First workflow run successful

**Documentation:**
- [ ] SECURITY.md reviewed by team
- [ ] CONTRIBUTING.md shared with contributors
- [ ] CODEOWNERS teams match actual teams
- [ ] Issue templates tested

---

**🎉 Setup Complete! Organizacja zabezpieczona zgodnie z best practices!**

---

**Created:** 2025-11-27  
**Version:** 1.0  
**Maintained by:** ZSE-BCU Security Team
