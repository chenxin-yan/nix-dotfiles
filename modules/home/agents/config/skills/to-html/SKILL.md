---
name: to-html
description: Render a plan, review, design, or any structured topic as a single skimmable HTML file in the current directory, built for visual review (diagrams, charts, stats, side-by-side, tables, callouts) instead of prose. Use whenever the user says "make an html for this", "show me this as a page", "render this as html", "visualize this", "build a review page", "build a dashboard", "/skill:to-html", or when the topic has flows, before/after, trade-offs, file-by-file changes, metrics, quantitative data, or risks that would be faster to grasp visually than to read in chat. Bias toward triggering whenever a wall of text in chat would be harder to skim than a page.
---

# to-html

Produce a **single skimmable HTML file** at `./<slug>.html` so the user can review a topic visually instead of scrolling chat prose.

The artifact is for the user, on their laptop, regenerated cheaply and often. Optimize for **first-paint scannability**, not document depth.

## When to use / when NOT to use

| Use when | Skip when |
|---|---|
| topic has flows, before/after, trade-offs, file-by-file changes, options, risks, metrics | answer fits in a few chat lines |
| user explicitly asks for an html / page / visual | topic is one paragraph of prose explanation |
| there are ≥3 distinct things to compare, list, or sequence | reply is a single bullet list |
| user wants to sit with a plan before approving | user wants conversation, not artifact |

If you would otherwise produce a wall of prose with two headings, **write the prose in chat instead** and don't trigger this skill.

## Output contract

- One file: `./<slug>.html` in the **current working directory**. Overwrite if it exists — regen is cheap.
- The slug is the topic in kebab-case (`auth-refactor-plan`, `pr-42-review`). With no topic, slug = `note`.
- Chat reply is **one line**: the absolute `file://` URL. No bullets, no recap, no "here's how to regenerate."
- The file embeds a regen breadcrumb near the top: `<!-- regen: <verbatim user request> -->`. If the request contains `--`, replace it with `- -` so the comment stays valid.
- Don't try to `open` the file. The user clicks the URL.

## Workflow

1. **Pick blocks** — read `assets/blocks.html`. Decide which of the 9 blocks the topic actually needs. Two- or three-block pages are good. Nine-block pages are a smell.
2. **Start from `assets/template.html`** — copy it, fill in `<title>`, the regen comment, and the Hero. Drop in the blocks you picked.
3. **Toggle optional CDNs in the template** — uncomment the Mermaid `<script>` if any block is a Diagram. Uncomment the highlight.js block if any block contains code. Uncomment the Chart.js block if any block is a Chart. Uncomment the filter `<script>` only if a Matrix has ≥10 rows.
4. **Self-check, write, reply** — run the pre-delivery check below, write the file, reply with only the absolute `file://` URL on its own line.

## The 9 blocks

The output composes from this closed vocabulary. See `assets/blocks.html` for a rendered example of each.

1. **Hero** — exactly once, top of page. `h1` + one-sentence takeaway + small meta strip (date).
2. **Callout** — colored card. Four variants: `info`, `warn`, `risk`, `good`. Body is **≤1 short sentence or a ≤3-item list**.
3. **Compare** — 2-column grid (occasionally 3). Each column: short label + body. For before/after, options, current/proposed.
4. **Diagram** — Mermaid block. Flows, state machines, sequences, small architectures.
5. **Matrix** — table with header row; cells can hold pills. Trade-off matrices, file-by-file change summaries, decision grids.
6. **Steps** — ordered list, optional status pill per step. Plans, walkthroughs, checklists.
7. **Details** — `<summary>` + body collapsed by default. For full diffs, raw output, appendix material. The body itself follows block rules.
8. **Stats** — grid of 2–4 big-number KPI cards (value + label, optional tone + delta). When the topic has headline numbers — counts, latencies, pass rates, sizes — lead with Stats right after the Hero.
9. **Chart** — Chart.js via `<canvas data-chart='…JSON config…'>`. For quantitative data where the *shape* matters: time series, distributions, magnitude comparisons. If exact values matter more than shape, use a Matrix instead. Never chart ≤3 numbers — that's a Stats block.

**Inline vocabulary** (used inside blocks): **pill** (colored status chip), **code** (inline `<code>` or `<pre><code class=language-…>`), **xref** (`<a href="#id">` — the template gives `:target` a free ring-pulse on click).

## Design policy

Blocks give structure; this gives polish. Both are enforced.

- **Hierarchy — squint test.** Not everything deserves equal weight. The one thing the user must take away gets size, space, or color; supporting material stays compact or goes in a Details. If a blurred screenshot of the page wouldn't show what matters, restructure.
- **Color is semantic, not decorative.** Slate for structure. Emerald/amber/rose/sky only where they *mean* good/warn/risk/info. A page where every block is colored says nothing.
- **Anti-slop, hard bans:** gradients, box-shadows for decoration, emojis as bullets or icons, rainbow palettes, `background-clip: text`. Two or more present → redesign, don't patch.
- **Chart discipline:** bar charts start at zero; label axes or the chart is a decoration; one series color from the semantic palette unless series *are* semantically different; no 3D, no donut charts with <4 slices.

**Pre-delivery self-check** (before writing the file):
1. Fewest blocks that carry the message? Any block you could delete without losing meaning — delete it.
2. Does one element visually dominate, and is it the right one?
3. Every optional CDN in the file matches an actual block on the page?
4. No prose `<p>` over ~3 lines outside a Details?

## Hard rules

- The output lives in `cwd`. Never write to `tmp/`, `docs/`, `$TMPDIR`, or any other path.
- Overwrite on slug collision. Don't add timestamp suffixes.
- The main flow is **blocks, not prose**. No `<p>` longer than ~3 lines outside a `Details`.
- Don't invent new block types or layouts. Stick to the 7.
- Tailwind via CDN is always included. Mermaid, highlight.js, and Chart.js are **conditional** — only include them when a block actually uses them.
- Allowed JS: Mermaid init, highlight.js init, Chart.js init (the `data-chart` snippet in the template), and the Matrix filter snippet. **Nothing else.** No theme toggles, no `localStorage`, no ToC observers, no keyboard shortcuts, no "mark reviewed" checkboxes.
- Dark mode is `prefers-color-scheme` only — the user's OS already knows. No toggle button.

## Anti-patterns

- **Recreating a markdown document.** If the topic would fit in a paragraph of chat prose, write the paragraph in chat instead.
- **Block padding.** Don't add blocks the topic doesn't need. The right page has the *fewest* blocks that still carry the message.
- **`<p>` chains.** If you'd write three paragraphs, the right block is almost always Compare, Matrix, Steps, or a Callout list — not prose.
- **Invented layouts.** If content genuinely doesn't fit the 9 blocks, the content doesn't belong in HTML — say so in chat and write prose.
- **Card-wrapping everything.** A page where Hero, three callouts, a table, and a paragraph each sit in an identical bordered card has no hierarchy — the bad-example section in `assets/blocks.html` shows this. Tables and prose can sit directly on the page.
- **Reviving the old interactivity menu.** Theme toggles, persisted `<details>`, "mark reviewed" checkboxes, ToCs, IntersectionObserver active-section highlighting, keyboard shortcuts — all cut on purpose. Don't add them back.
- **Claiming "self-contained".** The file needs Tailwind from CDN, plus Mermaid/highlight when used. Be honest about it.
