#!/usr/bin/env python3
"""Slide-sized cut of ace-jax's silicon accuracy-cost figure (panel B: A100 cost
vs QoI error) for the CECAM deck: five ladders, larger text.

Reads figures/acejax-si-pareto-a100.json (the points extracted from ace-jax's
bench/si_qoi/plot_cost.py; see its "source" field) and writes
figures/acejax-si-pareto-a100.png.

    uv run --with matplotlib plot_acejax_pareto.py
"""

from __future__ import annotations

import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import matplotlib.ticker as mticker  # noqa: E402

HERE = Path(__file__).parent
DATA = HERE / "figures" / "acejax-si-pareto-a100.json"
OUT = HERE / "figures" / "acejax-si-pareto-a100.png"

INK, MUTED, GRID = "#1f2328", "#57606a", "#e6e6e6"
# ace-jax's own family styles (plot_cost.py FAM), so the cut matches the docs figure
STYLE = {  # family: (legend label, colour, marker, linestyle, filled)
    "ace":     ("linear ACE (ace-jax)",      "#2a78d6", "o", "-",  True),
    "ace_tab": ("linear ACE, run by ML-PACE", "#2a78d6", "*", ":",  True),
    "pace":    ("PACE (pacemaker)",          "#eda100", "^", "-",  True),
    "mace_L0": ("MACE, L=0",                 "#4a3aa7", "D", "--", False),
    "mace_L1": ("MACE, L=1",                 "#4a3aa7", "D", "-",  True),
}


def main() -> None:
    d = json.loads(DATA.read_text())
    fig, ax = plt.subplots(figsize=(5.4, 2.5), dpi=200)
    fig.patch.set_alpha(0)

    for fam, (label, col, mk, ls, filled) in STYLE.items():
        pts = d["series"][fam]["points"]
        ax.plot([p["cost_us"] for p in pts], [p["qoi"] for p in pts], ls=ls, lw=2, color=col,
                marker=mk, ms=8 if mk == "*" else 6, mfc=col if filled else "white", mec=col,
                mew=1.5, label=label, zorder=3)

    ax.axhline(d["target_qoi"], color=MUTED, lw=1.2, ls="--", zorder=2)
    ax.text(0.99, d["target_qoi"], "target", transform=ax.get_yaxis_transform(),
            ha="right", va="bottom", fontsize=10, color=MUTED)

    ax.set_xscale("log")
    ax.set_yscale("log")
    for axis, ticks in ((ax.xaxis, [0.2, 0.5, 1, 2, 5]), (ax.yaxis, [0.3, 0.5, 1, 2, 3])):
        axis.set_major_locator(mticker.FixedLocator(ticks))
        axis.set_major_formatter(mticker.FormatStrFormatter("%g"))
        axis.set_minor_formatter(mticker.NullFormatter())
    ax.set_xlabel("A100 GPU cost (µs / atom / MD step)", fontsize=10.5, color=INK)
    ax.set_ylabel("QoI error vs DFT", fontsize=10.5, color=INK)
    ax.tick_params(labelsize=10, colors=MUTED)
    ax.grid(True, which="major", color=GRID, lw=0.8)
    ax.set_axisbelow(True)
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
    for s in ("left", "bottom"):
        ax.spines[s].set_color(MUTED)
    ax.legend(loc="upper right", frameon=False, fontsize=9, labelcolor=INK, handlelength=2.2, borderaxespad=0.2)

    fig.tight_layout()
    fig.savefig(OUT, dpi=200, transparent=True)
    print("wrote", OUT)


if __name__ == "__main__":
    main()
