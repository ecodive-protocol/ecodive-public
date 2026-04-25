"use client";

import { useState, type ReactNode } from "react";
import { WagmiProvider } from "wagmi";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { RainbowKitProvider, darkTheme, type AvatarComponent } from "@rainbow-me/rainbowkit";
import "@rainbow-me/rainbowkit/styles.css";
import { wagmiConfig } from "@/lib/wagmi";

/**
 * Deterministic cyan/teal gradient avatar based on wallet address.
 * Shows ENS avatar when available (ensImage takes precedence).
 * Unique per address — never shows EcoDive logo for end users.
 */
const EcoDiveAvatar: AvatarComponent = ({ address, ensImage, size }) => {
  if (ensImage) {
    return (
      <img
        src={ensImage}
        width={size}
        height={size}
        style={{ borderRadius: "50%", objectFit: "cover" }}
        alt="ENS avatar"
      />
    );
  }

  // Generate a hue from the address for a unique-per-wallet gradient
  const hue = parseInt(address.slice(2, 6), 16) % 360;
  const hue2 = (hue + 60) % 360;

  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: "50%",
        background: `linear-gradient(135deg, hsl(${hue},70%,50%), hsl(${hue2},80%,40%))`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontSize: size * 0.38,
        fontWeight: 700,
        color: "rgba(255,255,255,0.85)",
        fontFamily: "monospace",
        userSelect: "none",
      }}
    >
      {address.slice(2, 4).toUpperCase()}
    </div>
  );
};

export function Web3Providers({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());

  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider
          theme={darkTheme({
            accentColor: "#22d3ee",
            accentColorForeground: "#040c19",
            borderRadius: "medium",
            fontStack: "system",
          })}
          avatar={EcoDiveAvatar}
          modalSize="compact"
          showRecentTransactions={false}
        >
          {children}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
