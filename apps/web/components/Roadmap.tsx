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
    <section
      id="roadmap"
      className="py-24 sm:py-32"
      style={{ background: "linear-gradient(180deg, #0a2540 0%, #071e38 100%)" }}
    >
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-5xl font-extrabold text-white mb-4">{t("title")}</h2>
          <p className="text-sky-200/50 max-w-xl mx-auto font-medium">{t("subtitle")}</p>
        </div>

        <div className="relative">
          {/* Vertical line */}
          <div className="absolute left-6 top-0 bottom-0 w-px hidden sm:block" style={{ background: "linear-gradient(180deg, #22d3ee33 0%, #0ea5e922 100%)" }} />

          <div className="space-y-10">
            {phases.map((phase, i) => (
              <div key={i} className="relative sm:pl-16">
                {/* Dot */}
                <div
                  className={`absolute left-4 top-2 h-4 w-4 rounded-full border-2 hidden sm:block ${
                    phase.status === "active"
                      ? "bg-cyan-400 border-cyan-300 shadow-[0_0_14px_rgba(34,211,238,0.6)]"
                      : phase.status === "done"
                      ? "bg-teal-400 border-teal-300"
                      : "bg-slate-700 border-slate-600"
                  }`}
                />

                <div
                  className="border rounded-xl p-6 transition-colors hover:border-sky-400/30"
                  style={{
                    background: "rgba(10, 40, 70, 0.5)",
                    borderColor: phase.status === "active" ? "rgba(34,211,238,0.2)" : "rgba(255,255,255,0.07)",
                  }}
                >
                  <div className="flex flex-wrap items-center gap-3 mb-3">
                    <span className="text-xs font-mono text-cyan-400 uppercase tracking-widest font-bold">
                      {phase.phase}
                    </span>
                    <Badge
                      className={
                        phase.status === "active"
                          ? "bg-cyan-400/15 text-cyan-300 border-cyan-400/30"
                          : phase.status === "done"
                          ? "bg-teal-400/15 text-teal-300 border-teal-400/30"
                          : "bg-white/5 text-sky-200/30 border-white/10"
                      }
                    >
                      {phase.period}
                    </Badge>
                  </div>
                  <h3 className="text-lg font-bold text-white mb-4">{phase.title}</h3>
                  <ul className="space-y-2">
                    {phase.items.map((item, j) => (
                      <li key={j} className="flex items-start gap-2 text-sm text-sky-100/60">
                        <span className="text-cyan-400 mt-0.5 shrink-0">▸</span>
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
