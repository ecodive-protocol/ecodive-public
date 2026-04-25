"use client";

import dynamic from "next/dynamic";
import type { ReactNode } from "react";

const Web3Providers = dynamic(
  () => import("./Web3Providers").then((m) => m.Web3Providers),
  { ssr: false },
);

export function Web3ProvidersClient({ children }: { children: ReactNode }) {
  return <Web3Providers>{children}</Web3Providers>;
}
