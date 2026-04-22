"use client";

import { useTranslations } from "next-intl";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

type Allocation = { label: string; pct: number; color: string };

export function Tokenomics() {
  const t = useTranslations("tokenomics");
  const allocations = t.raw("allocations") as Allocation[];

  return (
    <section id="tokenomics" className="bg-black py-24 sm:py-32">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-5xl font-bold text-white mb-4">{t("title")}</h2>
          <p className="text-white/50 max-w-xl mx-auto">{t("subtitle")}</p>
        </div>

        {/* Token Cards */}
        <div className="grid md:grid-cols-2 gap-6 mb-16">
          {/* ECOD */}
          <Card className="bg-white/5 border-emerald-500/20 hover:border-emerald-500/40 transition-colors">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="text-2xl font-bold text-emerald-400">
                  {t("ecod.name")}
                </CardTitle>
                <Badge className="bg-emerald-500/20 text-emerald-300 border-emerald-500/30">
                  ERC-20
                </Badge>
              </div>
              <p className="text-white/50 text-sm">{t("ecod.tagline")}</p>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-white/70 text-sm leading-relaxed">{t("ecod.description")}</p>
              <div className="grid grid-cols-3 gap-3 pt-2">
                <Stat value={t("ecod.supply")} label={t("ecod.supplyLabel")} />
                <Stat value={t("ecod.tax")} label={t("ecod.taxLabel")} />
                <Stat value={t("ecod.chain")} label={t("ecod.chainLabel")} />
              </div>
            </CardContent>
          </Card>

          {/* PLASTIC */}
          <Card className="bg-white/5 border-teal-500/20 hover:border-teal-500/40 transition-colors">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="text-2xl font-bold text-teal-400">
                  {t("plastic.name")}
                </CardTitle>
                <Badge className="bg-teal-500/20 text-teal-300 border-teal-500/30">RWA</Badge>
              </div>
              <p className="text-white/50 text-sm">{t("plastic.tagline")}</p>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-white/70 text-sm leading-relaxed">{t("plastic.description")}</p>
              <div className="grid grid-cols-3 gap-3 pt-2">
                <Stat value={t("plastic.ratio")} label={t("plastic.ratioLabel")} />
                <Stat value={t("plastic.verify")} label={t("plastic.verifyLabel")} />
                <Stat value={t("plastic.burn")} label={t("plastic.burnLabel")} />
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Allocation */}
        <Card className="bg-white/5 border-white/10">
          <CardHeader>
            <CardTitle className="text-white text-xl">{t("allocationTitle")}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {allocations.map((a) => (
              <div key={a.label} className="flex items-center gap-4">
                <span className="text-white/60 text-sm w-44 shrink-0">{a.label}</span>
                <div className="flex-1 h-3 bg-white/10 rounded-full overflow-hidden">
                  <div
                    className={`h-full rounded-full ${a.color}`}
                    style={{ width: `${a.pct}%` }}
                  />
                </div>
                <span className="text-white/60 text-sm w-10 text-right">{a.pct}%</span>
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
    <div className="bg-white/5 rounded-lg p-3 text-center">
      <div className="text-white font-semibold text-sm">{value}</div>
      <div className="text-white/40 text-xs mt-0.5">{label}</div>
    </div>
  );
}
