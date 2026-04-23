# EcoDive & Shores — Whitepaper

> **v1.0 — Public Release (Q2 2026)**
> A Clean-to-Earn protocol for underwater cleanups, beach volunteering, and tokenized plastic credits.

---

> **Disclaimer:** Research phase only. No token sale. No public offering. No investment solicitation. Nothing herein constitutes financial advice.

## Abstract

EcoDive & Shores is an open-source protocol that rewards individuals for physically removing plastic from the environment and converts verified cleanups into tradeable real-world-asset (RWA) credits purchased by corporations for ESG/CSRD compliance.

The protocol uses a **dual-token architecture**:

- **ECOD** — an ERC-20 governance and community token with a 3% DEX transaction tax split between treasury, liquidity, and developer operations.
- **PLASTIC** — an ERC-20 RWA credit where 1 token equals 1 kilogram of plastic verified through a five-layer provenance system. Corporations burn PLASTIC to produce on-chain ESG offset certificates.

Cleanups are verified through a composite system designed specifically for underwater environments, where traditional crowdsourcing cannot operate: Buddy-Dive dual-signature, Proof of Dive (dive computer API integration), C2PA photo provenance, YOLOv8 edge AI, and a GPT-4o compliance lens.

## 1. Problem

Eight million metric tons of plastic enter the world's oceans every year. Traditional approaches — centralized collectors (Plastic Bank), crowdsourced mapping (CleanApp), and voluntary carbon-style offsets (Toucan, KlimaDAO) — share two gaps:

1. **None reach underwater waste.** Recreational and technical divers who could remove ghost nets, sunken tires, and microplastic concentrations have no economic incentive.
2. **No standardized plastic credit market.** While carbon credits reached billions in RWA TVL, plastic credits remain fragmented and centralized.

Simultaneously, the EU Corporate Sustainability Reporting Directive (CSRD, phased 2025–2028) requires over 50,000 companies to report measurable environmental impact — creating a multi-billion-euro demand for auditable, verifiable, on-chain ESG offsets.

## 2. Solution Overview

EcoDive is a decentralized protocol that:

1. **Verifies cleanup events** through a five-layer system combining GPS, dive computer telemetry, buddy dual-signature, AI classification, and photo provenance.
2. **Mints PLASTIC tokens** proportional to verified weight, scaled by a difficulty multiplier (beach x1 to ghost-net diving x10).
3. **Sells PLASTIC credits** to corporations for ESG reporting via on-chain burn certificates.
4. **Distributes ECOD rewards** to users from a community treasury.
5. **Governs ecosystem decisions** through geographically scoped Sub-DAOs (Baltic, Mediterranean, Lakes PL).

## 3. Tokenomics

### 3.1 ECOD — Community Token

- **Standard**: ERC-20
- **Chain**: Base (L2)
- **Total supply**: 100,000,000
- **Transaction tax on DEX**: 3% (1% treasury / 1% liquidity / 1% dev operations)
- **Distribution**:

| Allocation | % | Amount |
|---|---|---|
| DEX Liquidity | 40% | 40,000,000 |
| Clean-to-Earn Treasury | 30% | 30,000,000 |
| Presale | 15% | 15,000,000 |
| Team (18-month vesting) | 10% | 10,000,000 |
| Marketing & Airdrops | 5% | 5,000,000 |

Tax is only applied on transfers to or from designated taxed pairs (DEX pools). Regular wallet-to-wallet transfers are untaxed. System wallets (treasury, liquidity, team) are excluded from tax to avoid double-taxation during setup.

### 3.2 PLASTIC — RWA Credit Token

- **Standard**: ERC-20 with burn-on-use semantics
- **Minting**: restricted to `MINTER_ROLE` (verification oracle / treasury contract)
- **Unit**: 1 token = 1 kilogram of verified plastic
- **Burn certificate**: every burn emits an indexed `BurnCertificate` event with optional 256-byte metadata for ESG reporting
- **Market**: initially sold over-the-counter to corporations; secondary DEX liquidity optional

### 3.3 Difficulty Multiplier

Reward multiplier reflects the true cost and risk of each cleanup type:

| Cleanup type | ECOD reward | PLASTIC mint ratio |
|---|---|---|
| Beach (solo) | x1 | 1:1 kg |
| Beach (group event) | x1.2 | 1:1 kg |
| Forest / river | x1.5 | 1:1 kg |
| Recreational diving (<18m) | x5 | 1:1.2 kg |
| Technical diving (>18m) | x8 | 1:1.5 kg |
| Ghost net retrieval | x10 + bounty | 1:2 kg |

## 4. Verification Architecture

### Layer 1 — EcoScanner Mobile
On-device YOLOv8 classifies 18 trash categories. GPS, accelerometer, and signed timestamps produce a cryptographic *Proof of Location*.

### Layer 2 — Buddy-Dive
Divers operate in pairs. Two verified accounts cross-sign each other's cleanup reports. Both receive rewards and accumulate a non-transferable *Trust Score* NFT. Sybil attacks require coordinated physical presence and on-chain history across two independent accounts.

### Layer 3 — Proof of Dive
Optional integration with Shearwater Cloud, Suunto App, and Garmin Descent FIT files. Dive profile (timestamp, depth, decompression schedule) cryptographically anchors the cleanup. Bonus reward +30% ECOD for verified integration.

### Layer 4 — C2PA Provenance
For external cameras (GoPro, DSLR in housings), EcoDive validates Content Authenticity Initiative manifests that cryptographically bind photos to their capture device and edit history.

### Layer 5 — Compliance Lens
Batch-mode GPT-4o Vision audits consistency between photo, reported weight, location, and category. File hashes are anchored on-chain as a *Root of Trust*.

### Beach Verification (lighter, high-volume mode)
Beach cleanups operate in three modes: solo (daily cap), event (QR Event Code issued by organizer with group anti-cheat), and Land Buddy (pair signing). Lower reward threshold reflects lower economic incentive to cheat.

## 5. Governance

### 5.1 Sub-DAOs
Instead of a single global DAO, EcoDive partitions governance geographically:

- **Baltic DAO** (Poland, Lithuania, Latvia, Estonia, Finland, Germany, Denmark, Sweden)
- **Mediterranean DAO** (Croatia, Greece, Italy, Spain, Turkey, North Africa)
- **Lakes PL DAO** (Polish lakes, rivers)

Each Sub-DAO receives a quarterly budget from the core Treasury and votes on local priorities, events, and sponsored bounties.

### 5.2 Core DAO
Holders of Legendary-tier photo NFTs and significant ECOD stakes vote on protocol-level decisions: tax parameters, new Sub-DAO spawning, and grant allocations.

## 6. Anti-Sybil & Security

- **Gitcoin Passport** is required for reward claims above threshold amounts.
- **Merkle-based claim distribution** batches daily payouts into a single root, minimizing gas costs (~$0.02 per claim on Base).
- **OpenZeppelin 5.x** standards inheritance, `ReentrancyGuard` on all external transfers, custom errors throughout for gas efficiency.
- **Audit**: contracts will undergo a third-party security audit before mainnet launch.

## 7. Technology Stack

| Layer | Technology |
|---|---|
| Smart contracts | Solidity 0.8.24 + Foundry + OpenZeppelin 5.x |
| Chain | Base (L2) |
| dApp | Next.js 15 + Viem + RainbowKit |
| Mobile | React Native + Expo |
| Edge AI | YOLOv8 quantized (TFLite / CoreML) |
| Cloud AI | OpenAI GPT-4o Vision Batch API |
| Storage | IPFS (Pinata) + Arweave |
| Anti-sybil | Gitcoin Passport |

## 8. Roadmap

- **Q2 2026** — Contracts on Base Sepolia testnet. Public landing page. Community seeding on Twitter / Farcaster.
- **Q3 2026** — External security audit. Mainnet deployment. EcoScanner beta on Android. First beach event on the Polish Baltic coast. First hotel white-label LOI.
- **Q4 2026** — Buddy-Dive verification live. Shearwater API integration. First corporate PLASTIC credit sale. Baltic Sub-DAO activation. Public pollution heatmap.
- **Q1 2027+** — Mediterranean expansion. iOS EcoScanner. Authorial NFT collection (conditional on traction).

## 9. Open Source & Scope

The following components are MIT-licensed and developed in the public `ecodive-public` repository:

- All smart contracts (ECOD, PLASTIC, Treasury, Signer, claim infrastructure)
- TypeScript SDK for integrators
- dApp frontend
- This whitepaper and architectural documentation

The following are intentionally proprietary and commercial:

- Backend verification service (anti-cheat logic, AI orchestration)
- Admin/CRM systems
- Trained AI model weights
- Mobile application (EcoScanner)

This split follows established Web3 practice: protocols open, products commercial (cf. Uniswap V4, Hivemapper, Helium).

## 10. Contact & Contribution

- Repository: [github.com/ecodive-protocol/ecodive-public](https://github.com/ecodive-protocol/ecodive-public)
- Security disclosures: `security@ecodive.xyz`
- Twitter / Farcaster: `@ecodive`

---

*EcoDive is built by an anonymous developer combining backgrounds in firefighting, diving, underwater photography, and programming. Field reports and build logs are published continuously under the Faceless Builder convention — the work speaks, not the face.*
