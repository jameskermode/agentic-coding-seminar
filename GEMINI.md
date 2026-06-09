# GEMINI.md - Agentic Coding Seminar Project

This project contains the source files for three seminars on "Effective Agentic Coding for Scientific Computing" delivered by James Kermode. The decks are written in [Typst](https://typst.app/) and share a common source.

## Project Overview

- **Main Goal:** Deliver presentation slides and handouts for three seminar versions: "Research" (Warwick), "Brookes" (Oxford Brookes), and "MPIP" (Max Planck Institute for Polymer Research — a trimmed ~45 min cut of the Research deck).
- **Core Stack:** Typst (for documents), Python (for data analysis/figures), `uv` (for Python management).
- **Architecture:** 
    - `agentic-coding-seminar-shared.typ`: The single source of truth for all three decks.
    - Shim files (e.g., `agentic-coding-seminar-research.typ`) import the shared deck and configure it.
    - `github_claude_stats.py`: Analyzes Claude-authored commits across multiple repos to produce charts in the `figures/` directory.

## Building and Running

### Slides and Handouts (Typst)
Requires `typst` (tested on 0.14.2).

```bash
# Research version (Presentation / Handout)
typst compile agentic-coding-seminar-research.typ
typst compile agentic-coding-seminar-research-handout.typ

# Brookes version (Presentation / Handout)
typst compile agentic-coding-seminar-brookes.typ
typst compile agentic-coding-seminar-brookes-handout.typ

# MPIP version (Presentation / Handout)
typst compile agentic-coding-seminar-mpip.typ
typst compile agentic-coding-seminar-mpip-handout.typ
```

### Statistics and Figures (Python)
Requires `uv` and `gh` CLI (authenticated).

```bash
# Regenerate chart figures (heatmap.png, transition.png, etc.)
uv run github_claude_stats.py
```

## Key Files

- `agentic-coding-seminar-shared.typ`: Contains the `#deck(version, handout: false)` function and all slide content.
- `github_claude_stats.py`: Python script for GitHub API analysis and `matplotlib` rendering.
- `figures/`: Contains the generated images used in the slides.
- `README.md`: Original project documentation.

## Development Conventions

- **Shared Source:** Always modify `agentic-coding-seminar-shared.typ` for content changes unless they are specific to a single version shim.
- **Version Shims:** Use the `version` variable (`"research"`, `"brookes"`, `"mpip"`) within the shared source to toggle version-specific content (e.g., `#if version == "brookes" [...]`). Each conditional's `else` branch is the research content, so `mpip` inherits the research deck; it overrides only via `else if version == "mpip"` and is trimmed by gating slides with `#if version != "mpip"`.
- **Phased Slides:** Use `phased-slide` and `phase(k, step, content)` for progressive reveals in the presentation.
- **Figure Regeneration:** If repo statistics change, run `github_claude_stats.py` to update the figures. Ensure `gh` is logged in (`gh auth login`).
- **Commits:** Follow the "Co-Authored-By: Claude" convention for substantive AI contributions.
