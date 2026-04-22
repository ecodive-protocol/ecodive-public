import type { Metadata } from "next";
import { Plus_Jakarta_Sans } from "next/font/google";
import { NextIntlClientProvider } from "next-intl";
import { getMessages } from "next-intl/server";
import { notFound } from "next/navigation";
import { routing } from "@/i18n/routing";
import "./globals.css";

const jakartaSans = Plus_Jakarta_Sans({
  variable: "--font-jakarta",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
});

export const metadata: Metadata = {
  title: "EcoDive — Clean-to-Earn Protocol",
  description:
    "Rewarding ocean divers and beach cleaners with ECOD tokens. Every kilogram of verified plastic becomes a PLASTIC RWA credit on Base L2.",
  openGraph: {
    title: "EcoDive — Clean-to-Earn Protocol",
    description: "Turning ocean cleanup into digital value on Base L2.",
    type: "website",
  },
};

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

export default async function LocaleLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  if (!routing.locales.includes(locale as "en" | "pl")) notFound();

  const messages = await getMessages();

  return (
    <html lang={locale} className="scroll-smooth">
      <body className={`${jakartaSans.variable} font-[family-name:var(--font-jakarta)] antialiased`}>
        <NextIntlClientProvider messages={messages}>{children}</NextIntlClientProvider>
      </body>
    </html>
  );
}
