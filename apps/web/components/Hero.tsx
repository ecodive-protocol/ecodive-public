"use client";

import { useTranslations } from "next-intl";
import { Badge } from "@/components/ui/badge";

export function Hero() {
  const t = useTranslations("hero");

  const stats = [
    { value: t("stat1Value"), label: t("stat1Label") },
    { value: t("stat2Value"), label: t("stat2Label") },
    { value: t("stat3Value"), label: t("stat3Label") },
  ];

  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center overflow-hidden bg-black pt-16">
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-b from-emerald-950/40 via-black to-black pointer-events-none" />
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-emerald-500/10 rounded-full blur-3xl pointer-events-none" />

      <div className="relative z-10 mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 text-center">
        <Badge className="mb-6 bg-emerald-500/20 text-emerald-300 border-emerald-500/30 hover:bg-emerald-500/20">
          {t("badge")}
        </Badge>

        <h1 className="text-4xl sm:text-6xl lg:text-7xl font-bold tracking-tight text-white mb-6 leading-tight whitespace-pre-line">
          {t("title")}
        </h1>

        <p className="text-lg sm:text-xl text-white/60 max-w-2xl mx-auto mb-10 leading-relaxed">
          {t("subtitle")}
        </p>

        <div className="flex flex-col sm:flex-row gap-4 justify-center mb-20">
          <a
            href="https://github.com/MariuszCzajka/ecodive-public/blob/main/docs/whitepaper.md"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center rounded-lg bg-emerald-500 hover:bg-emerald-400 text-black font-semibold px-8 py-3 transition-colors text-sm"
          >
            {t("ctaPrimary")}
          </a>
          <a
            href="https://github.com/MariuszCzajka/ecodive-public/tree/main/contracts/src"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center rounded-lg border border-white/20 text-white hover:bg-white/10 bg-transparent px-8 py-3 transition-colors text-sm"
          >
            {t("ctaSecondary")}
          </a>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-8 border-t border-white/10 pt-10">
          {stats.map((s) => (
            <div key={s.label} className="flex flex-col items-center gap-1">
              <span className="text-3xl sm:text-4xl font-bold text-emerald-400">{s.value}</span>
              <span className="text-xs sm:text-sm text-white/50 text-center">{s.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Scroll indicator */}
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
        <svg className="h-6 w-6 text-white/30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </div>
    </section>
  );
}
