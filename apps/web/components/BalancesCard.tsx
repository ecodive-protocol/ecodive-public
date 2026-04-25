"use client";

import { useAccount, useReadContract } from "wagmi";
import { formatUnits } from "viem";
import { useTranslations } from "next-intl";
import { erc20Abi } from "@/lib/abi";
import { CONTRACTS, basescanAddressUrl } from "@/lib/contracts";

type TokenKey = keyof typeof CONTRACTS;

function TokenRow({ token }: { token: TokenKey }) {
  const { address, isConnected } = useAccount();
  const t = useTranslations("dapp.balances");
  const contract = CONTRACTS[token];

  const { data: symbol } = useReadContract({
    address: contract,
    abi: erc20Abi,
    functionName: "symbol",
  });

  const { data: decimals } = useReadContract({
    address: contract,
    abi: erc20Abi,
    functionName: "decimals",
  });

  const { data: balance, isLoading } = useReadContract({
    address: contract,
    abi: erc20Abi,
    functionName: "balanceOf",
    args: address ? [address] : undefined,
    query: { enabled: Boolean(address) },
  });

  const formatted =
    balance !== undefined && decimals !== undefined
      ? formatUnits(balance as bigint, Number(decimals))
      : "—";

  return (
    <div className="flex items-center justify-between rounded-xl border border-white/10 bg-white/5 p-4">
      <div>
        <div className="text-sm font-semibold text-cyan-300">
          {(symbol as string) ?? token}
        </div>
        <a
          href={basescanAddressUrl(contract)}
          target="_blank"
          rel="noopener noreferrer"
          className="text-xs text-white/50 hover:text-white/80 underline"
        >
          {`${contract.slice(0, 6)}…${contract.slice(-4)}`}
        </a>
      </div>
      <div className="text-right">
        <div className="text-2xl font-mono text-white">
          {!isConnected ? "—" : isLoading ? "…" : formatted}
        </div>
        <div className="text-xs text-white/40">
          {isConnected ? t("yourBalance") : t("connectToView")}
        </div>
      </div>
    </div>
  );
}

export function BalancesCard() {
  const t = useTranslations("dapp.balances");
  return (
    <div className="rounded-2xl border border-white/10 bg-[#071426] p-6">
      <h2 className="mb-4 text-lg font-semibold text-white">{t("title")}</h2>
      <div className="space-y-3">
        <TokenRow token="ECOD" />
        <TokenRow token="PLASTIC" />
      </div>
      <p className="mt-4 text-xs text-white/40">{t("disclaimer")}</p>
    </div>
  );
}
