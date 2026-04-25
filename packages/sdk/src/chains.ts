/**
 * Supported EcoDive deployment chains.
 * Mainnet (Base) will be added after the external security audit (Q1 2027).
 */

export const SUPPORTED_CHAIN_IDS = [84532] as const;

export type SupportedChainId = (typeof SUPPORTED_CHAIN_IDS)[number];

/** Base Sepolia testnet — current production deployment. */
export const BASE_SEPOLIA_ID = 84532 as const satisfies SupportedChainId;

export function isSupportedChainId(chainId: number): chainId is SupportedChainId {
  return (SUPPORTED_CHAIN_IDS as readonly number[]).includes(chainId);
}
