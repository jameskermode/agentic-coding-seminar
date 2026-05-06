#!/usr/bin/env python3
"""Analyse Claude Code co-authored commits across GitHub repos.

Uses `gh` CLI for authentication (5000 req/hr, private repos accessible).
Run via:  uv run github_claude_stats.py

Produces:
    claude_commit_stats.json         per-repo counts + kLOC + categories
    all_commits_timeseries.json      weekly Claude-vs-other buckets
    contribution_calendar.json       daily GitHub contribution counts
    figures/heatmap.png              GitHub-style contribution heatmap
    figures/transition.png           weekly commits with Nov-2025 inflection
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap
from matplotlib.patches import Rectangle

# ── Configuration ─────────────────────────────────────────────────────────────

OWNERS = [
    ("jameskermode", False),
    ("kermodegroup",  True),
    ("libAtoms",      True),
    ("ACEsuit",       True),
    ("HetSys",        True),
]

SINCE_DATE = datetime(2025, 3, 23, tzinfo=timezone.utc)
COMMITS_SINCE = SINCE_DATE.strftime("%Y-%m-%dT%H:%M:%SZ")

# Heatmap window: match GitHub's rolling 365-day view ending today.
HEATMAP_TO = datetime.now(timezone.utc).replace(hour=23, minute=59, second=59, microsecond=0)
HEATMAP_FROM = (HEATMAP_TO - timedelta(days=364)).replace(hour=0, minute=0, second=0)

TRANSITION_MARK = datetime(2025, 10, 1, tzinfo=timezone.utc)

HERE = Path(__file__).parent
CLONE_DIR = Path("/tmp/gitclones")
FIG_DIR = HERE / "figures"

ACCENT = "#005BA1"
ACCENT2 = "#003870"
GH_GREENS = ["#ebedf0", "#9be9a8", "#40c463", "#30a14e", "#216e39"]

plt.rcParams.update({
    "font.family": "Arial",
    "axes.spines.top": False,
    "axes.spines.right": False,
})

# ── gh CLI helpers ────────────────────────────────────────────────────────────

def run(cmd: list[str], check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=check, capture_output=True, text=True)


def preflight_auth() -> None:
    if shutil.which("gh") is None:
        sys.exit("error: `gh` not found. Install it from https://cli.github.com/")
    r = run(["gh", "auth", "status"], check=False)
    if r.returncode != 0:
        sys.exit("error: not logged in. Run:  gh auth login -s repo,read:org")


def gh_token() -> str:
    return run(["gh", "auth", "token"]).stdout.strip()


def gh_api(path: str, *, tolerate_404: bool = False, retries: int = 3) -> list:
    """REST call with pagination; returns a flat list of items.

    Transient failures (non-404) are retried with backoff. 404s are logged
    and return [] when tolerate_404=True; otherwise they raise.
    """
    import time
    last_err = ""
    for attempt in range(retries):
        r = run(["gh", "api", path, "--paginate", "--slurp"], check=False)
        if r.returncode == 0:
            pages = json.loads(r.stdout) if r.stdout.strip() else []
            out = []
            for page in pages:
                if isinstance(page, list):
                    out.extend(page)
                elif isinstance(page, dict) and "items" in page:
                    out.extend(page["items"])
            return out
        last_err = r.stderr
        is_404 = "HTTP 404" in last_err or "status code 404" in last_err.lower()
        if is_404:
            if tolerate_404:
                print(f"    [404] {path} — skipping")
                return []
            raise RuntimeError(f"gh api 404: {path}\n{last_err}")
        # Transient: log and retry.
        print(f"    [attempt {attempt+1}/{retries}] gh api failed: {path}\n"
              f"      {last_err.strip()[:200]}")
        time.sleep(1 + attempt * 2)
    raise RuntimeError(f"gh api failed after {retries} attempts: {path}\n{last_err}")


def gh_graphql(query: str, **variables) -> dict:
    cmd = ["gh", "api", "graphql", "-f", f"query={query}"]
    for k, v in variables.items():
        cmd.extend(["-F", f"{k}={v}"])
    r = run(cmd)
    return json.loads(r.stdout)

# ── Data collection ───────────────────────────────────────────────────────────

def list_repos() -> list[tuple[str, str]]:
    """All repos across the configured owners, filtered by recent activity."""
    repos: list[tuple[str, str]] = []
    for owner, is_org in OWNERS:
        if is_org:
            items = gh_api(f"orgs/{owner}/repos?type=all&per_page=100&sort=updated")
        else:
            # /user/repos returns everything the auth'd user can see;
            # filter to the personal owner only.
            items = gh_api("user/repos?affiliation=owner&per_page=100&sort=updated")
            items = [r for r in items if r["owner"]["login"].lower() == owner.lower()]
        kept = []
        for r in items:
            updated = datetime.fromisoformat(r["updated_at"].replace("Z", "+00:00"))
            if updated > SINCE_DATE:
                kept.append((r["full_name"], bool(r.get("private"))))
        print(f"  {owner}: {len(kept)} repos updated since {SINCE_DATE.date()}")
        repos.extend([(f, _) for f, _ in kept])
    return repos


def get_commits_by_author(full_name: str) -> list[dict]:
    """All commits by jameskermode in the window — Claude and non-Claude alike."""
    path = (
        f"repos/{full_name}/commits"
        f"?author=jameskermode&since={COMMITS_SINCE}&per_page=100"
    )
    items = gh_api(path, tolerate_404=True)
    out = []
    for c in items:
        msg = c.get("commit", {}).get("message", "")
        out.append({
            "repo": full_name,
            "sha": c["sha"][:7],
            "date": c["commit"]["author"]["date"][:10],
            "message": msg.split("\n")[0][:120],
            "claude": ("claude" in msg.lower()
                       and "co-authored-by" in msg.lower()),
        })
    return out


def clone_bare(full_name: str, token: str) -> Path:
    name = full_name.replace("/", "_")
    path = CLONE_DIR / f"{name}.git"
    if not path.exists():
        print(f"  cloning {full_name}…")
        url = f"https://x-access-token:{token}@github.com/{full_name}.git"
        run(["git", "clone", "--bare", "--quiet", url, str(path)], check=False)
    return path


# Extensions that are typically simulation outputs, package locks, or other
# bulk data — not authored source. Exclude from kLOC so one big CASTEP run
# doesn't dwarf a hand-written codebase.
DATA_EXT = {
    # CASTEP / DFT outputs & inputs
    "usp", "castep", "bands", "fs", "dat", "out", "cell", "param",
    # Atomistic trajectories / structures
    "extxyz", "xyz", "traj", "poscar", "cif", "vasp",
    # Structured-data dumps (parity tables, committee samples, etc.)
    "json", "data", "bak",
    # Logs / locks / caches
    "log", "lock", "sum",
    # Embedded documents / images shown as text
    "svg", "pdb", "pdf",
}


def _is_data_file(path: str) -> bool:
    ext = path.rsplit(".", 1)[-1].lower() if "." in path else ""
    return ext in DATA_EXT


def git_numstat(git_dir: Path, shas: list[str]) -> tuple[int, int]:
    total_add = total_del = 0
    for sha in shas:
        r = run(
            ["git", "--git-dir", str(git_dir), "show", "--numstat", "--format=", sha],
            check=False,
        )
        for line in r.stdout.strip().splitlines():
            parts = line.split("\t")
            if len(parts) == 3 and not _is_data_file(parts[2]):
                try:
                    total_add += int(parts[0])
                    total_del += int(parts[1])
                except ValueError:
                    pass  # binary files show '-'
    return total_add, total_del


def fetch_contribution_calendar() -> dict[str, int]:
    query = """query($from:DateTime!,$to:DateTime!){
      user(login:"jameskermode"){
        contributionsCollection(from:$from,to:$to){
          contributionCalendar{
            totalContributions
            weeks{ contributionDays{ date contributionCount } }
          }
        }
      }
    }"""
    data = gh_graphql(
        query,
        **{
            "from": HEATMAP_FROM.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "to": HEATMAP_TO.strftime("%Y-%m-%dT%H:%M:%SZ"),
        },
    )
    cal = data["data"]["user"]["contributionsCollection"]["contributionCalendar"]
    days: dict[str, int] = {}
    for week in cal["weeks"]:
        for d in week["contributionDays"]:
            days[d["date"]] = d["contributionCount"]
    return days

# ── Categorisation ────────────────────────────────────────────────────────────

def categorise(message: str) -> str:
    msg = message.lower()
    categories = {
        "CI/CD & build":  ["ci", "workflow", "build", "wheel", "cibuildwheel",
                           "meson", "deploy", "pypi", "release", "bump version", "ci:"],
        "Bug fixes":      ["fix", "bug", "revert", "workaround", "patch", "bfg:"],
        "Tests":          ["test", "tst:", "tolerance", "integration test"],
        "Documentation":  ["doc", "readme", "tutorial", "comment", "mkdocs", "citation"],
        "New features":   ["add", "implement", "new", "support", "enable",
                           "initial", "phase ", "introduce"],
        "Refactor":       ["refactor", "migrate", "cleanup", "clean up",
                           "simplif", "remove"],
        "API compat":     ["api:", "numpy", "ase", "compatibility", "deprecation"],
        "Performance":    ["optimiz", "performance", "benchmark", "speed",
                           "memory", "fast"],
        "Security":       ["security", "rlimit", "bwrap", "sandbox", "harden"],
        "Demo / viz":     ["demo", "dashboard", "visuali", "plot", "wasm",
                           "marimo", "notebook"],
    }
    for cat, keywords in categories.items():
        if any(k in msg for k in keywords):
            return cat
    return "Other"

# ── Figure rendering ──────────────────────────────────────────────────────────

def _short_repo(full_name: str) -> str:
    return full_name.split("/", 1)[1]


def render_heatmap(days: dict[str, int], path: Path) -> None:
    """GitHub-style contribution heatmap: 53 weeks × 7 days."""
    dates = sorted(days)
    if not dates:
        return
    start = datetime.fromisoformat(dates[0])
    # Align start to the Sunday on or before the first date (GitHub starts weeks on Sunday).
    start -= timedelta(days=(start.weekday() + 1) % 7)
    end = datetime.fromisoformat(dates[-1])

    # Build a 7 × N matrix.
    n_weeks = ((end - start).days // 7) + 1
    grid = np.zeros((7, n_weeks), dtype=int)
    for iso, count in days.items():
        d = datetime.fromisoformat(iso)
        col = (d - start).days // 7
        row = (d.weekday() + 1) % 7  # 0=Sun, 6=Sat
        if 0 <= col < n_weeks:
            grid[row, col] = count

    # Bucket counts → 0..4 for the 5-colour palette.
    max_count = max(1, int(grid.max()))
    thresholds = [0, 1, max(2, max_count // 10), max(4, max_count // 4), max(8, max_count // 2)]
    bucketed = np.zeros_like(grid)
    for i in range(1, 5):
        bucketed[grid >= thresholds[i]] = i

    cmap = ListedColormap(GH_GREENS)
    fig, ax = plt.subplots(figsize=(10, 2.4), dpi=200)
    fig.patch.set_alpha(0)

    cell = 1.0
    gap = 0.12
    for (row, col), bucket in np.ndenumerate(bucketed):
        x = col * (cell + gap)
        y = (6 - row) * (cell + gap)
        ax.add_patch(Rectangle((x, y), cell, cell,
                                facecolor=cmap(bucket), edgecolor="none"))

    # Month labels: one tick at the first column of each month.
    month_ticks: list[tuple[float, str]] = []
    prev_month = None
    for col in range(n_weeks):
        d = start + timedelta(days=col * 7)
        if d.month != prev_month:
            month_ticks.append((col * (cell + gap), d.strftime("%b")))
            prev_month = d.month
    for x, label in month_ticks:
        ax.text(x, 7 * (cell + gap) + 0.1, label,
                ha="left", va="bottom", fontsize=8, color="#444")

    # Day labels: Mon/Wed/Fri.
    for row, label in [(1, "Mon"), (3, "Wed"), (5, "Fri")]:
        y = (6 - row) * (cell + gap) + cell / 2
        ax.text(-0.4, y, label, ha="right", va="center",
                fontsize=8, color="#444")

    ax.set_xlim(-1.2, n_weeks * (cell + gap) + 0.2)
    ax.set_ylim(-0.3, 7 * (cell + gap) + 1.0)
    ax.set_aspect("equal")
    ax.axis("off")

    total = sum(days.values())
    ax.text(0, -0.3, f"{total:,} contributions in the last year",
            ha="left", va="top", fontsize=8, color="#444", style="italic")

    fig.savefig(path, bbox_inches="tight", dpi=200, transparent=True)
    plt.close(fig)


def render_weekly_transition(timeseries: dict[str, dict[str, int]], path: Path) -> None:
    """Smoothed line plot: avg commits/week, Claude vs other, with Oct-2025 line."""
    weeks = sorted(timeseries)
    dates = [datetime.fromisoformat(w).replace(tzinfo=timezone.utc) for w in weeks]
    claude = np.array([timeseries[w]["claude"] for w in weeks], dtype=float)
    other = np.array([timeseries[w]["other"] for w in weeks], dtype=float)

    # 4-week centred rolling mean. Use the actual sample count at each
    # position so the edges aren't deflated by zero-padding (which would
    # make the line dive at the current date as an artifact).
    def rolling(x: np.ndarray, w: int = 4) -> np.ndarray:
        out = np.empty_like(x)
        half = w // 2
        n = len(x)
        for i in range(n):
            lo = max(0, i - half)
            hi = min(n, i + (w - half))
            out[i] = x[lo:hi].mean()
        return out

    claude_smooth = rolling(claude)
    other_smooth = rolling(other)

    fig, ax = plt.subplots(figsize=(14, 2.5), dpi=200)
    fig.patch.set_alpha(0)

    # Faint raw weekly points behind the smoothed lines.
    ax.scatter(dates, claude, s=14, color=ACCENT, alpha=0.25, zorder=2)
    ax.scatter(dates, other, s=14, color="#607D8B", alpha=0.25, zorder=2)

    # Smoothed lines (4-week rolling average).
    ax.plot(dates, claude_smooth, color=ACCENT, linewidth=2.4,
            label="Claude co-authored (4-wk avg)", zorder=3)
    ax.plot(dates, other_smooth, color="#607D8B", linewidth=2.4,
            label="other (4-wk avg)", zorder=3)

    # Vertical inflection marker.
    ax.axvline(TRANSITION_MARK, color=ACCENT2, linestyle="--", linewidth=1.4)
    ymax = max(claude_smooth.max(), other_smooth.max(), claude.max(), other.max())
    ax.text(TRANSITION_MARK + timedelta(days=4), ymax * 0.97,
            "Oct 2025: first sustained Claude usage",
            color=ACCENT2, fontsize=11, weight="bold", va="top")

    # Before/after means.
    cutoff = TRANSITION_MARK
    before_mask = np.array([d < cutoff for d in dates])
    after_mask = ~before_mask
    total = claude + other
    mean_before = total[before_mask].mean() if before_mask.any() else 0
    mean_after = total[after_mask].mean() if after_mask.any() else 0
    claude_share_before = (claude[before_mask].sum() /
                           max(1, total[before_mask].sum())) * 100
    claude_share_after = (claude[after_mask].sum() /
                          max(1, total[after_mask].sum())) * 100
    ax.text(
        0.02, 0.97,
        f"before Oct 2025:  {mean_before:.1f} commits/wk  "
        f"(Claude {claude_share_before:.0f}%)\n"
        f"after:            {mean_after:.1f} commits/wk  "
        f"(Claude {claude_share_after:.0f}%)",
        transform=ax.transAxes, ha="left", va="top",
        fontsize=10, family="monospace",
        bbox=dict(facecolor="white", edgecolor="#CCC", boxstyle="round,pad=0.4"),
    )

    ax.xaxis.set_major_locator(mdates.MonthLocator(interval=2))
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%b %Y"))
    ax.set_ylabel("commits / week")
    ax.set_xlabel("")
    ax.set_ylim(bottom=0)
    ax.legend(loc="upper left", bbox_to_anchor=(0.02, 0.78),
              frameon=False, fontsize=10)
    ax.grid(axis="y", alpha=0.3)

    fig.autofmt_xdate()
    fig.tight_layout()
    fig.savefig(path, bbox_inches="tight", dpi=200, transparent=True)
    plt.close(fig)

# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    preflight_auth()
    CLONE_DIR.mkdir(exist_ok=True)
    FIG_DIR.mkdir(exist_ok=True)
    token = gh_token()

    print("Fetching repo lists…")
    repos_with_priv = []
    for owner, is_org in OWNERS:
        if is_org:
            items = gh_api(f"orgs/{owner}/repos?type=all&per_page=100&sort=updated")
        else:
            items = gh_api("user/repos?affiliation=owner&per_page=100&sort=updated")
            items = [r for r in items if r["owner"]["login"].lower() == owner.lower()]
        kept = []
        for r in items:
            updated = datetime.fromisoformat(r["updated_at"].replace("Z", "+00:00"))
            if updated > SINCE_DATE:
                kept.append((r["full_name"], bool(r.get("private"))))
        print(f"  {owner}: {len(kept)} repos updated since {SINCE_DATE.date()}")
        repos_with_priv.extend(kept)
    print(f"Total repos to scan: {len(repos_with_priv)}\n")

    print("Scanning commits…")
    all_commits: list[dict] = []
    for full_name, _is_priv in repos_with_priv:
        commits = get_commits_by_author(full_name)
        if commits:
            n_claude = sum(1 for c in commits if c["claude"])
            n_other = len(commits) - n_claude
            print(f"  {full_name}: {n_claude} Claude + {n_other} other")
            all_commits.extend(commits)

    claude_commits = [c for c in all_commits if c["claude"]]
    print(f"\nTotal: {len(claude_commits)} Claude + "
          f"{len(all_commits) - len(claude_commits)} other commits")

    print("\nCloning repos and computing line stats…")
    by_repo = defaultdict(list)
    for c in claude_commits:
        by_repo[c["repo"]].append(c["sha"])

    repo_stats: dict[str, dict] = {}
    for repo in sorted(by_repo, key=lambda r: -len(by_repo[r])):
        git_dir = clone_bare(repo, token)
        adds, dels = git_numstat(git_dir, by_repo[repo])
        repo_stats[repo] = {
            "commits": len(by_repo[repo]),
            "additions": adds,
            "deletions": dels,
            "kloc": adds / 1000,
        }

    cat_totals: dict[str, int] = defaultdict(int)
    for c in claude_commits:
        cat_totals[categorise(c["message"])] += 1

    # ── Weekly timeseries (Claude vs other) ──
    def week_start(iso: str) -> str:
        d = datetime.fromisoformat(iso)
        d -= timedelta(days=d.weekday())  # Monday
        return d.strftime("%Y-%m-%d")

    timeseries: dict[str, dict[str, int]] = defaultdict(lambda: {"claude": 0, "other": 0})
    for c in all_commits:
        wk = week_start(c["date"])
        timeseries[wk]["claude" if c["claude"] else "other"] += 1

    first = week_start(SINCE_DATE.strftime("%Y-%m-%d"))
    last = week_start(datetime.now(timezone.utc).strftime("%Y-%m-%d"))
    d = datetime.fromisoformat(first)
    end = datetime.fromisoformat(last)
    while d <= end:
        k = d.strftime("%Y-%m-%d")
        timeseries.setdefault(k, {"claude": 0, "other": 0})
        d += timedelta(days=7)

    # ── Contribution calendar ──
    print("\nFetching contribution calendar…")
    calendar = fetch_contribution_calendar()
    print(f"  {len(calendar)} days · {sum(calendar.values())} total contributions")

    # ── Print summary tables ──
    print("\n" + "=" * 70)
    print("CLAUDE CO-AUTHORED COMMITS BY REPOSITORY")
    print("=" * 70)
    print(f"{'Repo':<45} {'Commits':>8} {'kLOC+':>7} {'kLOC-':>7}")
    print("-" * 70)
    for repo, s in sorted(repo_stats.items(), key=lambda x: -x[1]["commits"]):
        print(f"{repo:<45} {s['commits']:>8} {s['kloc']:>7.1f} "
              f"{s['deletions']/1000:>7.1f}")
    print(f"\n{'TOTAL':<45} {len(claude_commits):>8} "
          f"{sum(s['additions'] for s in repo_stats.values())/1000:>7.1f}")

    print("\n" + "=" * 70)
    print("BY CONTRIBUTION TYPE")
    print("=" * 70)
    for cat, n in sorted(cat_totals.items(), key=lambda x: -x[1]):
        print(f"  {cat:<25} {n:>4}  " + "█" * min(n, 60))

    # ── Save JSONs ──
    (HERE / "claude_commit_stats.json").write_text(json.dumps({
        "generated": datetime.now().isoformat(),
        "since": COMMITS_SINCE,
        "total_commits": len(claude_commits),
        "repos": repo_stats,
        "categories": dict(cat_totals),
        "commits": claude_commits,
    }, indent=2))

    (HERE / "all_commits_timeseries.json").write_text(json.dumps({
        "generated": datetime.now().isoformat(),
        "since": COMMITS_SINCE,
        "weekly": {k: timeseries[k] for k in sorted(timeseries)},
    }, indent=2))

    (HERE / "contribution_calendar.json").write_text(json.dumps({
        "generated": datetime.now().isoformat(),
        "from": HEATMAP_FROM.strftime("%Y-%m-%d"),
        "to": HEATMAP_TO.strftime("%Y-%m-%d"),
        "days": calendar,
    }, indent=2))

    # ── Figures ──
    print("\nRendering figures…")
    render_heatmap(calendar, FIG_DIR / "heatmap.png")
    render_weekly_transition(
        {k: timeseries[k] for k in sorted(timeseries)},
        FIG_DIR / "transition.png",
    )
    print(f"  wrote {FIG_DIR}/heatmap.png")
    print(f"  wrote {FIG_DIR}/transition.png")


if __name__ == "__main__":
    main()
