#!/usr/bin/env node
/**
 * Build the whitepaper PDF from docs/whitepaper.md using md-to-pdf (Puppeteer).
 *
 * Output: docs/whitepaper.pdf
 *
 * Usage:
 *   node scripts/build-whitepaper-pdf.mjs
 */

import { mdToPdf } from "md-to-pdf";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { stat } from "node:fs/promises";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");

const inputPath = path.join(repoRoot, "docs", "whitepaper.md");
const outputPath = path.join(repoRoot, "docs", "whitepaper.pdf");
const cssPath = path.join(repoRoot, "docs", "whitepaper.css");

console.log(`[whitepaper] Rendering ${path.relative(repoRoot, inputPath)} → ${path.relative(repoRoot, outputPath)}`);

const pdf = await mdToPdf(
  { path: inputPath },
  {
    dest: outputPath,
    stylesheet: [cssPath],
    pdf_options: {
      format: "A4",
      printBackground: true,
      margin: {
        top: "22mm",
        bottom: "22mm",
        left: "18mm",
        right: "18mm",
      },
      displayHeaderFooter: true,
      headerTemplate:
        '<div style="font-size:8pt;color:#4b6079;width:100%;padding:0 18mm;display:flex;justify-content:space-between;">' +
        '<span>EcoDive · Whitepaper v1.0</span>' +
        '<span>ecodive.xyz</span>' +
        '</div>',
      footerTemplate:
        '<div style="font-size:8pt;color:#4b6079;width:100%;padding:0 18mm;text-align:center;">' +
        'Page <span class="pageNumber"></span> / <span class="totalPages"></span>' +
        '</div>',
    },
    launch_options: {
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    },
  },
);

if (!pdf) {
  console.error("[whitepaper] md-to-pdf returned no result");
  process.exit(1);
}

const { size } = await stat(outputPath);
console.log(`[whitepaper] OK — ${(size / 1024).toFixed(1)} KB`);
