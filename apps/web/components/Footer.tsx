"use client";

import { useTranslations } from "next-intl";
import { Separator } from "@/components/ui/separator";

export function Footer() {
  const t = useTranslations("footer");

  const links = [
    {
      label: t("contracts"),
      href: "https://github.com/ecodive-protocol/ecodive-public/tree/main/contracts/src",
    },
    {
      label: t("docs"),
      href: "https://github.com/ecodive-protocol/ecodive-public/tree/main/docs",
    },
    {
      label: t("github"),
      href: "https://github.com/ecodive-protocol/ecodive-public",
    },
  ];

  return (
    <footer
      className="border-t py-10"
      style={{
        background: "#040c19",
        borderColor: "rgba(34,211,238,0.08)",
      }}
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
          <div>
            <span className="text-lg font-extrabold text-white">🤿 EcoDive</span>
            <p className="text-sky-200/35 text-sm mt-1 font-medium">{t("tagline")}</p>
          </div>

          <div className="flex items-center gap-6">
            {links.map((l) => (
              <a
                key={l.href}
                href={l.href}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-sky-200/45 hover:text-cyan-300 transition-colors font-medium"
              >
                {l.label}
              </a>
            ))}
          </div>
        </div>

        <Separator className="my-6" style={{ backgroundColor: "rgba(34,211,238,0.08)" }} />

        <p className="text-center text-xs text-sky-200/25 font-medium">{t("copyright")}</p>
      </div>
    </footer>
  );
}
