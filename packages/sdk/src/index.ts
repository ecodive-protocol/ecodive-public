/**
 * @ecodive/sdk — Public TypeScript SDK for the EcoDive Clean-to-Earn protocol.
 *
 * v0.1 is read-only: balances + token metadata on Base Sepolia testnet.
 * Write paths (claim rewards, corporate burn) will be added in v0.2 once
 * the backend Merkle publisher is live.
 *
 * @packageDocumentation
 */

export {
  ADDRESSES,
  explorerAddressUrl,
  getTokenAddress,
  type TokenAddressBook,
  type TokenName,
} from "./addresses.js";

export {
  BASE_SEPOLIA_ID,
  isSupportedChainId,
  SUPPORTED_CHAIN_IDS,
  type SupportedChainId,
} from "./chains.js";

export {
  getBalance,
  getTokenInfo,
  type TokenBalance,
  type TokenInfo,
} from "./tokens.js";

export { erc20ReadAbi } from "./abi/erc20.js";
