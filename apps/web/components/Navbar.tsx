"use client";

import { useTranslations, useLocale } from "next-intl";
import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { useState, useRef, useEffect } from "react";

const LOCALES = [
  { code: "en", label: "EN", flag: "🇬🇧" },
  { code: "pl", label: "PL", flag: "🇵🇱" },
  { code: "es", label: "ES", flag: "🇪🇸" },
  { code: "de", label: "DE", flag: "🇩🇪" },
  { code: "fr", label: "FR", flag: "🇫🇷" },
  { code: "it", label: "IT", flag: "🇮🇹" },
  { code: "hr", label: "HR", flag: "🇭🇷" },
] as const;

export function Navbar() {
  const t = useTranslations("nav");
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [langOpen, setLangOpen] = useState(false);
  const langRef = useRef<HTMLDivElement>(null);

  // Close lang dropdown on outside click
  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (langRef.current && !langRef.current.contains(e.target as Node)) {
        setLangOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, []);

  function switchLocale(code: string) {
    const newPath = pathname.replace(`/${locale}`, `/${code}`);
    router.push(newPath);
    setLangOpen(false);
  }

  const currentLocale = LOCALES.find((l) => l.code === locale) ?? LOCALES[0];

  const links = [
    { href: "#tokenomics", label: t("tokenomics") },
    { href: "#roadmap", label: t("roadmap") },
    { href: "#faq", label: t("faq") },
    {
      href: "https://github.com/ecodive-protocol/ecodive-public/blob/main/docs/whitepaper.md",
      label: t("whitepaper"),
      external: true,
    },
  ];

  return (
    <nav
      className="fixed top-0 inset-x-0 z-50 border-b border-sky-400/10"
      style={{ background: "rgba(5, 15, 30, 0.75)", backdropFilter: "blur(12px)" }}
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 flex h-16 items-center justify-between">
        {/* Logo */}
        <Link href={`/${locale}`} className="flex items-center gap-2">
          <Image src="/LogoMask.png" alt="EcoDive" width={32} height={32} className="object-contain rounded-full" />
          <span className="text-xl font-extrabold tracking-tight text-white">EcoDive</span>
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
                className="text-sm text-sky-200/60 hover:text-cyan-300 transition-colors font-medium"
              >
                {l.label}
              </a>
            ) : (
              <a
                key={l.href}
                href={l.href}
                className="text-sm text-sky-200/60 hover:text-cyan-300 transition-colors font-medium"
              >
                {l.label}
              </a>
            )
          )}

          {/* Language dropdown */}
          <div ref={langRef} className="relative">
            <button
              onClick={() => setLangOpen((v) => !v)}
              className="flex items-center gap-1.5 rounded-lg border border-cyan-400/25 px-3 py-1.5 text-sm font-semibold text-cyan-300/80 hover:text-cyan-300 hover:bg-cyan-400/10 transition-colors"
            >
              <span>{currentLocale.flag}</span>
              <span>{currentLocale.label}</span>
              <svg
                className={`h-3 w-3 transition-transform ${langOpen ? "rotate-180" : ""}`}
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            {langOpen && (
              <div
                className="absolute right-0 mt-2 w-28 rounded-xl border border-sky-400/15 overflow-hidden shadow-xl"
                style={{ background: "rgba(5, 18, 35, 0.97)" }}
              >
                {LOCALES.map((l) => (
                  <button
                    key={l.code}
                    onClick={() => switchLocale(l.code)}
                    className={`w-full flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors hover:bg-cyan-400/10 ${
                      l.code === locale ? "text-cyan-300" : "text-sky-200/60 hover:text-cyan-300"
                    }`}
                  >
                    <span>{l.flag}</span>
                    <span>{l.label}</span>
                  </button>
                ))}
              </div>
            )}
          </div>

          <Link
            href={`/${locale}/app`}
            className="rounded-lg bg-cyan-400 px-3.5 py-1.5 text-sm font-semibold text-[#040c19] hover:bg-cyan-300 transition-colors"
          >
            Launch App
          </Link>
        </div>

        {/* Mobile hamburger */}
        <button
          className="md:hidden text-sky-200/60 hover:text-cyan-300"
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
        <div
          className="md:hidden border-t border-sky-400/10 px-4 py-4 flex flex-col gap-4"
          style={{ background: "rgba(5, 15, 30, 0.95)" }}
        >
          {links.map((l) =>
            l.external ? (
              <a
                key={l.href}
                href={l.href}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-sky-200/60 hover:text-cyan-300 transition-colors font-medium"
                onClick={() => setOpen(false)}
              >
                {l.label}
              </a>
            ) : (
              <a
                key={l.href}
                href={l.href}
                className="text-sm text-sky-200/60 hover:text-cyan-300 transition-colors font-medium"
                onClick={() => setOpen(false)}
              >
                {l.label}
              </a>
            )
          )}
          <Link
            href={`/${locale}/app`}
            onClick={() => setOpen(false)}
            className="rounded-lg bg-cyan-400 px-3.5 py-2 text-center text-sm font-semibold text-[#040c19] hover:bg-cyan-300 transition-colors"
          >
            Launch App
          </Link>
          {/* Mobile lang switcher */}
          <div className="flex gap-2 pt-1 border-t border-sky-400/10">
            {LOCALES.map((l) => (
              <button
                key={l.code}
                onClick={() => { switchLocale(l.code); setOpen(false); }}
                className={`flex items-center gap-1 rounded-lg px-3 py-1.5 text-sm font-semibold transition-colors ${
                  l.code === locale
                    ? "bg-cyan-400/15 text-cyan-300"
                    : "text-sky-200/50 hover:text-cyan-300 hover:bg-cyan-400/10"
                }`}
              >
                <span>{l.flag}</span>
                <span>{l.label}</span>
              </button>
            ))}
          </div>
        </div>
      )}
    </nav>
  );
}

