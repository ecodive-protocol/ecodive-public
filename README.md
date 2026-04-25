# EcoDive & Shores

> **Clean-to-Earn protocol** bridging underwater cleanups, beach volunteering, and the real-world-asset (RWA) plastic credits market.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?logo=solidity)](https://soliditylang.org/)
[![Base](https://img.shields.io/badge/Chain-Base-0052FF?logo=coinbase)](https://base.org/)

## What is EcoDive?

EcoDive is an open-source protocol that rewards people for physically removing plastic from the environment — with special focus on underwater cleanups that traditional crowdsourcing cannot reach.

The protocol uses a **dual-token model**:

- **ECOD** — governance/community token (ERC-20)
- **PLASTIC** — RWA credit token (1 token = 1 kg of verified, removed plastic), purchased and burned by corporations for ESG/CSRD compliance

## Features

- **Buddy-Dive verification** — cryptographic dual-signature between paired divers
- **Proof of Dive** — integration with Shearwater, Suunto, and Garmin dive computers
- **C2PA provenance** — tamper-proof photo verification
- **YOLOv8 Edge AI** — on-device trash classification (18 categories)
- **Merkle-based claims** — gas-efficient rewards on Base L2
- **Sub-DAOs** — geographically decentralized governance (Baltic, Mediterranean, Lakes PL)
- **Difficulty multiplier** — x1 beach / x5 recreational diving / x10 ghost nets

## Repository structure

```
ecodive-public/
├── contracts/          Solidity smart contracts (Foundry)
├── packages/sdk/       TypeScript SDK for integrators
├── apps/web/           dApp frontend (Next.js)
├── docs/               Whitepaper, tokenomics, API reference
└── .github/            CI/CD workflows
```

## Getting started

### Prerequisites

- Node.js 22+
- pnpm 9+
- Foundry (`forge`, `cast`, `anvil`)

### Install

```bash
git clone https://github.com/MariuszCzajka/ecodive-public.git
cd ecodive-public
pnpm install
```

### Build contracts

```bash
cd contracts
forge build
forge test
```

### Run dApp locally

```bash
cd apps/web
pnpm dev
```

## Documentation

- [Whitepaper (Markdown)](docs/whitepaper.md) · [PDF](docs/whitepaper.pdf) · [Publishing to IPFS](docs/PUBLISHING_IPFS.md)
- [TypeScript SDK (`@ecodive/sdk`)](packages/sdk/README.md)
- [Tokenomics](docs/tokenomics.md)
- [Architecture](docs/architecture.md)
- [Contributing](CONTRIBUTING.md)

## Security

Found a vulnerability? Email `security@ecodive.xyz` (do NOT open a public issue).

Bug bounty program coming Q4 2026.

## License

[MIT](LICENSE) — do whatever you want, but we take no warranty. Smart contracts are audited but use at your own risk.

## Not open-source

The following components are intentionally proprietary and NOT part of this repository:
- Backend AI verification service (anti-cheat logic)
- Admin panel / B2B CRM
- Mobile app (EcoScanner)
- Trained AI models
- Business strategy documents

This aligns with standard Web3 practice (Uniswap, Hivemapper, Helium) — the protocol is open, the product is commercial.

---

> **Disclaimer:** This repository is in research phase. There is no token sale, no public offering, and no investment solicitation. Nothing here constitutes financial advice. Use at your own risk.

**Built with 🌊 by an anonymous builder based in Poland. Follow [@ecodive](#) for field reports.**
