"use client";

import { useTranslations } from "next-intl";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

type Allocation = { label: string; pct: number; color: string };

export function Tokenomics() {
  const t = useTranslations("tokenomics");
  const allocations = t.raw("allocations") as Allocation[];

  return (
    <section
      id="tokenomics"
      className="py-24 sm:py-32"
      style={{ background: "linear-gradient(180deg, #071e38 0%, #0a2540 100%)" }}
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-5xl font-extrabold text-white mb-4">{t("title")}</h2>
          <p className="text-sky-200/50 max-w-xl mx-auto font-medium">{t("subtitle")}</p>
        </div>

        {/* Token Cards */}
        <div className="grid md:grid-cols-2 gap-6 mb-16">
          {/* ECOD */}
          <Card
            className="border-sky-400/20 hover:border-sky-400/40 transition-colors"
            style={{ background: "rgba(14, 60, 100, 0.4)" }}
          >
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="text-2xl font-extrabold text-sky-300">
                  {t("ecod.name")}
                </CardTitle>
                <Badge className="bg-sky-400/15 text-sky-300 border-sky-400/30">
                  ERC-20
                </Badge>
              </div>
              <p className="text-sky-200/50 text-sm font-medium">{t("ecod.tagline")}</p>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sky-100/70 text-sm leading-relaxed">{t("ecod.description")}</p>
              <div className="grid grid-cols-3 gap-3 pt-2">
                <Stat value={t("ecod.supply")} label={t("ecod.supplyLabel")} />
                <Stat value={t("ecod.tax")} label={t("ecod.taxLabel")} />
                <Stat value={t("ecod.chain")} label={t("ecod.chainLabel")} />
              </div>
            </CardContent>
          </Card>

          {/* PLASTIC */}
          <Card
            className="border-teal-400/20 hover:border-teal-400/40 transition-colors"
            style={{ background: "rgba(10, 70, 80, 0.4)" }}
          >
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="text-2xl font-extrabold text-teal-300">
                  {t("plastic.name")}
                </CardTitle>
                <Badge className="bg-teal-400/15 text-teal-300 border-teal-400/30">RWA</Badge>
              </div>
              <p className="text-sky-200/50 text-sm font-medium">{t("plastic.tagline")}</p>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sky-100/70 text-sm leading-relaxed">{t("plastic.description")}</p>
              <div className="grid grid-cols-3 gap-3 pt-2">
                <Stat value={t("plastic.ratio")} label={t("plastic.ratioLabel")} />
                <Stat value={t("plastic.verify")} label={t("plastic.verifyLabel")} />
                <Stat value={t("plastic.burn")} label={t("plastic.burnLabel")} />
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Allocation */}
        <Card
          className="border-sky-400/15"
          style={{ background: "rgba(10, 40, 70, 0.5)" }}
        >
          <CardHeader>
            <CardTitle className="text-white text-xl font-bold">{t("allocationTitle")}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {allocations.map((a) => (
              <div key={a.label} className="flex items-center gap-4">
                <span className="text-sky-200/60 text-sm w-44 shrink-0 font-medium">{a.label}</span>
                <div className="flex-1 h-2.5 bg-white/5 rounded-full overflow-hidden">
                  <div
                    className={`h-full rounded-full ${a.color}`}
                    style={{ width: `${a.pct}%` }}
                  />
                </div>
                <span className="text-sky-200/60 text-sm w-10 text-right font-semibold">{a.pct}%</span>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </section>
  );
}

function Stat({ value, label }: { value: string; label: string }) {
  return (
    <div className="rounded-lg p-3 text-center" style={{ background: "rgba(255,255,255,0.05)" }}>
      <div className="text-white font-bold text-sm">{value}</div>
      <div className="text-sky-200/40 text-xs mt-0.5 font-medium">{label}</div>
    </div>
  );
}
