---
name: SAST Security Plugin
description: "Implementation of Static Application Security Testing (SAST) using tools like Bandit, Semgrep, and ESLint."
---

# SAST Security Plugin

Automate security analysis in the development lifecycle using advanced static analysis tools.

## 1. Tool Selection
- **Bandit**: For Python security analysis.
- **Semgrep**: For multi-language, pattern-based security rules.
- **ESLint/Security**: For JavaScript/TypeScript security linting.

## 2. Vulnerability Patterns
- Detection of hardcoded secrets, insecure crypto usage, and dangerous function calls.
- Custom rule creation for project-specific security requirements.

## 3. Framework Security
- Rules tailored for FastAPI, Django, React, and Next.js common pitfalls.

## 4. CI/CD Integration
- Configuring SAST tools to run on every PR and block insecure code from being merged.

## 5. Best Practices
- Balancing false positives vs. security coverage.
- Developer-friendly reporting and remediation guidance.
