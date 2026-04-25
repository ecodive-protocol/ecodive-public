# Publishing the Whitepaper to IPFS

This repo ships the whitepaper in two formats:

- **`docs/whitepaper.md`** — canonical source, version-controlled, edited as plain Markdown.
- **`docs/whitepaper.pdf`** — generated PDF (typeset, page numbers, header/footer). Rebuild with `pnpm whitepaper:pdf`.

The PDF is published to IPFS so it can be referenced by an immutable CID from the smart contracts, the website, and external partners.

---

## Build the PDF locally

```bash
pnpm install --ignore-workspace
pnpm whitepaper:pdf
```

Output: `docs/whitepaper.pdf` (~190 KB).

The build is deterministic for a given Markdown + CSS input (Puppeteer / Chromium under the hood).

---

## Pin to IPFS via Pinata (recommended)

[Pinata](https://app.pinata.cloud) offers a free tier sufficient for the whitepaper.

### Option A — Web UI (no credentials in repo)

1. Sign in at <https://app.pinata.cloud>.
2. **Files → Upload → File** → select `docs/whitepaper.pdf`.
3. Copy the resulting CID (e.g. `bafybei…`).
4. Verify via gateway: `https://gateway.pinata.cloud/ipfs/<CID>` and `https://ipfs.io/ipfs/<CID>`.
5. Update the link in:
   - [`README.md`](../README.md) — top-level "Whitepaper" link.
   - [`docs/whitepaper.md`](./whitepaper.md) — header banner.
   - Landing page `apps/web/components/Hero.tsx` — `ctaPrimary` href.
6. Commit the CID change with message: `docs(whitepaper): pin v1.0 to IPFS <short-cid>`.

### Option B — Pinata CLI / API

If you have a Pinata JWT in 1Password, the CLI route avoids the web UI entirely:

```bash
PINATA_JWT=$(op item get "Pinata API JWT" --vault EcoDive --fields token --reveal)
curl -X POST https://api.pinata.cloud/pinning/pinFileToIPFS \
  -H "Authorization: Bearer ${PINATA_JWT}" \
  -F "file=@docs/whitepaper.pdf" \
  -F 'pinataMetadata={"name":"ecodive-whitepaper-v1.0.pdf"}' \
  -F 'pinataOptions={"cidVersion":1}' \
| python3 -c "import sys,json; print('CID:', json.load(sys.stdin)['IpfsHash'])"
```

> **Pinata JWT is not yet in 1Password.** Add it as a `Secure Note` titled `Pinata API JWT` once you generate one in the Pinata dashboard (`API Keys → New Key → Admin: pinFileToIPFS`).

---

## Compute the CID locally (no upload)

For a sanity check / dry run you can compute the IPFS CIDv1 without uploading:

```bash
npx -y ipfs-only-hash docs/whitepaper.pdf --cidVersion 1
```

The CID is content-addressed — anyone uploading the same bytes will get the same CID.

---

## Long-term archival (Arweave)

For permanent storage (one-time fee, no ongoing pinning) we will mirror the final v1.0 PDF to **Arweave** before TGE. This is a P2 task — IPFS via Pinata is sufficient for the testnet phase.

```bash
# Future:
# arkb deploy docs/whitepaper.pdf --wallet ~/arweave-wallet.json
```

---

## Versioning policy

- The Markdown source is versioned via Git history (no CID is "the" canonical reference until v1.0 is final).
- Every published PDF gets a CID; previous CIDs remain accessible forever (that's the point of IPFS).
- The `README.md` link points to the **latest pinned** CID.
- Major revisions bump the version banner in `whitepaper.md` (e.g. `v1.0 → v1.1`) and require a new pin.
