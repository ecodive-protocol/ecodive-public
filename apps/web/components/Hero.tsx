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
    <section
      className="relative min-h-screen flex flex-col items-center justify-center overflow-hidden pt-16"
      style={{ background: "linear-gradient(180deg, #030d1a 0%, #071828 40%, #0a2236 70%, #0d2f4a 100%)" }}
    >
      {/* Deep-ocean radial glow */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse 80% 50% at 50% 30%, rgba(14,100,160,0.25) 0%, transparent 70%), radial-gradient(ellipse 40% 30% at 70% 60%, rgba(34,211,238,0.08) 0%, transparent 60%)",
        }}
      />

      {/* Floating bubbles */}
      {[
        { left: "15%", bottom: "30%", size: 6, delay: "0s" },
        { left: "30%", bottom: "20%", size: 4, delay: "1.5s" },
        { left: "55%", bottom: "15%", size: 8, delay: "3s" },
        { left: "75%", bottom: "35%", size: 5, delay: "0.8s" },
        { left: "85%", bottom: "25%", size: 3, delay: "2.2s" },
      ].map((b, i) => (
        <span
          key={i}
          className="bubble absolute rounded-full border border-cyan-400/20 bg-cyan-400/5 pointer-events-none"
          style={{
            left: b.left,
            bottom: b.bottom,
            width: b.size * 4,
            height: b.size * 4,
            animationDelay: b.delay,
          }}
        />
      ))}

      {/* Content */}
      <div className="relative z-10 mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 text-center">
        <Badge className="mb-6 bg-cyan-400/15 text-cyan-300 border-cyan-400/30 hover:bg-cyan-400/15 font-medium tracking-wide">
          {t("badge")}
        </Badge>

        <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight text-white mb-6 leading-tight whitespace-pre-line">
          {t("title")}
        </h1>

        <p className="text-lg sm:text-xl text-sky-100/60 max-w-2xl mx-auto mb-10 leading-relaxed font-medium">
          {t("subtitle")}
        </p>

        <div className="flex flex-col sm:flex-row gap-4 justify-center mb-20">
          <a
            href="https://github.com/MariuszCzajka/ecodive-public/blob/main/docs/whitepaper.md"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center rounded-xl font-semibold px-8 py-3.5 transition-all text-sm shadow-lg shadow-cyan-500/20 hover:shadow-cyan-500/40 hover:-translate-y-0.5"
            style={{ background: "linear-gradient(135deg, #0ea5e9 0%, #06b6d4 100%)", color: "#fff" }}
          >
            {t("ctaPrimary")}
          </a>
          <a
            href="https://github.com/MariuszCzajka/ecodive-public/tree/main/contracts/src"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center rounded-xl border border-cyan-400/25 text-cyan-200 hover:bg-cyan-400/10 hover:-translate-y-0.5 bg-transparent px-8 py-3.5 transition-all text-sm font-medium"
          >
            {t("ctaSecondary")}
          </a>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-8 border-t border-cyan-400/10 pt-10">
          {stats.map((s) => (
            <div key={s.label} className="flex flex-col items-center gap-1">
              <span className="text-3xl sm:text-4xl font-extrabold text-cyan-300">{s.value}</span>
              <span className="text-xs sm:text-sm text-sky-200/40 text-center font-medium">{s.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Wave SVG bottom */}
      <div className="absolute bottom-0 inset-x-0 pointer-events-none overflow-hidden leading-none">
        <svg
          className="wave-animate w-full"
          viewBox="0 0 1440 80"
          preserveAspectRatio="none"
          xmlns="http://www.w3.org/2000/svg"
          style={{ display: "block" }}
        >
          <path
            d="M0,40 C240,80 480,0 720,40 C960,80 1200,0 1440,40 L1440,80 L0,80 Z"
            fill="#071e38"
            fillOpacity="0.9"
          />
        </svg>
        <svg
          className="wave-animate-slow absolute bottom-0 w-full"
          viewBox="0 0 1440 60"
          preserveAspectRatio="none"
          xmlns="http://www.w3.org/2000/svg"
          style={{ display: "block" }}
        >
          <path
            d="M0,30 C360,60 720,0 1080,30 C1260,45 1380,20 1440,30 L1440,60 L0,60 Z"
            fill="#071e38"
            fillOpacity="0.6"
          />
        </svg>
      </div>

      {/* Scroll indicator */}
      <div className="absolute bottom-10 left-1/2 -translate-x-1/2 animate-bounce z-10">
        <svg className="h-5 w-5 text-cyan-400/40" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </div>
    </section>
  );
}
