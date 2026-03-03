---
name: security-review
description: Scan the codebase for security vulnerabilities (OWASP Top 10)
allowed-tools: Read, Grep, Glob, Bash
disable-model-invocation: true
---

Perform a security review of this codebase.

## Checks

1. **Hardcoded secrets** — grep for API keys, passwords, tokens, private keys, connection strings
2. **Injection** — SQL injection (string concat in queries), command injection (`shell=True`, `eval`), XSS (`innerHTML`, `dangerouslySetInnerHTML`)
3. **Auth issues** — missing auth middleware, JWT without expiration, disabled cert validation, `CORS: *`
4. **Dependencies** — run `npm audit` or `pip audit` if available
5. **Data exposure** — sensitive data in logs, stack traces in error responses
6. **Config** — debug mode in prod, default credentials, missing security headers

## Output

For each finding report: severity (CRITICAL/HIGH/MEDIUM/LOW), file:line, category, description, impact, and fix.
End with a summary table of findings by severity.
