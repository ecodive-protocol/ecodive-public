"use client";

import { useTranslations } from "next-intl";
import { Separator } from "@/components/ui/separator";

export function Footer() {
  const t = useTranslations("footer");

  const links = [
    {
      label: t("contracts"),
      href: "https://github.com/MariuszCzajka/ecodive-public/tree/main/contracts/src",
    },
    {
      label: t("docs"),
      href: "https://github.com/MariuszCzajka/ecodive-public/tree/main/docs",
    },
    {
      label: t("github"),
      href: "https://github.com/MariuszCzajka/ecodive-public",
    },
  ];

  return (
    <footer className="bg-black border-t border-white/10 py-10">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
          <div>
            <span className="text-lg font-bold text-white">🤿 EcoDive</span>
            <p className="text-white/40 text-sm mt-1">{t("tagline")}</p>
          </div>

          <div className="flex items-center gap-6">
            {links.map((l) => (
              <a
                key={l.href}
                href={l.href}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-white/50 hover:text-white transition-colors"
              >
                {l.label}
              </a>
            ))}
          </div>
        </div>

        <Separator className="my-6 bg-white/10" />

        <p className="text-center text-xs text-white/30">{t("copyright")}</p>
      </div>
    </footer>
  );
}
