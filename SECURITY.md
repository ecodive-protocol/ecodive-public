# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest (`main`) | ✅ |

## Reporting a Vulnerability

**Do NOT open a public GitHub issue for security vulnerabilities.**

Report vulnerabilities privately via GitHub Security Advisories:  
**[Report a vulnerability](https://github.com/ecodive-protocol/ecodive-public/security/advisories/new)**

Or email: **security@ecodive.xyz**

### What to include

- Description of the vulnerability
- Steps to reproduce
- Affected component (smart contract / frontend / backend)
- Potential impact
- Suggested fix (optional)

### Response timeline

| Step | Timeframe |
|------|-----------|
| Initial acknowledgment | 48 hours |
| Triage & severity assessment | 5 business days |
| Fix / patch | Depends on severity (critical: 7 days, high: 14 days) |
| Public disclosure | After fix is deployed |

## Scope

### In scope
- Smart contracts in `contracts/src/`
- Frontend `apps/web/`
- SDK `packages/sdk/`

### Out of scope
- Third-party dependencies (report to upstream)
- Issues requiring physical access
- Social engineering attacks

## Smart Contract Security

EcoDive contracts are built with security-first principles:

- OpenZeppelin 5.x audited base contracts
- Reentrancy guards on all external functions involving token transfers
- Custom errors (no string `require`) for gas efficiency and clarity
- EIP-712 typed signatures to prevent replay attacks
- Comprehensive test suite (Foundry, ≥90% coverage)

## Disclosure Policy

We follow [Responsible Disclosure](https://en.wikipedia.org/wiki/Responsible_disclosure). We will credit researchers in release notes (with their consent).

---

*This policy applies to the `ecodive-protocol/ecodive-public` repository.*
