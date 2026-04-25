import type { Address } from "viem";
import { BASE_SEPOLIA_ID, type SupportedChainId } from "./chains.js";

/**
 * Token contract names supported by the SDK.
 * - ECOD    — governance / community token (ERC-20, capped supply).
 * - PLASTIC — RWA credit token (1 token = 1 kg verified plastic).
 */
export type TokenName = "ECOD" | "PLASTIC";

export type TokenAddressBook = Readonly<Record<TokenName, Address>>;

/**
 * Deployed contract addresses, indexed by chainId.
 * Source of truth for the SDK and any consumer that imports `@ecodive/sdk/addresses`.
 */
export const ADDRESSES: Readonly<Record<SupportedChainId, TokenAddressBook>> = {
  [BASE_SEPOLIA_ID]: {
    ECOD: "0xa6A6f140eaD9729a49A6aaa95B0F64cD6CB31513",
    PLASTIC: "0xa993eEC1B74262422D59c0cD5C54E549C51f912b",
  },
} as const;

/**
 * Resolve the deployed address of a token on a given chain.
 *
 * @throws Error if the chain is not supported.
 */
export function getTokenAddress(
  chainId: SupportedChainId,
  token: TokenName,
): Address {
  const book = ADDRESSES[chainId];
  if (!book) {
    throw new Error(`[ecodive/sdk] Unsupported chainId: ${chainId}`);
  }
  return book[token];
}

/**
 * Block explorer URL helper for the supported chains.
 */
export function explorerAddressUrl(
  chainId: SupportedChainId,
  address: Address,
): string {
  switch (chainId) {
    case BASE_SEPOLIA_ID:
      return `https://sepolia.basescan.org/address/${address}`;
    default: {
      // Exhaustiveness guard — if a new chain is added to SupportedChainId
      // but not handled here, this branch will fail typecheck.
      const _exhaustive: never = chainId;
      return _exhaustive;
    }
  }
}
