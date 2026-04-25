/**
 * Wagmi + RainbowKit configuration.
 * Lazily imported by the dApp segment only — keeps the landing bundle lean.
 */

import { getDefaultConfig } from "@rainbow-me/rainbowkit";
import { baseSepolia } from "wagmi/chains";
import { http } from "wagmi";

const projectId =
  process.env.NEXT_PUBLIC_WALLETCONNECT_ID ?? "ecodive-mvp-placeholder";

export const wagmiConfig = getDefaultConfig({
  appName: "EcoDive",
  projectId,
  chains: [baseSepolia],
  transports: {
    [baseSepolia.id]: http("https://sepolia.base.org"),
  },
  ssr: true,
});
