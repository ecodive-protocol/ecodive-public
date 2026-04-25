import type { ReactNode } from "react";
import { Web3ProvidersClient } from "@/components/Web3ProvidersClient";

export default function DappLayout({ children }: { children: ReactNode }) {
  return <Web3ProvidersClient>{children}</Web3ProvidersClient>;
}
