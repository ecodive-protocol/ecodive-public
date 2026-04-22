"use client";

import { useTranslations } from "next-intl";
import { useState } from "react";

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
    <section
      className="py-24 sm:py-32"
      style={{ background: "linear-gradient(180deg, #060f1e 0%, #040c19 100%)" }}
    >
      <div className="mx-auto max-w-xl px-4 sm:px-6 lg:px-8 text-center">
        {submitted ? (
          <div className="space-y-3">
            <div className="text-4xl">🌊</div>
            <h2 className="text-2xl font-bold text-white">{t("successTitle")}</h2>
            <p className="text-sky-200/50">{t("successText")}</p>
          </div>
        ) : (
          <>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white mb-3">{t("title")}</h2>
            <p className="text-sky-200/50 mb-8 font-medium">{t("subtitle")}</p>

            <form onSubmit={handleSubmit} noValidate className="flex flex-col sm:flex-row gap-3">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder={t("placeholder")}
                className="flex-1 rounded-xl border px-4 py-3 text-white placeholder:text-sky-200/25 focus:outline-none transition-colors text-sm font-medium"
                style={{
                  background: "rgba(10, 40, 70, 0.5)",
                  borderColor: "rgba(34,211,238,0.2)",
                }}
                onFocus={(e) => (e.currentTarget.style.borderColor = "rgba(34,211,238,0.5)")}
                onBlur={(e) => (e.currentTarget.style.borderColor = "rgba(34,211,238,0.2)")}
              />
              <button
                type="submit"
                className="rounded-xl font-semibold px-6 py-3 shrink-0 transition-all hover:-translate-y-0.5 text-sm"
                style={{ background: "linear-gradient(135deg, #0ea5e9 0%, #06b6d4 100%)", color: "#fff" }}
              >
                {t("cta")}
              </button>
            </form>

            {error && <p className="mt-2 text-sm text-red-400 text-left">{error}</p>}
            <p className="mt-4 text-xs text-sky-200/25 font-medium">{t("disclaimer")}</p>
          </>
        )}
      </div>
    </section>
  );
}
