"use client";

import { useTranslations } from "next-intl";
import { Badge } from "@/components/ui/badge";

type Phase = {
  phase: string;
  title: string;
  period: string;
  status: "active" | "upcoming" | "done";
  items: string[];
};

export function Roadmap() {
  const t = useTranslations("roadmap");
  const phases = t.raw("phases") as Phase[];

  return (
    <section id="roadmap" className="bg-zinc-950 py-24 sm:py-32">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-5xl font-bold text-white mb-4">{t("title")}</h2>
          <p className="text-white/50 max-w-xl mx-auto">{t("subtitle")}</p>
        </div>

        <div className="relative">
          {/* Vertical line */}
          <div className="absolute left-6 top-0 bottom-0 w-px bg-white/10 hidden sm:block" />

          <div className="space-y-10">
            {phases.map((phase, i) => (
              <div key={i} className="relative sm:pl-16">
                {/* Dot */}
                <div
                  className={`absolute left-4 top-1.5 h-4 w-4 rounded-full border-2 hidden sm:block ${
                    phase.status === "active"
                      ? "bg-emerald-500 border-emerald-400 shadow-[0_0_12px_rgba(16,185,129,0.5)]"
                      : phase.status === "done"
                      ? "bg-teal-500 border-teal-400"
                      : "bg-zinc-700 border-zinc-600"
                  }`}
                />

                <div className="bg-white/5 border border-white/10 rounded-xl p-6 hover:border-white/20 transition-colors">
                  <div className="flex flex-wrap items-center gap-3 mb-3">
                    <span className="text-xs font-mono text-emerald-400 uppercase tracking-widest">
                      {phase.phase}
                    </span>
                    <Badge
                      className={
                        phase.status === "active"
                          ? "bg-emerald-500/20 text-emerald-300 border-emerald-500/30"
                          : phase.status === "done"
                          ? "bg-teal-500/20 text-teal-300 border-teal-500/30"
                          : "bg-white/5 text-white/40 border-white/10"
                      }
                    >
                      {phase.period}
                    </Badge>
                  </div>
                  <h3 className="text-lg font-semibold text-white mb-4">{phase.title}</h3>
                  <ul className="space-y-2">
                    {phase.items.map((item, j) => (
                      <li key={j} className="flex items-start gap-2 text-sm text-white/60">
                        <span className="text-emerald-500 mt-0.5 shrink-0">▸</span>
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
