import { defineRouting } from "next-intl/routing";

export const routing = defineRouting({
  locales: ["en", "pl", "es", "de", "fr", "it", "hr"],
  defaultLocale: "en",
});
