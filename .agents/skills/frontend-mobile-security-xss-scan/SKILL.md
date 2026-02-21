---
name: XSS Vulnerability Scanner
description: "Detection, analysis, and prevention of Cross-Site Scripting (XSS) vulnerabilities in frontend and mobile applications."
---

# XSS Vulnerability Scanner

This skill provides expertise in identifying, analyzing, and preventing XSS vulnerabilities.

## 1. Detection Methods
- Manual code review focusing on data injection points.
- Automated scanning using security tools.
- Dynamic analysis by testing inputs with common XSS payloads.

## 2. Framework-Specific Analysis
- **React**: Check for `dangerouslySetInnerHTML`, insecure prop usage, and older versions with known vulnerabilities.
- **Next.js**: Analyze use of `next/script`, `dangerouslySetInnerHTML`, and server-side rendering patterns.
- **React Native**: Focus on `WebView` components and data handling in native modules.

## 3. Secure Coding Examples
- Provide examples of how to securely handle user input.
- Show how to use framework-provided sanitization and escaping mechanisms.

## 4. Automated Scanning Integration
- Instructions on how to integrate security scanning tools into the CI/CD pipeline.

## 5. Report Generation
- Create detailed reports on identified vulnerabilities, including severity, location, and remediation steps.

## Prevention Checklist
- [ ] Use framework-provided auto-escaping.
- [ ] Sanitize all user input before rendering.
- [ ] Use Content Security Policy (CSP) headers.
- [ ] Set `HttpOnly` and `Secure` flags on cookies.
- [ ] Avoid `dangerouslySetInnerHTML` unless absolutely necessary and sanitized.
