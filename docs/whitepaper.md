# EcoDive & Shores — Whitepaper

> **v1.1 — Public Draft (Q2 2026)**
> A Clean-to-Earn protocol for verified underwater and coastal cleanups, reward points, and auditable plastic recovery credits.

---

> **Disclaimer:** Research phase only. No token sale. No public offering. No investment solicitation. Nothing herein constitutes financial advice.

## Abstract

EcoDive & Shores is an open-source protocol that rewards people for physically removing plastic from the environment and converts verified cleanups into auditable plastic recovery data for partners, communities, and corporate sustainability teams.

The protocol uses a **reward-and-proof architecture**:

- **EcoPoints** — an off-chain loyalty layer for mainstream users. EcoPoints are designed for marketplace rewards and partner redemptions without requiring a crypto wallet.
- **ECOD** — an ERC-20 governance and community token for self-custody users and future Sub-DAO participation.
- **PLASTIC** — a B2B-only plastic recovery credit where 1 token represents 1 kilogram of verified removed plastic. Corporate partners can burn PLASTIC to produce an on-chain impact certificate.

Cleanups are verified through a composite system designed specifically for environments where traditional crowdsourcing is weak: GPS and timestamp checks, Buddy-Dive dual-signature, Proof of Dive integrations, C2PA photo provenance, edge computer vision, and cloud multimodal review.

## 1. Problem

Eight million metric tons of plastic enter the world's oceans every year. Traditional approaches — centralized collectors (Plastic Bank), crowdsourced mapping (CleanApp), and voluntary carbon-style offsets (Toucan, KlimaDAO) — share two gaps:

1. **None reach underwater waste.** Recreational and technical divers who could remove ghost nets, sunken tires, and microplastic concentrations have no economic incentive.
2. **No standardized plastic credit market.** While carbon credits reached billions in RWA TVL, plastic credits remain fragmented and centralized.

At the same time, EU sustainability reporting, green-claims rules, and consumer scrutiny are pushing companies toward evidence-backed environmental claims. EcoDive is designed around auditable evidence: who collected, where, when, how much, and how the claim was verified.

## 2. Solution Overview

EcoDive is a decentralized protocol that:

1. **Verifies cleanup events** through a layered system combining GPS, timestamps, photo provenance, computer vision, buddy review, and optional dive telemetry.
2. **Rewards mainstream users** with EcoPoints for marketplace redemptions and partner benefits.
3. **Supports self-custody users** through ECOD rewards and future governance participation.
4. **Issues PLASTIC recovery credits** for verified kilograms removed, kept B2B-only and burned for auditable impact certificates.
5. **Governs ecosystem decisions** through geographically scoped Sub-DAOs once the protocol reaches sufficient traction.

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
| Clean-to-Earn Treasury / EcoPoints backing | 30% | 30,000,000 |
| Presale | 15% | 15,000,000 |
| Team (18-month vesting) | 10% | 10,000,000 |
| Marketing & Airdrops | 5% | 5,000,000 |

Tax is only applied on transfers to or from designated taxed pairs (DEX pools). Regular wallet-to-wallet transfers are untaxed. System wallets (treasury, liquidity, team) are excluded from tax to avoid double-taxation during setup.

Future EcoPoints backing is expected to be funded from the treasury allocation or a dedicated custody pool. The exact mainnet structure will be finalized only after legal review and external smart-contract audit.

### 3.2 PLASTIC — RWA Credit Token

- **Standard**: ERC-20 with burn-on-use semantics
- **Minting**: restricted to `MINTER_ROLE` (verification oracle / treasury contract)
- **Unit**: 1 token = 1 kilogram of verified plastic
- **Burn certificate**: every burn emits an indexed `BurnCertificate` event with optional 256-byte metadata for auditable impact reporting
- **Market**: B2B-only. PLASTIC is not intended for retail distribution.

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
On-device computer vision classifies trash categories. GPS, accelerometer, and signed timestamps produce a cryptographic *Proof of Location*. The exact edge model family will be selected through mobile benchmarks rather than hard-coded upfront.

### Layer 2 — Buddy-Dive
Divers operate in pairs. Two verified accounts cross-sign each other's cleanup reports. Both receive rewards and accumulate a non-transferable *Trust Score* NFT. Sybil attacks require coordinated physical presence and on-chain history across two independent accounts.

### Layer 3 — Proof of Dive
Optional integration with Shearwater Cloud, Suunto App, and Garmin Descent FIT files. Dive profile (timestamp, depth, decompression schedule) cryptographically anchors the cleanup. Bonus reward +30% ECOD for verified integration.

### Layer 4 — C2PA Provenance
For external cameras (GoPro, DSLR in housings), EcoDive validates Content Authenticity Initiative manifests that cryptographically bind photos to their capture device and edit history.

### Layer 5 — Compliance Lens
Batch-mode multimodal review audits consistency between photo, reported weight, location, and category. File hashes can be anchored on-chain as a *Root of Trust* while personal data remains off-chain.

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
- **Tier 1 limits** cap daily cleanups, high-multiplier diving claims, and marketplace redemptions until trust is established.
- **Merkle-based claim distribution** batches daily payouts into a single root, minimizing gas costs (~$0.02 per claim on Base).
- **OpenZeppelin 5.x** standards inheritance, `ReentrancyGuard` on all external transfers, custom errors throughout for gas efficiency.
- **Audit**: contracts will undergo a third-party security audit before mainnet launch.

## 7. Technology Stack

| Layer | Technology |
|---|---|
| Smart contracts | Solidity 0.8.24 + Foundry + OpenZeppelin 5.x |
| Chain | Base (L2) |
| dApp | Next.js + Viem + RainbowKit |
| Mobile | React Native + Expo |
| Edge AI | Mobile computer vision model exported to TFLite / CoreML |
| Cloud AI | Multimodal verification model router with batch processing |
| Storage | IPFS (Pinata) + Arweave |
| Anti-sybil | Device limits, behavior rules, optional identity checks, Gitcoin Passport for Web3 users |

## 8. Roadmap

- **Q2 2026** — Contracts on Base Sepolia testnet. Public landing page. Community seeding on Twitter / Farcaster.
- **Q3 2026** — Legal review. EcoPoints terms. EcoScanner Android beta. First beach event on the Polish Baltic coast. Marketplace partner pilots.
- **Q4 2026** — External security audit. Mainnet readiness. Buddy-Dive verification. First B2B PLASTIC pilot. Public pollution heatmap.
- **Q1 2027+** — Mainnet deployment after legal and audit clearance. Baltic Sub-DAO. Mediterranean expansion. iOS EcoScanner.

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
