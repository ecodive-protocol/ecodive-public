"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount, useChainId, useSwitchChain } from "wagmi";
import { baseSepolia } from "wagmi/chains";

export function ConnectBar() {
  const { isConnected } = useAccount();
  const chainId = useChainId();
  const { switchChain, isPending } = useSwitchChain();
  const wrongNetwork = isConnected && chainId !== baseSepolia.id;

  return (
    <div className="flex flex-col items-end gap-2">
      <ConnectButton
        accountStatus={{ smallScreen: "avatar", largeScreen: "full" }}
        chainStatus="icon"
        showBalance={false}
      />
      {wrongNetwork && (
        <button
          type="button"
          onClick={() => switchChain({ chainId: baseSepolia.id })}
          disabled={isPending}
          className="rounded-md border border-amber-400/40 bg-amber-400/10 px-3 py-1 text-xs text-amber-300 hover:bg-amber-400/20 disabled:opacity-60"
        >
          {isPending ? "Switching…" : "Switch to Base Sepolia"}
        </button>
      )}
    </div>
  );
}
