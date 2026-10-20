# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Slides and handouts for four seminars, "Effective Agentic Coding for
Scientific Computing," by James Kermode (University of Warwick). It is a Typst
document project plus one Python figure-generation script — not an application.

## Build

Decks are written in [Typst](https://typst.app/) (tested on `typst 0.14.2`).

```sh
typst compile agentic-coding-seminar-research.typ          # research live deck
typst compile agentic-coding-seminar-research-handout.typ  # research handout
typst compile agentic-coding-seminar-brookes.typ           # Brookes live deck
typst compile agentic-coding-seminar-brookes-handout.typ   # Brookes handout
typst compile agentic-coding-seminar-mpip.typ              # MPIP live deck
typst compile agentic-coding-seminar-mpip-handout.typ      # MPIP handout
typst compile agentic-coding-seminar-cecam.typ             # CECAM live deck
typst compile agentic-coding-seminar-cecam-handout.typ     # CECAM handout
```

The handout PDFs are committed to the repo; the live-deck PDFs are
`.gitignore`d and regenerated locally. After a content change, recompile and
commit the affected handout PDF(s).

There is no test suite or linter. To verify a change, compile every affected
version and check the rendered pages for overflow (text spilling onto an extra
page or running off the 16:9 slide); compilation can succeed even when a slide
overflows.

Regenerate the chart figures in `figures/`:

```sh
uv run github_claude_stats.py   # needs `gh auth login -s repo,read:org`
```

## Architecture

All eight `.typ` shims are one-liners that `#import` `deck` from
`agentic-coding-seminar-shared.typ` and call `#deck(version, handout: ...)`.
**`agentic-coding-seminar-shared.typ` is the single source of truth** — make
content and layout edits there, not in the shims.

`#deck(version, handout)` (defined at the top of the shared file) takes:

- `version` — `"research"`, `"brookes"`, `"mpip"`, or `"cecam"`. The decks share most
  content; audiences diverge at roughly a dozen `#if version == "brookes"`
  blocks (title, the Brookes-only thesis slide, the case-study ordering,
  anti-pattern examples, outlook, guides, responsible-use, closing question).
  Every such block's `else` branch *is* the research content, so a non-Brookes
  version inherits the research deck by falling through. `mpip` is exactly
  this: it reuses the research deck, overriding only the title, responsible-use
  and discussion slides via `else if version == "mpip"`, and is trimmed for
  time — four research slides (heatmap, Commit Analysis, Atomistica, the
  mograder case study) are gated `#if version != "mpip"` so MPIP skips them.
  Conversely, one slide ("Here's one I made earlier...") is gated
  `#if version != "brookes"`. Some overrides are inline inside a shared slide
  (e.g. a single `#if version == "mpip"` bullet in responsible-use), so a slide
  outside any top-level conditional can still differ between versions. When
  editing a slide, check which conditional (if any) it sits in, and recompile
  every version it affects.
- `cecam` is different: a separate 10-minute talk that shares no slides. It
  branches right after the helpers (`#if version == "cecam" [...] else [...]`)
  and the other three decks' slides all sit, unindented, in that `else`.
  Edits inside the cecam branch cannot affect the other decks; edits outside it
  cannot affect cecam. Design and plan: `docs/superpowers/`.
- `handout` — when `true`, every `phased-slide` collapses to its final phase,
  turning the build-up deck into a one-page-per-slide shareable PDF.

### Progressive reveals

`phased-slide(title:, phases:, body)` emits `phases` copies of a slide, passing
the current phase `k` (1..phases) to the `body` lambda. Inside the body, wrap
each block in `phase(k, step, content)`: the block appears on phase `step` and
stays visible after. Hidden blocks are kept with `hide()` so layout does not
reflow between phases. In `handout` mode only the final phase is emitted.

### Styling helpers

The shared file defines its own slide vocabulary near the top — `slide`,
`titleslide`, `sectionslide`, `bullet`, `note`, `warn-block`, `good-block`,
`bad-block`, `codebox`, `twocol`, plus an `accent`/`light`/`warn` colour
palette. Reuse these rather than inlining raw Typst styling, and keep new
slides consistent with the existing ones.

### Figures

`github_claude_stats.py` analyses Claude co-authored commits across the GitHub
orgs listed in its `OWNERS` config. It writes only `figures/heatmap.png` and
`figures/transition.png` (or dated copies with `--fig-suffix=-YYYY-MM`, which
keeps the figures used by already-delivered decks unchanged), plus three JSON sidecars at the **repo root**
(`claude_commit_stats.json`, `all_commits_timeseries.json`,
`contribution_calendar.json`). Those JSON files are neither committed nor
gitignored. `figures/mograder_commits.png` and `figures/repo_qr.png` are not
produced by the script; the QR code came from the `qrcode` library's `qr` CLI.
The shared deck consumes the PNGs via `image("figures/...")`. The script
authenticates through the `gh` CLI.

## Conventions

- Commits with substantive AI contribution carry a `Co-Authored-By: Claude`
  trailer — this is itself the audit trail recommended in the deck.
- `GEMINI.md` covers the same project for Gemini CLI; keep the two roughly in
  sync when project facts change.
