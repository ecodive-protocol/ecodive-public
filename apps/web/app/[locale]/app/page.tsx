import { ConnectBar } from "@/components/ConnectBar";
import { BalancesCard } from "@/components/BalancesCard";
import { ComingSoonGrid } from "@/components/ComingSoonGrid";
import { Footer } from "@/components/Footer";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import Image from "next/image";

export default async function DappPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const t = await getTranslations("dapp");

  return (
    <div style={{ background: "#040c19" }} className="min-h-screen text-white">
      <header className="sticky top-0 z-40 border-b border-white/5 bg-[#040c19]/80 backdrop-blur">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
          <Link
            href={`/${locale}`}
            className="flex items-center gap-2 text-sm text-white/80 hover:text-white"
          >
            <Image
              src="/LogoMask.png"
              alt="EcoDive"
              width={32}
              height={32}
              className="rounded-full"
            />
            <span className="font-semibold">EcoDive</span>
            <span className="text-white/40">/ app</span>
          </Link>
          <ConnectBar />
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-10">
        <div className="mb-8">
          <span className="inline-block rounded-full bg-amber-400/10 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-amber-300">
            {t("testnetBadge")}
          </span>
          <h1 className="mt-3 text-3xl font-bold sm:text-4xl">{t("dashboardTitle")}</h1>
          <p className="mt-2 max-w-2xl text-white/60">
            {t("dashboardSubtitle")}
          </p>
        </div>

        <div className="grid gap-6 lg:grid-cols-[1fr_1fr]">
          <BalancesCard />
          <div className="rounded-2xl border border-white/10 bg-[#071426] p-6">
            <h2 className="mb-2 text-lg font-semibold">{t("statusTitle")}</h2>
            <ul className="space-y-2 text-sm text-white/70">
              <li>
                ✅ {t("statusContracts")}{" "}
                <span className="text-cyan-300">ECOD</span> +{" "}
                <span className="text-cyan-300">PLASTIC</span>
              </li>
              <li>🚧 {t("statusClaim")}</li>
              <li>🚧 {t("statusBurn")}</li>
              <li>🚧 {t("statusGovernance")}</li>
              <li>🔒 {t("statusMainnet")}</li>
            </ul>
          </div>
        </div>

        <div className="mt-10">
          <h2 className="mb-4 text-lg font-semibold">{t("comingNextTitle")}</h2>
          <ComingSoonGrid />
        </div>
      </main>

      <Footer />
    </div>
  );
}
