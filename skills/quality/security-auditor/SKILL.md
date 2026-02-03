---
name: security-auditor
description: |
  Security review and vulnerability assessment. Use when reviewing code for
  security issues, auditing authentication/authorization, or checking for
  OWASP Top 10 vulnerabilities. Provides actionable security recommendations.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - quality
    - security
    - audit
---

# Security Auditor

Identify and remediate security vulnerabilities in code.

## When to Use

- Security review before deployment
- Auditing authentication/authorization
- Reviewing code handling sensitive data
- Checking for OWASP Top 10 vulnerabilities
- After a security incident

## OWASP Top 10 Checklist

### 1. Broken Access Control

**Check for:**
- Missing authorization checks
- Insecure direct object references
- Path traversal vulnerabilities
- CORS misconfiguration

```typescript
// Bad: No authorization check
app.get('/api/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user);
});

// Good: Verify authorization
app.get('/api/users/:id', authenticate, async (req, res) => {
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const user = await User.findById(req.params.id);
  res.json(user);
});
```

### 2. Cryptographic Failures

**Check for:**
- Sensitive data transmitted in clear text
- Weak cryptographic algorithms
- Hardcoded secrets
- Missing encryption at rest

```typescript
// Bad: Weak hashing
const hash = crypto.createHash('md5').update(password).digest('hex');

// Good: Strong password hashing
const hash = await bcrypt.hash(password, 12);
```

### 3. Injection

**Check for:**
- SQL injection
- NoSQL injection
- Command injection
- LDAP injection

```typescript
// Bad: SQL injection vulnerability
const query = `SELECT * FROM users WHERE id = ${userId}`;

// Good: Parameterized query
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);
```

### 4. Insecure Design

**Check for:**
- Missing rate limiting
- No account lockout
- Lack of input validation
- Missing security headers

```typescript
// Good: Rate limiting
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: 'Too many login attempts'
});

app.post('/login', loginLimiter, loginHandler);
```

### 5. Security Misconfiguration

**Check for:**
- Default credentials
- Unnecessary features enabled
- Missing security headers
- Verbose error messages

```typescript
// Good: Security headers
app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
  }
}));
```

### 6. Vulnerable Components

**Check for:**
- Outdated dependencies
- Known vulnerable packages
- Unmaintained libraries

```bash
# Check for vulnerabilities
npm audit
pnpm audit

# Fix vulnerabilities
npm audit fix
```

### 7. Authentication Failures

**Check for:**
- Weak passwords allowed
- Missing MFA support
- Session fixation
- Credential stuffing vulnerability

```typescript
// Good: Password requirements
const passwordSchema = z.string()
  .min(12, 'Minimum 12 characters')
  .regex(/[A-Z]/, 'Need uppercase')
  .regex(/[a-z]/, 'Need lowercase')
  .regex(/[0-9]/, 'Need number')
  .regex(/[^A-Za-z0-9]/, 'Need special character');
```

### 8. Data Integrity Failures

**Check for:**
- Missing integrity checks
- Unsigned updates
- Insecure deserialization

```typescript
// Bad: Unsafe deserialization
const data = JSON.parse(untrustedInput);
eval(data.code);

// Good: Validate before use
const schema = z.object({
  name: z.string(),
  value: z.number()
});
const data = schema.parse(JSON.parse(untrustedInput));
```

### 9. Logging & Monitoring Failures

**Check for:**
- Missing audit logs
- No alerting on suspicious activity
- Sensitive data in logs

```typescript
// Bad: Logging sensitive data
logger.info('User login', { username, password });

// Good: Redact sensitive fields
logger.info('User login', { username, password: '[REDACTED]' });
```

### 10. Server-Side Request Forgery (SSRF)

**Check for:**
- User-controlled URLs
- Internal service access
- Cloud metadata endpoints

```typescript
// Bad: SSRF vulnerability
const response = await fetch(req.body.url);

// Good: Validate and allowlist
const allowedHosts = ['api.example.com'];
const url = new URL(req.body.url);
if (!allowedHosts.includes(url.hostname)) {
  throw new Error('Invalid URL');
}
```

## Security Review Checklist

### Authentication

- [ ] Passwords hashed with bcrypt/argon2 (cost factor ≥ 12)
- [ ] Session tokens are random and unpredictable
- [ ] Session expires after inactivity
- [ ] Password reset tokens expire quickly
- [ ] Account lockout after failed attempts

### Authorization

- [ ] Every endpoint checks authorization
- [ ] Role-based access control implemented
- [ ] Principle of least privilege followed
- [ ] No reliance on client-side checks only

### Input Validation

- [ ] All input validated on server side
- [ ] Allowlist validation preferred over blocklist
- [ ] File uploads validated (type, size, content)
- [ ] SQL queries use parameterized statements

### Data Protection

- [ ] Sensitive data encrypted at rest
- [ ] HTTPS enforced everywhere
- [ ] Secure cookies (HttpOnly, Secure, SameSite)
- [ ] No secrets in code or logs

### Headers & Configuration

- [ ] Security headers set (CSP, HSTS, etc.)
- [ ] CORS properly configured
- [ ] Debug mode disabled in production
- [ ] Error messages don't leak info

## Report Format

```markdown
## Security Audit Report

### Critical Issues
Issues requiring immediate attention.

#### [CRITICAL] SQL Injection in User Search
**Location**: `src/api/users.ts:45`
**Risk**: Database compromise, data theft
**Remediation**: Use parameterized queries

### High Severity
Significant vulnerabilities.

### Medium Severity
Issues that should be addressed.

### Low Severity
Minor issues and recommendations.

### Recommendations
General security improvements.
```

## Quick Scan Commands

```bash
# Node.js dependency audit
npm audit --audit-level=high

# Python dependency scan
pip-audit

# Secret scanning
gitleaks detect

# SAST scanning
semgrep --config=auto .
```
