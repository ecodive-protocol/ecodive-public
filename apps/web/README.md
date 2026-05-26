# EcoDive Web

Public landing page and testnet dApp for EcoDive.

## Stack

- Next.js App Router
- TypeScript strict mode
- Tailwind CSS
- next-intl locales: `en`, `pl`, `es`, `de`, `fr`, `it`, `hr`
- wagmi + viem + RainbowKit for the Base Sepolia testnet preview

## Getting Started

Run the development server:

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

Main content entrypoint: `app/[locale]/page.tsx`.

## Scripts

```bash
pnpm lint
pnpm build
```

## Public Messaging Rules

- Keep the first-screen copy focused on verified cleanup impact and user rewards, not token speculation.
- Do not announce a TGE date, whitelist, presale, or expected token value.
- Keep PLASTIC positioned as B2B-only and use careful language around ESG/CSRD.
- Tier 1 user copy should avoid wallet/blockchain/gas terminology.

## Deployment

Production runs on Vercel from the monorepo root with `apps/web` as the project root.
