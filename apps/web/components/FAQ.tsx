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
    <section
      id="faq"
      className="py-24 sm:py-32"
      style={{ background: "linear-gradient(180deg, #071e38 0%, #060f1e 100%)" }}
    >
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-5xl font-extrabold text-white mb-4">{t("title")}</h2>
        </div>

        <Accordion className="space-y-3">
          {items.map((item, i) => (
            <AccordionItem
              key={i}
              value={i}
              className="border rounded-xl px-6 hover:border-sky-400/25 transition-colors"
              style={{ background: "rgba(10, 40, 70, 0.45)", borderColor: "rgba(34,211,238,0.1)" }}
            >
              <AccordionTrigger className="text-sky-50 hover:text-cyan-300 transition-colors text-left hover:no-underline py-5 font-semibold">
                {item.question}
              </AccordionTrigger>
              <AccordionContent className="text-sky-100/55 text-sm leading-relaxed pb-5">
                {item.answer}
              </AccordionContent>
            </AccordionItem>
          ))}
        </Accordion>
      </div>
    </section>
  );
}
