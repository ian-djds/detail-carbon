# Spec — Detail Carbon: Embodied Carbon Calculator for Architectural Details

## 1. One-line summary
A single-page web tool that lets an architect build up an architectural detail
layer by layer, then calculates and visualizes its **embodied carbon** (kgCO₂e),
both as a total and per unit area.

## 2. Purpose & audience
- **Who:** architects, designers, and students (DJDS context: justice-oriented,
  sustainability-conscious building design).
- **Goal:** quickly estimate the cradle-to-gate (A1–A3) embodied carbon of a
  wall/floor/roof detail to compare design options early in design.
- **Job to be done:** "I'm drawing a wall section. Which version is lower-carbon —
  CLT or concrete? Roughly how much, and which layer dominates?"

## 3. Constraints (non-negotiable)
- **Single self-contained `index.html` file** — inline CSS and JS, no build step,
  no external runtime dependencies. (Google Fonts via CDN link is fine, matching
  the existing demo.)
- **Fully client-side.** All carbon factors are baked into a JS object in the
  file. No backend, no API calls, no network data. Works offline once loaded.
- Must run by double-clicking the file or serving it statically (GitHub Pages /
  Netlify drag-and-drop).

## 4. Methodology (keep it honest and simple)
- Scope = **A1–A3 (product stage / cradle-to-gate)** embodied carbon only. State
  this in the UI. Do NOT silently imply whole-life carbon.
- Core formula per layer:
  `carbon (kgCO₂e) = quantity × carbon_factor`
- Two ways to specify quantity per material, the tool converts as needed:
  - **By volume:** user enters thickness (mm) → tool computes volume per m² of
    detail = `thickness_m × 1 m²`, then mass = `volume × density`, then
    `carbon = mass × factor_per_kg`.
  - **By declared unit:** some materials are better expressed per m² or per kg
    directly; support a `unit` field on each material so the math adapts.
- The default functional unit is **1 m² of the detail** (typical for wall/floor
  build-ups). Also let the user set a total area (m²) to get an absolute total.
- Ship a **small starter materials database** of ~15–20 common materials with
  representative A1–A3 factors and densities. Each entry MUST carry a short source
  note. Make every factor **editable in the UI** so users can override with values
  from an EPD or the ICE database.
- Show a clear **disclaimer**: "Indicative early-design estimates. Factors are
  representative averages, not a substitute for product-specific EPDs."

## 5. Data model
```js
// Each material: factor is kgCO2e per the given `unit`.
// For volume-based materials, provide density (kg/m³) so thickness→mass works.
{
  id: "concrete_rc",
  name: "Reinforced concrete (C30/37)",
  category: "Structure",
  unit: "kg",          // "kg" | "m2" | "m3"
  factor: 0.13,        // kgCO2e per kg (example — verify against ICE/EPD)
  density: 2400,       // kg/m³ (required when entered by thickness)
  source: "ICE v3 (indicative)"
}
```
A "detail" is an ordered list of layers; each layer references a material id +
the user's quantity input (thickness in mm, or a direct amount in the material's
unit).

**Starter materials to include** (representative — flag all as verify-before-use):
concrete (reinforced + GGBS-blended), CMU block, brick, structural steel,
aluminium, cross-laminated timber (CLT), glulam, softwood, plywood/OSB,
mineral wool insulation, EPS, XPS, cellulose, gypsum plasterboard, cement
render, glass (float), plasterboard, vapour membrane. Group by category
(Structure / Insulation / Cladding & finishes / Membranes & misc).

## 6. Layout (single screen, top-to-bottom)
1. **Header** — title "Detail Carbon", short tagline, and a `by DJDS` / `by Ian`
   byline (match the existing demo's header style).
2. **Detail builder** — a list of layer rows. Each row:
   - Material dropdown (grouped by category)
   - Thickness input (mm) OR amount input (auto-shown based on material unit)
   - Computed layer carbon (kgCO₂e/m²), right-aligned
   - Editable factor field (small, inline or in an expandable row)
   - Remove (×) button
   - "+ Add layer" button below the list
3. **Detail area input** — "Total area (m²)" so the tool can show an absolute
   total alongside the per-m² figure (default 1).
4. **Results panel** — large total `kgCO₂e/m²`, a secondary absolute total, and a
   **horizontal stacked bar** breaking the total down by layer/material (reuse the
   `.strip` visual language from the existing demo). Hovering a segment shows the
   material name + its share.
5. **Comparison slot (stretch)** — "Save as Option A / Option B" to compare two
   build-ups side by side.
6. **Footer** — methodology note + disclaimer + data source line.

## 7. Interactions
- Adding/removing a layer, changing a material, thickness, factor, or area
  **recalculates live** (no submit button).
- Clicking a result number copies it to clipboard (reuse the copy pattern from the
  existing demo — toast/"copied!" feedback).
- Sensible defaults: starts with a small example detail (e.g. plasterboard +
  mineral wool + CLT) so the screen isn't empty on load.
- Input validation: ignore/handle blank or non-numeric inputs gracefully (treat as
  0, never NaN in the UI).
- Optional: a "Reset" and a "New layer" affordance; persist the current detail to
  `localStorage` so a refresh doesn't lose work.

## 8. Visual style
Match the existing `index.html` aesthetic for a consistent hackathon look:
- Dark theme: `--bg:#0d0d0d`, `--surface:#161616`, light text, subtle borders,
  rounded corners (`--radius:16px`), `Inter` for UI + `Space Mono` for numbers/hex
  values.
- Generous spacing, soft transitions, pill-shaped primary button.
- The stacked carbon bar should feel like the `.strip` element — clean colored
  segments with smooth transitions.
- Responsive: layer rows stack cleanly on mobile (≤600px).

## 9. Acceptance criteria
- [ ] Opens as a single `index.html` with no errors in the console, offline.
- [ ] Loads with a non-empty example detail and a computed total.
- [ ] Adding a layer, picking a material, and entering a thickness updates the
      per-m² total and the absolute total live.
- [ ] Each layer shows its own kgCO₂e/m² contribution.
- [ ] The breakdown bar reflects each layer's share and updates on change.
- [ ] Factors are editable and overriding one changes the result immediately.
- [ ] A worked example checks out (see §10).
- [ ] Disclaimer + scope (A1–A3) + data source are visible.
- [ ] Looks polished and on-theme on desktop and mobile.

## 10. Worked example (sanity check for the build)
A 1 m² wall layer of reinforced concrete, 200 mm thick:
- volume = 0.200 m³, mass = 0.200 × 2400 = 480 kg
- carbon = 480 × 0.13 = **62.4 kgCO₂e/m²**
The tool should produce ~62 kgCO₂e/m² for this single layer. Use this to verify
the thickness→volume→mass→carbon chain.

## 11. Out of scope (for the hackathon)
- B/C life-cycle stages, operational carbon, biogenic carbon accounting nuance,
  end-of-life, transport (A4). Mention as "future" only.
- User accounts, server storage, exporting to PDF (stretch at most).
- A comprehensive, certified materials database — the starter set is indicative.

## 12. Stretch goals (only if time allows)
- Save/compare two options side by side with a delta ("Option B is 38% lower").
- Toggle some materials to a "low-carbon variant" (e.g. GGBS concrete, recycled
  steel) to show quick wins.
- Export the detail + result as a shareable URL (encode state in the hash) or a
  copyable summary block.
- A simple bar chart of "carbon per category".

---

## 13. Ready-to-paste build prompt for Claude
> Build a single self-contained `index.html` file — inline CSS and JS, no build
> step, no backend, works offline — implementing the "Detail Carbon" embodied
> carbon calculator described in SPEC.md. Match the dark, polished visual style of
> the existing `index.html` (Inter + Space Mono, `--bg:#0d0d0d`, rounded surfaces,
> pill buttons, the `.strip` bar). Bake in a starter materials database of ~15–20
> common construction materials with representative A1–A3 carbon factors,
> densities, and a source note each, grouped by category, with every factor
> editable in the UI. Implement the layer-based detail builder, live calculation
> (thickness→volume→mass→carbon for volume materials), per-m² and absolute totals,
> a stacked breakdown bar, click-to-copy on result numbers, a non-empty example
> detail on load, and a visible A1–A3 scope + disclaimer + data-source line.
> Verify against the worked example in §10 (200 mm reinforced concrete ≈ 62
> kgCO₂e/m²). Keep accessibility and mobile layout in mind.
