/**
 * On-chain contract addresses for the EcoDive dApp.
 * MVP supports Base Sepolia testnet only.
 */

import { baseSepolia } from "wagmi/chains";

export const SUPPORTED_CHAIN = baseSepolia;

export const CONTRACTS = {
  ECOD: "0xa6A6f140eaD9729a49A6aaa95B0F64cD6CB31513",
  PLASTIC: "0xa993eEC1B74262422D59c0cD5C54E549C51f912b",
} as const satisfies Record<string, `0x${string}`>;

export const BASESCAN_TX_BASE = "https://sepolia.basescan.org";

export function basescanAddressUrl(address: `0x${string}`): string {
  return `${BASESCAN_TX_BASE}/address/${address}`;
}
