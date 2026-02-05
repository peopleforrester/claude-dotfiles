---
description: Security-focused code audit. Checks OWASP Top 10, secrets exposure, and vulnerability patterns. Invokes the security-reviewer agent.
---

# /security-review - Security Audit

Invoke the **security-reviewer** agent for a focused security analysis.

## Usage

```
/security-review                # Review all recent changes
/security-review src/api/       # Review specific path
/security-review --owasp        # Full OWASP Top 10 checklist
/security-review --deps         # Focus on dependency vulnerabilities
```

## What Gets Checked

### Automated Scans
- Hardcoded secrets and API keys
- Vulnerable dependencies (npm audit / pip-audit / cargo audit)
- Console.log/debug statements in production code

### Manual Review (OWASP Top 10)
- A01: Broken Access Control
- A02: Cryptographic Failures
- A03: Injection (SQL, XSS, command)
- A04: Insecure Design
- A05: Security Misconfiguration
- A06: Vulnerable Components
- A07: Authentication Failures
- A08: Data Integrity Failures
- A09: Logging Failures
- A10: SSRF

## Output

```markdown
## Security Audit Report

**Risk Level**: CRITICAL / HIGH / MEDIUM / LOW

### Findings by Severity
- CRITICAL: [Must fix immediately]
- HIGH: [Fix before merge]
- MEDIUM: [Fix when possible]

Each finding includes:
- CWE reference
- File and line location
- Vulnerable code snippet
- Remediation with secure code
```

## When to Use

- After code touching authentication or authorization
- After adding API endpoints accepting user input
- After modifying database queries
- Before any production deployment
- After adding or updating dependencies
