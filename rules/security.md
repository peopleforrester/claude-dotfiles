<!-- Tokens: ~900 | Lines: 110 | Compatibility: Claude Code 2.1+ -->
# Security Rules

Mandatory security constraints for all code operations. These rules enforce
defense-in-depth practices based on the OWASP Top 10 (2021) and CWE/SANS Top 25.

## Always

### Input Validation
- Validate all user input on the server side, never trust client-side validation alone
- Use allowlist validation over blocklist (define what IS allowed, not what is blocked)
- Sanitize data before database operations using parameterized queries or ORM methods
- Escape output based on context: HTML entities for HTML, prepared statements for SQL
- Validate file uploads by content type inspection, not just file extension

### Secrets Management
- Store secrets in environment variables, secret managers, or encrypted vaults
- Rotate secrets on a regular schedule and after any potential exposure
- Use different credentials for development, staging, and production
- Mask secrets in error messages, logs, and stack traces

### Authentication
- Hash passwords with bcrypt (cost >= 12), argon2id, or scrypt
- Generate session tokens with cryptographically secure random number generators
- Implement session expiration, idle timeout, and rotation on privilege escalation
- Enforce rate limiting on login endpoints (max 5 attempts per minute)
- Support multi-factor authentication for sensitive operations

### Authorization
- Check authorization on every protected endpoint (never rely on UI-only restrictions)
- Apply principle of least privilege to all service accounts and API keys
- Use indirect object references to prevent IDOR attacks
- Log all authorization failures for security monitoring

### Data Protection
- Enforce HTTPS/TLS 1.2+ for all data in transit
- Encrypt sensitive data at rest (AES-256 or equivalent)
- Set security headers: CSP, HSTS, X-Content-Type-Options, X-Frame-Options
- Configure CORS restrictively (explicit allowed origins, not wildcard)

## Never

- Hardcode secrets, API keys, passwords, or tokens in source code
- Store passwords in plain text or with reversible encryption
- Use MD5 or SHA1 for password hashing (use bcrypt/argon2 instead)
- Expose stack traces or internal error details in production responses
- Disable HTTPS for any production endpoint
- Execute user-provided strings as code, SQL, or shell commands without sanitization
- Trust file extensions for upload validation (inspect content bytes)
- Log sensitive data: passwords, tokens, PII, credit card numbers
- Use `eval()`, `exec()`, or dynamic code execution with user input
- Disable CSRF protection on state-changing endpoints

## OWASP Top 10 Quick Reference

| # | Vulnerability | Prevention |
|---|--------------|------------|
| A01 | Broken Access Control | Authorization on every endpoint, deny by default |
| A02 | Cryptographic Failures | TLS 1.2+, AES-256 at rest, no weak hashing |
| A03 | Injection | Parameterized queries, ORMs, input validation |
| A04 | Insecure Design | Threat modeling, secure design patterns |
| A05 | Security Misconfiguration | Security headers, disable debug, rotate defaults |
| A06 | Vulnerable Components | Regular `npm audit`/`pip-audit`, update dependencies |
| A07 | Auth Failures | MFA, bcrypt, session management, rate limiting |
| A08 | Data Integrity Failures | Verify signatures, use trusted CI/CD, SRI |
| A09 | Logging Failures | Audit trail, no PII in logs, monitoring alerts |
| A10 | SSRF | Allowlist URLs, validate schemes, block internal IPs |

## Before Every Commit

- [ ] `git diff` contains no secrets, API keys, or tokens
- [ ] All user inputs are validated on the server side
- [ ] Database queries use parameterized statements or ORM
- [ ] Authorization checks are present on new/changed endpoints
- [ ] Error messages are safe for production (no stack traces)
- [ ] Dependencies have no known critical CVEs (`npm audit` / `pip-audit`)

## Security Response Protocol

If a security issue is found during development:
1. Stop current work and assess severity
2. Document the vulnerability with CWE reference
3. Implement remediation with secure code patterns
4. Add regression test to prevent reintroduction
5. Review surrounding code for similar patterns
6. If credentials were exposed, rotate them immediately
