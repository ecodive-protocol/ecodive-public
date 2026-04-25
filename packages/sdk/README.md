# @ecodive/sdk

Public TypeScript SDK for the **EcoDive** Clean-to-Earn protocol — read on-chain ECOD and PLASTIC token data on Base.

[![npm version](https://img.shields.io/npm/v/@ecodive/sdk.svg)](https://www.npmjs.com/package/@ecodive/sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Status: v0.1 — read-only.** Write flows (claim rewards, corporate burn) ship in v0.2 once the Phase 2 backend is live. **Testnet only — no mainnet yet.**

## Install

```bash
pnpm add @ecodive/sdk viem
# or
npm install @ecodive/sdk viem
```

`viem ^2` is a peer dependency.

## Quick start

```ts
import { createPublicClient, http } from "viem";
import { baseSepolia } from "viem/chains";
import { getBalance, getTokenInfo } from "@ecodive/sdk";

const client = createPublicClient({
  chain: baseSepolia,
  transport: http("https://sepolia.base.org"),
});

// Token metadata
const ecod = await getTokenInfo(client, "ECOD");
console.log(ecod.symbol, ecod.decimals, ecod.totalSupply);

// Wallet balance
const balance = await getBalance(
  client,
  "PLASTIC",
  "0x4d0Ef6F910dcc6C0A40B38664D73859c7108E244",
);
console.log(`${balance.formatted} ${balance.symbol}`);
```

## API

### `getTokenInfo(client, token)`

Returns name, symbol, decimals, total supply, and deployed address for `"ECOD"` or `"PLASTIC"`.

### `getBalance(client, token, account)`

Returns the token balance for an account as both raw `bigint` and human-formatted string.

### `getTokenAddress(chainId, token)`

Static lookup of the deployed address — useful when you only need the address without a network call.

```ts
import { getTokenAddress, BASE_SEPOLIA_ID } from "@ecodive/sdk";
const ecodAddress = getTokenAddress(BASE_SEPOLIA_ID, "ECOD");
```

### `explorerAddressUrl(chainId, address)`

Returns a BaseScan URL for the given address.

### `erc20ReadAbi`

A minimal read-only ERC-20 ABI used internally — re-exported for advanced consumers who want to call `client.readContract` themselves.

## Supported chains

| Chain         | chainId | Status         |
| ------------- | ------: | -------------- |
| Base Sepolia  |   84532 | ✅ Live (v0.1) |
| Base mainnet  |    8453 | ⏳ After audit |

## Contracts

| Token   | Base Sepolia                                                                                                       |
| ------- | ------------------------------------------------------------------------------------------------------------------ |
| ECOD    | [`0xa6A6f140eaD9729a49A6aaa95B0F64cD6CB31513`](https://sepolia.basescan.org/address/0xa6A6f140eaD9729a49A6aaa95B0F64cD6CB31513) |
| PLASTIC | [`0xa993eEC1B74262422D59c0cD5C54E549C51f912b`](https://sepolia.basescan.org/address/0xa993eEC1B74262422D59c0cD5C54E549C51f912b) |

## Roadmap

- **v0.1** — read-only balances + metadata ✅
- **v0.2** — claim rewards (Merkle proof), corporate burn (ESG cert)
- **v0.3** — Sub-DAO governance helpers (Snapshot integration)
- **v1.0** — Mainnet support (post external audit)

## Disclaimer

EcoDive is in research/testnet phase. **Tokens have no monetary value, no public sale has occurred, and nothing in this SDK constitutes financial advice.** See [whitepaper](https://github.com/ecodive-protocol/ecodive-public/blob/main/docs/whitepaper.md) for details.

## License

MIT — see [LICENSE](../../LICENSE) at the repo root.
