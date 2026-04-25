type Item = {
  title: string;
  description: string;
};

const ITEMS: Item[] = [
  {
    title: "Claim Rewards",
    description:
      "Daily Merkle-proof claim of ECOD earned from verified cleanups. Backend integration in Phase 2.",
  },
  {
    title: "Corporate Burn",
    description:
      "Burn PLASTIC credits with on-chain ESG certificate for CSRD reporting. B2B-only.",
  },
  {
    title: "Governance",
    description:
      "Vote on Sub-DAO proposals (Baltic, Mediterranean, Lakes PL). Off-chain Snapshot integration first.",
  },
];

export function ComingSoonGrid() {
  return (
    <div className="grid gap-4 sm:grid-cols-3">
      {ITEMS.map((item) => (
        <div
          key={item.title}
          className="relative overflow-hidden rounded-2xl border border-white/10 bg-[#071426]/60 p-5 opacity-70"
        >
          <span className="absolute right-3 top-3 rounded-full bg-cyan-300/10 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-cyan-300">
            Soon
          </span>
          <h3 className="mb-2 text-base font-semibold text-white">
            {item.title}
          </h3>
          <p className="text-sm text-white/60">{item.description}</p>
        </div>
      ))}
    </div>
  );
}
