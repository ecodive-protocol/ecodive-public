"use client";

import { useTranslations } from "next-intl";
import { useState } from "react";
import { Button } from "@/components/ui/button";

export function Newsletter() {
  const t = useTranslations("newsletter");
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState("");

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // Basic email validation — no backend yet, just UI state
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError("Please enter a valid email address.");
      return;
    }
    setError("");
    setSubmitted(true);
  }

  return (
    <section className="bg-zinc-950 py-24 sm:py-32">
      <div className="mx-auto max-w-xl px-4 sm:px-6 lg:px-8 text-center">
        {submitted ? (
          <div className="space-y-3">
            <div className="text-4xl">🌊</div>
            <h2 className="text-2xl font-bold text-white">{t("successTitle")}</h2>
            <p className="text-white/50">{t("successText")}</p>
          </div>
        ) : (
          <>
            <h2 className="text-3xl sm:text-4xl font-bold text-white mb-3">{t("title")}</h2>
            <p className="text-white/50 mb-8">{t("subtitle")}</p>

            <form onSubmit={handleSubmit} noValidate className="flex flex-col sm:flex-row gap-3">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder={t("placeholder")}
                className="flex-1 rounded-lg border border-white/20 bg-white/5 px-4 py-2.5 text-white placeholder:text-white/30 focus:outline-none focus:border-emerald-500 transition-colors text-sm"
              />
              <Button
                type="submit"
                className="bg-emerald-500 hover:bg-emerald-400 text-black font-semibold shrink-0"
              >
                {t("cta")}
              </Button>
            </form>

            {error && <p className="mt-2 text-sm text-red-400 text-left">{error}</p>}
            <p className="mt-4 text-xs text-white/30">{t("disclaimer")}</p>
          </>
        )}
      </div>
    </section>
  );
}
