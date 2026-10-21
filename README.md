# Effective Agentic Coding for Scientific Computing

Slides from four seminars by [James Kermode](https://warwick.ac.uk/jrkermode), University of Warwick. All four versions share a single Typst source.

| Talk | Audience | Date | Handout |
|------|----------|------|---------|
| **Research version** | Predictive Modelling Discussion Group + HetSys CDT, University of Warwick | 30 April 2026 | [📄 PDF](agentic-coding-seminar-research-handout.pdf) |
| **Brookes version** | Oxford Brookes · AI & Data Analysis Network | 6 May 2026 | [📄 PDF](agentic-coding-seminar-brookes-handout.pdf) |
| **MPIP version** | Max Planck Institute for Polymer Research | 15 June 2026 | [📄 PDF](agentic-coding-seminar-mpip-handout.pdf) |
| **CECAM version** | CECAM Mary Ann Mansigh Lecture *Who writes the code?*, EPFL (online) | 27 October 2026 | [📄 PDF](agentic-coding-seminar-cecam-handout.pdf) |

The research, Brookes and MPIP decks share most of their content. The Brookes version leads with the assessment-design thesis and `mograder` as the worked case study; the research version leads with research-codebase examples (ACEpotentials, LAMMPS, GPU port, Atomistica) and frames `mograder` as a supporting case study. The MPIP version is a trimmed (~45 min) cut of the research version for a computational-science audience: it drops the `mograder` case study and a few detail slides. The CECAM version is a separate 10-minute talk on training the next generation: ace-jax and a Terminal-Bench-Science task as evidence that the human work has moved to asking the questions and deciding what counts as correct, then the HetSys AI policy and `mograder` as a response. Its patterns slide lists headlines only and links back here for the full versions.

Discussion: [LinkedIn post](https://www.linkedin.com/posts/james-kermode-b97147284_effective-agentic-coding-for-scientific-computing-activity-7457797781534011392-N-d9).

## Abstract

Agentic coding tools such as Claude Code, Cursor, and Codex have crossed from novelty into the daily workflows of research groups willing to engage them seriously. Used well, they can migrate legacy Fortran build systems, write numerically validated simulation code, and maintain CI across multi-language stacks; used badly, they hallucinate plausible nonsense at scale.

These talks distil 6 months of hands-on experience, 1,000+ Claude co-authored commits across 26 repositories, and `mograder` as a case study into practical patterns and anti-patterns. The patterns are tool-agnostic; the case studies use Claude Code. (By the CECAM talk in October 2026 the count had reached 2,332 commits across 52 repositories.)

## Disclaimer

The views and experiences in these slides are those of the author personally, in the role of an academic researcher and HetSys CDT director at the University of Warwick. They do not represent the institutional position of the University of Warwick, of the HetSys CDT, or of any funder. Warwick's AI strategy is being developed separately through the appropriate institutional channels.

The talks are reportorial: they describe what worked and what didn't on a specific set of scientific computing projects using a specific set of tools (primarily Claude Code, with reference to Cursor, Codex, and Gemini CLI). The patterns and anti-patterns are tool-agnostic; the cost figures and case studies are illustrative of one researcher's experience, not benchmarks or recommendations.

## How these slides were made

Claude Code (Anthropic) helped produce these slides: drafting Typst layout, analysing GitHub commit history into the bar charts, and catching overflow / formatting issues across the audience variants. I take full responsibility for the content, claims, and recommendations — every figure was verified, every cited statistic chased to source, every fact-claim about my own work double-checked against the underlying repositories. The patterns I recommend in the deck (spec first; red/green TDD; manage context; hoard known-working examples) are the patterns I used to make the deck itself. Commits with substantive AI contribution carry a `Co-Authored-By: Claude` trailer in `git log` — the partial audit trail recommended on the *Responsible Use* slide.

## Build

The decks are written in [Typst](https://typst.app/). Tested on `typst 0.14.2`.

```sh
# Research version
typst compile agentic-coding-seminar-research.typ          # full live deck (phase reveals)
typst compile agentic-coding-seminar-research-handout.typ  # one page per logical slide

# Brookes version
typst compile agentic-coding-seminar-brookes.typ           # full live deck (phase reveals)
typst compile agentic-coding-seminar-brookes-handout.typ   # one page per logical slide

# MPIP version (trimmed ~45 min cut of the research deck)
typst compile agentic-coding-seminar-mpip.typ              # full live deck (phase reveals)
typst compile agentic-coding-seminar-mpip-handout.typ      # one page per logical slide

# CECAM version (separate 10 min talk)
typst compile agentic-coding-seminar-cecam.typ             # full live deck (phase reveals)
typst compile agentic-coding-seminar-cecam-handout.typ     # one page per logical slide
```

All eight shims `#import` `deck` from `agentic-coding-seminar-shared.typ` and invoke it with the appropriate `version` and `handout` arguments.

## Repository contents

```
.
├── agentic-coding-seminar-shared.typ                # single source of truth (all four decks)
├── agentic-coding-seminar-research.typ              # shim → #deck("research")
├── agentic-coding-seminar-research-handout.typ      # shim → #deck("research", handout: true)
├── agentic-coding-seminar-research-handout.pdf      # prebuilt research handout
├── agentic-coding-seminar-brookes.typ               # shim → #deck("brookes")
├── agentic-coding-seminar-brookes-handout.typ       # shim → #deck("brookes", handout: true)
├── agentic-coding-seminar-brookes-handout.pdf       # prebuilt Brookes handout
├── agentic-coding-seminar-mpip.typ                  # shim → #deck("mpip")
├── agentic-coding-seminar-mpip-handout.typ          # shim → #deck("mpip", handout: true)
├── agentic-coding-seminar-mpip-handout.pdf          # prebuilt MPIP handout
├── agentic-coding-seminar-cecam.typ                 # shim → #deck("cecam")
├── agentic-coding-seminar-cecam-handout.typ         # shim → #deck("cecam", handout: true)
├── agentic-coding-seminar-cecam-handout.pdf         # prebuilt CECAM handout
├── figures/
│   ├── heatmap.png                                  # GitHub contribution heatmap
│   ├── transition.png                               # weekly commit transition chart
│   ├── heatmap-2026-10.png, transition-2026-10.png  # Oct 2026 stats re-run
│   ├── heatmap-2y-2026-10.png                       # 2-year heatmap (--heatmap-years 2), CECAM close
│   ├── si-crack-sw-upper-fold.png, hetsys-*.png     # CECAM deck illustrations
│   ├── ukri-epsrc-logo.png                          # EPSRC logo (ukri.org), CECAM close
│   ├── acejax-si-pareto-a100.{json,png}             # ace-jax Si accuracy vs A100 cost (plot_acejax_pareto.py)
│   ├── mograder_commits.png                         # by-repo commit / kLOC bar chart
│   └── repo_qr.png                                  # QR code for the closing slide
├── github_claude_stats.py                           # regenerates the chart figures
├── plot_acejax_pareto.py                            # ace-jax Pareto cut for the CECAM deck
├── docs/superpowers/                                # CECAM design spec and implementation plan
├── LICENSE                                          # CC-BY-4.0
└── README.md
```

The chart figures in `figures/` are produced by `github_claude_stats.py`; if you want to regenerate or adapt them, the script needs `gh auth login -s repo,read:org` and is driven by `uv run`. The QR code points back to this repo and was generated with `qr` (the Python `qrcode` library's CLI).

The CECAM figures come from an October 2026 re-run that leaves the older figures untouched: `uv run github_claude_stats.py --fig-suffix=-2026-10 --heatmap-years 2` (the `=` is needed because the value starts with `-`). That command writes the 2-year heatmap as `heatmap-2026-10.png`; the deck uses a copy saved as `heatmap-2y-2026-10.png`, so the 1-year version is kept. The ace-jax panel is redrawn from `figures/acejax-si-pareto-a100.json` with `uv run --with matplotlib plot_acejax_pareto.py`; the JSON records how its points were extracted from the [ace-jax benchmarks](https://acesuit.github.io/ace-jax/benchmarks/#accuracy-and-cost-silicon). The crack image is a frame of the `si-fracture-fbc` reference-solution movie. The "3D follow-up" row on the benchmark slide summarises an unpublished private-set task, so it gives no name or detailed numbers.

## Acknowledgements

Claude usage for this work was supported by credits from Anthropic's AI for Science program. The HetSys Centre for Doctoral Training is funded by EPSRC (grants EP/S022848/1 and EP/Y035429/1). Thanks to Karsten Jacobsen (DTU Physics) for sharing the AI guidelines that were the starting point for the [HetSys AI policy](https://warwick.ac.uk/fac/sci/hetsys/studentinformationhub/aipolicy/), and to the HetSys staff and students who co-created it. Thanks also to the [Terminal-Bench-Science](https://www.terminal-bench-science.ai/) team and the reviewers of the `si-fracture-fbc` task.

Calculations were performed using the Sulis Tier 2 HPC platform hosted by the Scientific Computing Research Technology Platform at the University of Warwick. Sulis is funded by EPSRC Grant EP/T022108/1 and the HPC Midlands+ consortium.

## References

- Terminal-Bench-Science: cite via its [Zenodo concept DOI](https://doi.org/10.5281/zenodo.22110253).
- GAP-18 silicon dataset: A. P. Bartók, J. Kermode, N. Bernstein and G. Csányi, "Machine learning a general-purpose interatomic potential for silicon", *Phys. Rev. X* **8**, 041048 (2018). [doi:10.1103/PhysRevX.8.041048](https://doi.org/10.1103/PhysRevX.8.041048)
- ACEpotentials.jl: W. C. Witt *et al.* (C. Ortner), "ACEpotentials.jl: A Julia implementation of the atomic cluster expansion", *J. Chem. Phys.* **159**, 164101 (2023). [doi:10.1063/5.0158783](https://doi.org/10.1063/5.0158783)
- pacemaker (PACE): A. Bochkarev, Y. Lysogorskiy, S. Menon, M. Qamar, M. Mrovec and R. Drautz, "Efficient parametrization of the atomic cluster expansion", *Phys. Rev. Materials* **6**, 013804 (2022). [doi:10.1103/PhysRevMaterials.6.013804](https://doi.org/10.1103/PhysRevMaterials.6.013804)
- MACE: I. Batatia, D. P. Kovács, G. N. C. Simm, C. Ortner and G. Csányi, "MACE: Higher order equivariant message passing neural networks for fast and accurate force fields", *Advances in Neural Information Processing Systems* **35** (NeurIPS 2022). [arXiv:2206.07697](https://arxiv.org/abs/2206.07697)
- lammps-jax: A. Gangan, W. C. Witt and M. Kotak, *lammps-jax* (software, v0.2.0, 2026). [doi:10.5281/zenodo.20838694](https://doi.org/10.5281/zenodo.20838694)

## License

Slides, source, and figures are released under [CC BY 4.0](LICENSE). You are welcome to reuse, remix, and adapt with attribution.

## Resources cited in the decks

- Simon Willison — [Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/) (living guide, Feb 2026+)
- Patrick Mineault — [Claude Code for Scientists](https://neuroai.science/p/claude-code-for-scientists) (Jan 2026)
- MIT Missing Semester — [Agentic Coding](https://missing.csail.mit.edu/2026/agentic-coding/) (2026)
- [`obra/superpowers`](https://github.com/obra/superpowers) — skills framework & software methodology
- [`marimo-team/marimo-pair`](https://github.com/marimo-team/marimo-pair) — drop agents inside a running marimo notebook session
- [`mograder`](https://jameskermode.github.io/mograder/) — the case study referenced throughout
