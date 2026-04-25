import {
  formatUnits,
  type Address,
  type PublicClient,
} from "viem";
import { erc20ReadAbi } from "./abi/erc20.js";
import { getTokenAddress, type TokenName } from "./addresses.js";
import { isSupportedChainId, type SupportedChainId } from "./chains.js";

/**
 * Static metadata describing a deployed ERC-20 token.
 */
export interface TokenInfo {
  readonly chainId: SupportedChainId;
  readonly token: TokenName;
  readonly address: Address;
  readonly name: string;
  readonly symbol: string;
  readonly decimals: number;
  readonly totalSupply: bigint;
}

/**
 * A wallet balance reading expressed both as raw bigint and as a
 * human-formatted decimal string (using the token's decimals).
 */
export interface TokenBalance {
  readonly chainId: SupportedChainId;
  readonly token: TokenName;
  readonly account: Address;
  readonly value: bigint;
  readonly formatted: string;
  readonly decimals: number;
  readonly symbol: string;
}

/**
 * Asserts that the connected `PublicClient` is on a supported chain
 * and narrows the inferred chainId to `SupportedChainId`.
 */
async function assertSupportedChain(
  client: PublicClient,
): Promise<SupportedChainId> {
  const chainId = await client.getChainId();
  if (!isSupportedChainId(chainId)) {
    throw new Error(
      `[ecodive/sdk] PublicClient is connected to chainId ${chainId}, ` +
        `which is not supported. Use Base Sepolia (84532).`,
    );
  }
  return chainId;
}

/**
 * Fetch full metadata for an EcoDive token (ECOD or PLASTIC).
 *
 * @example
 * ```ts
 * import { createPublicClient, http } from "viem";
 * import { baseSepolia } from "viem/chains";
 * import { getTokenInfo } from "@ecodive/sdk";
 *
 * const client = createPublicClient({ chain: baseSepolia, transport: http() });
 * const info = await getTokenInfo(client, "ECOD");
 * console.log(info.symbol, info.totalSupply);
 * ```
 */
export async function getTokenInfo(
  client: PublicClient,
  token: TokenName,
): Promise<TokenInfo> {
  const chainId = await assertSupportedChain(client);
  const address = getTokenAddress(chainId, token);

  const [name, symbol, decimals, totalSupply] = await Promise.all([
    client.readContract({ address, abi: erc20ReadAbi, functionName: "name" }),
    client.readContract({ address, abi: erc20ReadAbi, functionName: "symbol" }),
    client.readContract({
      address,
      abi: erc20ReadAbi,
      functionName: "decimals",
    }),
    client.readContract({
      address,
      abi: erc20ReadAbi,
      functionName: "totalSupply",
    }),
  ]);

  return {
    chainId,
    token,
    address,
    name,
    symbol,
    decimals: Number(decimals),
    totalSupply,
  };
}

/**
 * Fetch the token balance of a given account, returning both raw and
 * human-formatted values.
 */
export async function getBalance(
  client: PublicClient,
  token: TokenName,
  account: Address,
): Promise<TokenBalance> {
  const chainId = await assertSupportedChain(client);
  const address = getTokenAddress(chainId, token);

  const [value, decimals, symbol] = await Promise.all([
    client.readContract({
      address,
      abi: erc20ReadAbi,
      functionName: "balanceOf",
      args: [account],
    }),
    client.readContract({
      address,
      abi: erc20ReadAbi,
      functionName: "decimals",
    }),
    client.readContract({
      address,
      abi: erc20ReadAbi,
      functionName: "symbol",
    }),
  ]);

  const decimalsNum = Number(decimals);

  return {
    chainId,
    token,
    account,
    value,
    decimals: decimalsNum,
    symbol,
    formatted: formatUnits(value, decimalsNum),
  };
}
