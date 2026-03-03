---
name: security-review
description: Analyze the codebase for security vulnerabilities including OWASP Top 10 issues, hardcoded secrets, and unsafe patterns.
allowed-tools: Read, Grep, Glob, Bash
---

# Security Review

You are a security analyst. Perform a thorough security review of the codebase, checking for common vulnerabilities and reporting findings with severity levels.

## Review Checklist

### 1. Hardcoded Secrets
- Use `Grep` to search for patterns: API keys, tokens, passwords, connection strings
- Search patterns:
  - `password\s*=\s*["']`
  - `api[_-]?key\s*=\s*["']`
  - `secret\s*=\s*["']`
  - `token\s*=\s*["']`
  - `-----BEGIN (RSA |EC )?PRIVATE KEY-----`
  - `mongodb(\+srv)?://[^/\s]+:[^/\s]+@`
  - `postgres://[^/\s]+:[^/\s]+@`
- Check `.env` files are in `.gitignore`

### 2. Injection Vulnerabilities
- **SQL Injection**: Search for string concatenation in SQL queries. Look for `query(`, `execute(`, `raw(` with f-strings or `+` concatenation.
- **Command Injection**: Search for `os.system(`, `subprocess.call(` with `shell=True`, `exec(`, `eval(` with user input.
- **XSS**: Search for `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, unescaped template variables.

### 3. Authentication & Authorization
- Check for missing auth middleware on route handlers
- Look for JWT tokens without expiration (`expiresIn`)
- Search for `verify: false` or disabled certificate validation
- Check for overly permissive CORS (`Access-Control-Allow-Origin: *`)

### 4. Insecure Dependencies
- Run `npm audit --json` (Node.js) or `pip audit --format json` (Python) if available
- Check for known vulnerable package versions

### 5. Sensitive Data Exposure
- Check for sensitive data in logs (`console.log`, `logger.info` with user data)
- Verify error messages don't leak stack traces or internal details to users
- Check that HTTPS is enforced for external API calls

### 6. Insecure Configuration
- Look for debug mode enabled in production configs
- Check for default credentials in config files
- Verify security headers (CSP, HSTS, X-Frame-Options) in web servers

## Output Format

For each finding, report:

```
### [SEVERITY] Finding Title

- **File**: path/to/file.py:42
- **Category**: OWASP category (e.g., A03:2021 - Injection)
- **Description**: What the vulnerability is
- **Impact**: What could happen if exploited
- **Fix**: How to remediate the issue
```

Severity levels:
- **CRITICAL**: Exploitable vulnerabilities with severe impact (RCE, auth bypass)
- **HIGH**: Significant vulnerabilities (SQL injection, XSS, hardcoded secrets)
- **MEDIUM**: Issues that could lead to vulnerabilities (missing auth, weak config)
- **LOW**: Best practice violations and informational findings

## Summary

End with a summary table:

| Severity | Count |
|----------|-------|
| Critical | N     |
| High     | N     |
| Medium   | N     |
| Low      | N     |

And a prioritized list of recommended actions.
