import { getTranslations } from "next-intl/server";

export async function ComingSoonGrid() {
  const t = await getTranslations("dapp.comingSoon");

  const items = [
    { key: "claim", title: t("claim.title"), description: t("claim.description") },
    { key: "burn",  title: t("burn.title"),  description: t("burn.description")  },
    { key: "governance", title: t("governance.title"), description: t("governance.description") },
  ];

  return (
    <div className="grid gap-4 sm:grid-cols-3">
      {items.map((item) => (
        <div
          key={item.key}
          className="relative overflow-hidden rounded-2xl border border-white/10 bg-[#071426]/60 p-5 opacity-70"
        >
          <span className="absolute right-3 top-3 rounded-full bg-cyan-300/10 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-cyan-300">
            {t("badge")}
          </span>
          <h3 className="mb-2 text-base font-semibold text-white">{item.title}</h3>
          <p className="text-sm text-white/60">{item.description}</p>
        </div>
      ))}
    </div>
  );
}
