"use client";

import { useTranslations, useLocale } from "next-intl";
import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";
import { useState } from "react";
import { Button } from "@/components/ui/button";

export function Navbar() {
  const t = useTranslations("nav");
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  const otherLocale = locale === "en" ? "pl" : "en";

  function switchLocale() {
    // Replace /en/ or /pl/ prefix in pathname
    const newPath = pathname.replace(`/${locale}`, `/${otherLocale}`);
    router.push(newPath);
  }

  const links = [
    { href: "#tokenomics", label: t("tokenomics") },
    { href: "#roadmap", label: t("roadmap") },
    { href: "#faq", label: t("faq") },
    {
      href: "https://github.com/MariuszCzajka/ecodive-public/blob/main/docs/whitepaper.md",
      label: t("whitepaper"),
      external: true,
    },
  ];

  return (
    <nav className="fixed top-0 inset-x-0 z-50 border-b border-white/10 bg-black/70 backdrop-blur-md">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 flex h-16 items-center justify-between">
        {/* Logo */}
        <Link href={`/${locale}`} className="flex items-center gap-2">
          <span className="text-xl font-bold tracking-tight text-white">
            🤿 EcoDive
          </span>
        </Link>

        {/* Desktop links */}
        <div className="hidden md:flex items-center gap-6">
          {links.map((l) =>
            l.external ? (
              <a
                key={l.href}
                href={l.href}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-white/70 hover:text-white transition-colors"
              >
                {l.label}
              </a>
            ) : (
              <a
                key={l.href}
                href={l.href}
                className="text-sm text-white/70 hover:text-white transition-colors"
              >
                {l.label}
              </a>
            )
          )}
          <Button
            variant="outline"
            size="sm"
            onClick={switchLocale}
            className="border-white/20 text-white/70 hover:text-white bg-transparent hover:bg-white/10"
          >
            {t("langSwitch")}
          </Button>
        </div>

        {/* Mobile hamburger */}
        <button
          className="md:hidden text-white/70 hover:text-white"
          onClick={() => setOpen(!open)}
          aria-label="Toggle menu"
        >
          <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            {open ? (
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            ) : (
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            )}
          </svg>
        </button>
      </div>

      {/* Mobile menu */}
      {open && (
        <div className="md:hidden border-t border-white/10 bg-black/90 px-4 py-4 flex flex-col gap-4">
          {links.map((l) =>
            l.external ? (
              <a
                key={l.href}
                href={l.href}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-white/70 hover:text-white transition-colors"
                onClick={() => setOpen(false)}
              >
                {l.label}
              </a>
            ) : (
              <a
                key={l.href}
                href={l.href}
                className="text-sm text-white/70 hover:text-white transition-colors"
                onClick={() => setOpen(false)}
              >
                {l.label}
              </a>
            )
          )}
          <button
            onClick={() => { switchLocale(); setOpen(false); }}
            className="text-left text-sm text-emerald-400 hover:text-emerald-300 transition-colors"
          >
            {t("langSwitch")}
          </button>
        </div>
      )}
    </nav>
  );
}
