# Effective Agentic Coding for Scientific Computing

Slides from two delivered seminars by [James Kermode](https://warwick.ac.uk/jrkermode), University of Warwick. Both versions share a single Typst source.

| Talk | Audience | Date | Handout |
|------|----------|------|---------|
| **Research version** | Predictive Modelling Discussion Group + HetSys CDT, University of Warwick | 30 April 2026 | [📄 PDF](agentic-coding-seminar-research-handout.pdf) |
| **Brookes version** | Oxford Brookes · AI & Data Analysis Network | 6 May 2026 | [📄 PDF](agentic-coding-seminar-brookes-handout.pdf) |

The two decks share most of their content. The Brookes version leads with the assessment-design thesis and `mograder` as the worked case study; the research version leads with research-codebase examples (ACEpotentials, LAMMPS, GPU port, Atomistica) and frames `mograder` as a supporting case study.

## Abstract

Agentic coding tools such as Claude Code, Cursor, and Codex have crossed from novelty into the daily workflows of research groups willing to engage them seriously. Used well, they can migrate legacy Fortran build systems, write numerically validated simulation code, and maintain CI across multi-language stacks; used badly, they hallucinate plausible nonsense at scale.

These talks distil 6 months of hands-on experience, 1,000+ Claude co-authored commits across 26 repositories, and `mograder` as a case study into practical patterns and anti-patterns. The patterns are tool-agnostic; the case studies use Claude Code.

## Disclaimer

The views and experiences in these slides are those of the author personally, in the role of an academic researcher and HetSys CDT director at the University of Warwick. They do not represent the institutional position of the University of Warwick, of the HetSys CDT, or of any funder. Warwick's AI strategy is being developed separately through the appropriate institutional channels.

The talks are reportorial: they describe what worked and what didn't on a specific set of scientific computing projects using a specific set of tools (primarily Claude Code, with reference to Cursor, Codex, and Gemini CLI). The patterns and anti-patterns are tool-agnostic; the cost figures and case studies are illustrative of one researcher's experience, not benchmarks or recommendations.

## Build

The decks are written in [Typst](https://typst.app/). Tested on `typst 0.14.2`.

```sh
# Research version
typst compile agentic-coding-seminar-research.typ          # full live deck (phase reveals)
typst compile agentic-coding-seminar-research-handout.typ  # one page per logical slide

# Brookes version
typst compile agentic-coding-seminar-brookes.typ           # full live deck (phase reveals)
typst compile agentic-coding-seminar-brookes-handout.typ   # one page per logical slide
```

All four shims `#import` `deck` from `agentic-coding-seminar-shared.typ` and invoke it with the appropriate `version` and `handout` arguments.

## Repository contents

```
.
├── agentic-coding-seminar-shared.typ                # single source of truth (both decks)
├── agentic-coding-seminar-research.typ              # shim → #deck("research")
├── agentic-coding-seminar-research-handout.typ      # shim → #deck("research", handout: true)
├── agentic-coding-seminar-research-handout.pdf      # prebuilt research handout
├── agentic-coding-seminar-brookes.typ               # shim → #deck("brookes")
├── agentic-coding-seminar-brookes-handout.typ       # shim → #deck("brookes", handout: true)
├── agentic-coding-seminar-brookes-handout.pdf       # prebuilt Brookes handout
├── figures/
│   ├── heatmap.png                                  # GitHub contribution heatmap
│   ├── transition.png                               # weekly commit transition chart
│   ├── mograder_commits.png                         # by-repo commit / kLOC bar chart
│   └── repo_qr.png                                  # QR code for the closing slide
├── github_claude_stats.py                           # regenerates the chart figures
├── LICENSE                                          # CC-BY-4.0
└── README.md
```

The chart figures in `figures/` are produced by `github_claude_stats.py`; if you want to regenerate or adapt them, the script needs `gh auth login -s repo,read:org` and is driven by `uv run`. The QR code points back to this repo and was generated with `qr` (the Python `qrcode` library's CLI).

## License

Slides, source, and figures are released under [CC BY 4.0](LICENSE). You are welcome to reuse, remix, and adapt with attribution.

## Resources cited in the decks

- Simon Willison — [Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/) (living guide, Feb 2026+)
- Patrick Mineault — [Claude Code for Scientists](https://neuroai.science/p/claude-code-for-scientists) (Jan 2026)
- MIT Missing Semester — [Agentic Coding](https://missing.csail.mit.edu/2026/agentic-coding/) (2026)
- [`obra/superpowers`](https://github.com/obra/superpowers) — skills framework & software methodology
- [`marimo-team/marimo-pair`](https://github.com/marimo-team/marimo-pair) — drop agents inside a running marimo notebook session
- [`mograder`](https://jameskermode.github.io/mograder/) — the case study referenced throughout
