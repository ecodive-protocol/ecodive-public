"use client";

import { useTranslations } from "next-intl";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

type FaqItem = { question: string; answer: string };

export function FAQ() {
  const t = useTranslations("faq");
  const items = t.raw("items") as FaqItem[];

  return (
    <section id="faq" className="bg-black py-24 sm:py-32">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-5xl font-bold text-white mb-4">{t("title")}</h2>
        </div>

        <Accordion className="space-y-3">
          {items.map((item, i) => (
            <AccordionItem
              key={i}
              value={i}
              className="bg-white/5 border border-white/10 rounded-xl px-6 hover:border-white/20 transition-colors"
            >
              <AccordionTrigger className="text-white hover:text-emerald-400 transition-colors text-left hover:no-underline py-5">
                {item.question}
              </AccordionTrigger>
              <AccordionContent className="text-white/60 text-sm leading-relaxed pb-5">
                {item.answer}
              </AccordionContent>
            </AccordionItem>
          ))}
        </Accordion>
      </div>
    </section>
  );
}
