// ============================================================
// Effective Agentic Coding for Scientific Computing
// James Kermode · School of Engineering, University of Warwick
//
// Two delivered talks share this source:
//   research:  Predictive Modelling Discussion Group + HetSys CDT, Warwick (30 Apr 2026)
//   brookes:   Oxford Brookes · AI & Data Analysis Network        (6 May 2026)
//
// Build (each shim is one line — `#import` + `#deck(...)`):
//   typst compile agentic-coding-seminar-research.typ
//   typst compile agentic-coding-seminar-research-handout.typ
//   typst compile agentic-coding-seminar-brookes.typ
//   typst compile agentic-coding-seminar-brookes-handout.typ
//
// `version` (string) is checked at slides that diverge between audiences:
// title, thesis (brookes-only), the case-study region (mograder-first vs.
// research-first), anti-pattern 2 examples, outlook bullets, lecturer/student
// guide, responsible-use, and the closing discussion question.
//
// `handout: true` collapses every `phased-slide` to its final phase only,
// producing a shareable post-talk PDF without the build-up pages. Reveals are
// recovered automatically because `phase(k, step, content)` returns the
// content as soon as `k >= step`.
//
// Disclaimer: the views in these slides are the author's, not the
// institutional position of the University of Warwick. See README.md.
// ============================================================

#let deck(version, handout: false) = [
#set page(paper: "presentation-16-9", margin: 0pt)
#set text(font: "Arial", size: 20pt)
#set par(leading: 0.65em)

#let accent  = rgb("#005BA1")
#let accent2 = rgb("#003870")
#let light   = rgb("#EEF4FB")
#let warn    = rgb("#FFF3E0")
#let green   = rgb("#E8F5E9")
#let red-bg  = rgb("#FDECEA")
#let code-bg = rgb("#F4F4F4")

// ── helpers ──────────────────────────────────────────────────

#let slide(title: none, body) = page(margin: 0pt, {
  set text(size: 19pt)
  if title != none {
    block(
      fill: accent, width: 100%,
      inset: (x: 1.3em, y: 0.6em),
      text(fill: white, weight: "bold", size: 23pt, title)
    )
  }
  block(width: 100%, inset: (x: 1.6em, y: 0.9em), body)
})

#let titleslide(title, subtitle, author, date, disclaimer: none) = page(
  margin: 0pt,
  fill: accent2,
  {
    set align(horizon)
    block(width: 100%, inset: (x: 2em, y: 0em), {
      text(fill: white, weight: "bold", size: 34pt, title)
      v(0.5em)
      text(fill: rgb("#AACCEE"), size: 22pt, subtitle)
      v(1.5em)
      line(length: 60%, stroke: 0.5pt + rgb("#AACCEE"))
      v(0.6em)
      text(fill: white, size: 18pt, author)
      linebreak()
      text(fill: rgb("#AACCEE"), size: 16pt, date)
      if disclaimer != none {
        v(1.2em)
        text(fill: rgb("#88AACC"), size: 12pt, style: "italic", disclaimer)
      }
    })
  }
)

#let sectionslide(title, subtitle: none) = page(
  margin: 0pt,
  fill: light,
  {
    set align(horizon + center)
    text(fill: accent, weight: "bold", size: 30pt, title)
    if subtitle != none {
      v(0.5em)
      text(fill: gray, size: 20pt, subtitle)
    }
  }
)

#let bullet(body) = {
  grid(
    columns: (1.2em, 1fr), gutter: 0.3em,
    text(fill: accent, weight: "bold", "▸"),
    body
  )
  v(0.2em)
}

#let note(body) = block(
  fill: light, radius: 4pt,
  inset: (x: 1em, y: 0.65em), width: 100%,
  text(size: 17pt, style: "italic", body)
)

#let warn-block(body) = block(
  fill: warn, radius: 4pt,
  inset: (x: 1em, y: 0.65em), width: 100%,
  body
)

#let good-block(body) = block(
  fill: green, radius: 4pt,
  inset: (x: 1em, y: 0.65em), width: 100%,
  body
)

#let bad-block(body) = block(
  fill: red-bg, radius: 4pt,
  inset: (x: 1em, y: 0.65em), width: 100%,
  body
)

#let codebox(content) = block(
  fill: code-bg, radius: 4pt,
  inset: (x: 1em, y: 0.7em), width: 100%,
  text(font: "Monaco", size: 15pt, content)
)

#let twocol(left, right, gutter: 1.4em) = grid(
  columns: (1fr, 1fr), gutter: gutter, left, right
)

// Progressive-reveal helpers. `phased-slide` emits `phases` copies of a slide,
// passing the current phase number `k` (1..phases) to the body lambda. Inside
// the body, wrap each block with `phase(k, step, ...)`: the block appears on
// phase `step` and stays visible thereafter. Hidden blocks still occupy their
// layout space (via `hide()`), so the slide doesn't reflow between phases.
//
// When the deck is invoked with `handout: true`, we emit only the final phase
// of each slide, collapsing build-up pages into a single post-talk page.
#let phased-slide(title: none, phases: 1, body) = {
  if handout {
    slide(title: title, body(phases))
  } else {
    for k in range(1, phases + 1) {
      slide(title: title, body(k))
    }
  }
}
#let phase(k, step, content) = if k >= step { content } else { hide(content) }

// ============================================================
// SLIDES
// ============================================================

// ── 1. Title (version-specific) ──────────────────────────────
#let warwick-disclaimer = "Personal experience as a Warwick academic and HetSys CDT director — not the institutional view of the University of Warwick. Warwick's AI strategy is being developed separately."

#if version == "brookes" [
  #titleslide(
    "AI-assisted coding, assessment design,\nand the agentic AI era",
    "If students can use AI to write code, what are we really assessing?",
    "James Kermode · School of Engineering, University of Warwick",
    "6 May 2026 · Oxford Brookes · AI & Data Analysis Network",
    disclaimer: warwick-disclaimer,
  )
] else [
  #titleslide(
    "Effective Agentic Coding\nfor Scientific Computing",
    "Patterns, pitfalls, and a live case study",
    "James Kermode · School of Engineering, University of Warwick\nPredictive Modelling Discussion Group + HetSys CDT",
    "30 April 2026",
    disclaimer: warwick-disclaimer,
  )
]

// ── 1b. Thesis slide (Brookes only) ──────────────────────────
#if version == "brookes" [
  #slide(title: "Talk Thesis")[
    #v(0.4em)
    #block(fill: light, radius: 4pt, inset: (x: 1.3em, y: 0.9em), width: 100%)[
      #text(size: 21pt, weight: "bold")[
        If students can use AI to write code,
        what are we really assessing?
      ]
      #v(0.5em)
      #text(size: 17pt, style: "italic")[
        One useful way forward: treat *coding as formative*,
        and *understanding as summative*.
      ]
    ]
    #v(0.5em)
    #text(size: 16pt)[
      #bullet[This talk argues that split, and gives a worked example — *mograder* — of what it can look like in practice.]
      #bullet[Plus the patterns and anti-patterns of using Agentic Coding tools well for your own work.]
      #bullet[Audience is mixed: discipline-specific examples where useful, but the assessment question cuts across.]
    ]
  ]
]

// ── 3. Spectrum ───────────────────────────────────────────────
#phased-slide(title: "A spectrum of AI coding tools", phases: 5, k => {
  // Direction indicators always visible
  grid(
    columns: (auto, 1fr, auto), align: horizon, gutter: 0.8em,
    text(size: 14pt, weight: "bold", fill: rgb("#B71C1C"))[Vibe coding],
    align(center)[#text(size: 12pt, fill: gray, style: "italic")[
      increasing context · increasing autonomy · increasing oversight responsibility
    ]],
    text(size: 14pt, weight: "bold", fill: rgb("#1B5E20"))[Agentic engineering],
  )
  v(0.3em)
  // Four stations revealed phase-by-phase; layout space reserved via hide()
  grid(
    columns: (1fr, 1fr, 1fr, 1fr), gutter: 0.6em,
    phase(k, 1, bad-block[
      #text(size: 14pt, weight: "bold")[ChatGPT in browser]
      #v(0.1em)
      #text(size: 12pt)[
        #bullet[Copy/paste both ways]
        #bullet[No project context]
        #bullet[You run the code]
        #bullet[*ChatGPT, Claude.ai*]
      ]
    ]),
    phase(k, 2, block(fill: warn, radius: 4pt, inset: (x: 0.8em, y: 0.55em), width: 100%)[
      #text(size: 14pt, weight: "bold")[Autocomplete in editor]
      #v(0.1em)
      #text(size: 12pt)[
        #bullet[Inline tab-completion]
        #bullet[Current-file context]
        #bullet[You drive every keystroke]
        #bullet[*Copilot, Cursor tab*]
      ]
    ]),
    phase(k, 3, block(fill: light, radius: 4pt, inset: (x: 0.8em, y: 0.55em), width: 100%)[
      #text(size: 14pt, weight: "bold")[Full AI editor]
      #v(0.1em)
      #text(size: 12pt)[
        #bullet[Chat edits files in repo]
        #bullet[Codebase-aware context]
        #bullet[You approve diffs in IDE]
        #bullet[*Cursor, Windsurf*]
      ]
    ]),
    phase(k, 4, good-block[
      #text(size: 14pt, weight: "bold")[Agent]
      #v(0.1em)
      #text(size: 12pt)[
        #bullet[Runs commands, iterates]
        #bullet[Full project context (`CLAUDE.md`)]
        #bullet[Review at task boundaries]
        #bullet[*Claude Code, Codex, Gemini CLI*]
      ]
    ])
  )
  v(0.3em)
  phase(k, 5, note[#text(size: 13pt)[
    Same model can sit behind any of these — the difference is the *harness*: how much context it sees, whether it can act, and where the human reviews. Willison: "Agentic Engineering represents the other end of the scale — professional engineers using coding agents to amplify their existing expertise." Case studies that follow use Claude Code; the patterns themselves are agnostic to which agentic harness you prefer.
  ]])
})

// ── How an LLM chatbot works (precursor to the agentic loop) ──
#slide(title: "How an LLM chatbot works")[
  #twocol(
    [
      *Pseudocode Sketch*
      #codebox(raw(
"messages = [system_prompt, task]

while not done:
    reply = model.generate(messages)

    messages.append(reply.text)
    display(reply.text)
    done = await_user()"
      ))
    ],
    [
      *Key properties*
      #v(0.15em)
      #text(size: 13pt)[
        #bullet[*System prompt* – persistent instructions set by the application #text(fill: rgb("#555"))[(role, tone, safety, format)]]
        #bullet[*`messages`* – full conversation history, replayed on every call; the model has no memory between sessions]
        #bullet[*Context window* – finite tokens per turn \
        #text(fill: rgb("#555"))[(200k-1M tokens, \~150k-750k words)]]
        #bullet[*Sampling* – `generate()` picks tokens probabilistically; same input can give different replies #text(fill: rgb("#555"))[(temperature, top-p)]]
        #bullet[*Knowledge cutoff* – no access to events after training ends]
        #bullet[*No actions* – model cannot run code, read files, or browse the web – only text in, text out]
      ]
      #v(0.2em)
      #note[#text(size: 13pt)[ChatGPT, Claude, Gemini etc. all basially work like this.]]
    ]
  )
]

// ── 3a. The agentic loop ─────────────────────────────────────
#slide(title: "Agentic Loop")[
  #twocol(
    [
      *Pseudocode Sketch*
      #block(
        fill: code-bg, radius: 4pt,
        inset: (x: 1em, y: 0.7em), width: 100%,
        {
          set text(font: "Monaco", size: 15pt)
          set par(leading: 0.45em)
          let hl(body) = highlight(fill: rgb("#b2ff9d"), extent: 2pt, body)
          [
            `messages = [system_prompt, `#hl[`CLAUDE_MD, `]`task]` \
            #hl[`tools    = [Bash, Read, Edit, Write, Grep,`] \
            #hl[`            Glob, WebFetch, WebSearch, Task]`] \
            `while not done:` \
            `    reply = model.generate(messages, ` \
            `                           `#hl[`tools=tools`]`)` \
            #hl[`    if reply.tool_calls:`] \
            #hl[`        for call in reply.tool_calls:`] \
            #hl[`            out = run_tool(call.name,`] \
            #hl[`                           call.args)`] \
            #hl[`            messages.append(`] \
            #hl[`                tool_result(call, out))`] \
            #hl[`    else:`] \
            `        messages.append(reply.text)` \
            `        display(reply.text)` \
            `        done = await_user()`
          ]
        }
      )
    ],
    [
      *Examples of Tools*
      #v(0.15em)
      #text(size: 12pt)[
        #bullet[*Bash* – run a shell command #text(fill: rgb("#555"))[(`pytest -xvs`, `uv run …`, `git log`, `make`)]]
        #bullet[*Read* / *Write* / *Edit* – create or open a file, or do a find-and-replace]
        #bullet[*Grep* – regex-search #text(fill: rgb("#555"))[(e.g. `def test_energy` across `**/*.py`)]]
        #bullet[*Glob* – enumerate files by pattern #text(fill: rgb("#555"))[(`src/**/*.py`)]]
        #bullet[*WebFetch* – pull a specific URL #text(fill: rgb("#555"))[(docs, GitHub issues, papers)]]
        #bullet[*WebSearch* – look up recent/obscure info #text(fill: rgb("#555"))[(post-training data, niche APIs, error message searches)]]
        #bullet[*Task* – spawn a sub-agent with its own context #text(fill: rgb("#555"))[("audit this PR", "find all callers of X"). Can use a cheaper model for sub-tasks.]]
      ]
      #v(0.2em)
      #note[#text(size: 12pt)[The agent is only as capable as its tools. Add an MCP server and it gains a new action; remove `Bash` and it can no longer run code. You can teach it to use new CLI tools (or even write new ones which are agent-friendly, with explanatory docs).]]
    ]
  )
]

// ── Agentic vs. Vibe Coding – key differences ────────────────
// Phase-2 payoff is discipline-specific: "physically correct" for research audiences;
// generalised to domain correctness for the cross-discipline Brookes audience.
#phased-slide(title: "Agentic vs. Vibe Coding – Key Differences", phases: 2, k => {
  phase(k, 1)[
    #bullet[Agent = model + harness that *executes* code and feeds results back]
    #bullet[Core loop is ~200 lines of code, not magic (MIT Missing Semester, 2026)]
    #v(0.4em)
    #warn-block[
    #bullet[*Willison: "Writing code is cheap now"*.]
    #bullet[Typing code into a computer is now almost free.]
    #bullet[Delivering *good* code, which is tested, correct, maintainable, is not.]
    ]
  ]
  phase(k, 2)[
    #v(0.2em)
    #if version == "brookes" [
      #text(size: 17pt)[
        In most disciplines, "correct" means more than "the tests pass":
        #block(fill: rgb("#FFF8E1"), radius: 4pt, inset: 0.6em)[
          #bullet[Code must also be correct *in your domain's sense* – physically, causally, pedagogically.]
          #bullet[No auto-generated test suite fully captures that: that is *your* job.]
        ]
      ]
    ] else [
      For scientific computing, we need to add another dimension:
      #block(fill: rgb("#FFF8E1"), radius: 4pt, inset: 0.8em)[
        #bullet[Code must also be physically correct.]
        #bullet[No auto-generated test suite fully captures that: that is our job.]
      ]
    ]
  ]
})

// ── 3b. Addressing the objections ────────────────────────────
#phased-slide(title: "Common Objections", phases: 4, k => {
  twocol(
    [
      #phase(k, 1)[
        *"AI writes code that doesn't compile"*
        #text(size: 16pt)[
          Zero-shot, no context, wrong language version: yes, often.
          With a `CLAUDE.md` specifying your Python/Julia version, package environment, and a working example to follow: almost never.
          The agent executes and iterates – it sees the compiler error.
        ]
      ]
      #v(0.35em)
      #phase(k, 3)[
        *"Fortran coverage is low"*
        #text(size: 16pt)[
          Correct. Training data is dominated by Fortran 77; modern Fortran 2018 features and fixed/free format confusion are failure modes. My QUIP work in this talk was CI and Python glue, not extensively touching the Fortran. Know your tool's limits.
        ]
      ]
    ],
    [
      #phase(k, 2)[
        *"Zero-shot failures on niche APIs"*
        #text(size: 16pt)[
          Correct. Zero-shot with no context for a specific LAMMPS fix style or ASE calculator is unreliable. Solution: provide a working example from your codebase. The agent recombines; it doesn't (shouldn't) invent.
        ]
      ]
      #v(0.35em)
      #phase(k, 4)[
        *"I tried it and got rubbish"*
        #text(size: 16pt)[
          Almost certainly towards vibe coding end of spectrum: without `CLAUDE.md`, working examples, or iterative feedback. The same person wouldn't hand a junior developer a task with no briefing and be surprised at the output. Capable models also help — recent flagship models from Anthropic, OpenAI, and Google all clear the bar; older or distilled checkpoints often don't.
        ]
      ]
    ]
  )
})

// ── 3c. Harder objections ─────────────────────────────────────
#phased-slide(title: "Harder Objections", phases: 4, k => {
  twocol(
    [
      #phase(k, 1)[
        *"It made me slower, not faster"*
        #text(size: 16pt)[
          A rigorous RCT (METR, July 2025) found experienced open-source developers were *19% slower* with AI tools. The finding is real for tasks where the developer already knows exactly what to do. Gains appear on unfamiliar territory, bridging expertise gaps, and maintenance work. Track time honestly.
        ]
      ]
      #v(0.35em)
      #phase(k, 3)[
        *"It's just regurgitating training data"*
        #text(size: 16pt)[
          Partly fair. For novel algorithms, you are the source of novelty: the agent implements what you specify. That is the spec-first pattern: you design, it codes. The Anthropic C compiler rewrite attracted "code laundering" criticism; for original research, the question is whether your idea/spec is  novel.
        ]
      ]
    ],
    [
      #phase(k, 2)[
        *Skill atrophy: the paradox of supervision*
        #text(size: 16pt)[
          Anthropic internal study (Dec 2025): developers scored *17% lower* on code comprehension tests when using AI to learn a new library. Paradox: effective use of Agentic AI requires supervising Claude, which requires the very skills that atrophy. Practise without AI too!
        ]
      ]
      #v(0.35em)
      #phase(k, 4)[
        *Data privacy and reproducibility*
        #text(size: 16pt)[
          Your code goes to Anthropic's servers – OK for open source code, otherwise not. For sensitive data, local models (Ollama + open weights) are improving rapidly. Hybrid approaches possible.
        ]
      ]
    ]
  )
})

// ── 4. Struggle as pedagogy ───────────────────────────────────
#slide(title: "Pedagogical Tensions")[
  #v(0.2em)
  #twocol(
    warn-block[
      *Struggle as pedagogy*
      #v(0.3em)
      #text(size: 17pt)[
        #bullet[Hitting a confusing error and working through it *is* the learning.]
        #bullet[Friction builds intuition.]
        #bullet[Researchers who never debug never develop a mental model of failure modes.]
      ]
    ],
    good-block[
      *Reducing friction*
      #v(0.3em)
      #text(size: 17pt)[
        #bullet[Remove obstacles that aren't educational.]
        #bullet[Better tools let people spend cognitive load on the science, not boilerplate.]
        #bullet[We don't code in assembly any more!]
        #bullet[AI assistance is now a professional reality in many domains]
      ]
    ]
  )
  #v(0.5em)
  The question is not whether to use AI tools – it is which friction is worth keeping.
]

// ── 4b. Where to draw the line ────────────────────────────────
#phased-slide(title: "Which friction is worth keeping?", phases: 2, k => {
  twocol(
    phase(k, 1)[
      *Worth keeping*
      #v(0.2em)
      #text(size: 17pt)[
        #bullet[Debugging logic errors in your own code]
        #bullet[Understanding *why* a numerical method converges or doesn't]
        #bullet[Choosing the right algorithm for the problem]
        #bullet[Interpreting results physically]
        #bullet[Reviewing/owning every line in a paper or PR]
      ]
    ],
    phase(k, 2)[
      *Worth removing*
      #v(0.2em)
      #text(size: 17pt)[
        #bullet[Boilerplate file I/O and plotting scaffolding]
        #bullet[Looking up library API signatures]
        #bullet[Translating a known algorithm into working syntax, or from one language to another]
        #bullet[Writing tests for behaviour you already understand]
        #bullet[Formatting and docstrings]
      ]
    ]
  )
})

// ── 5b. Speedup by education ──────────────────────────────────
#phased-slide(title: "Speedup grows with expertise – Anthropic Economic Index, Jan 2026", phases: 2, k => {
  v(0.3em)
  grid(columns: (1fr, 1fr), gutter: 1.5em,
    phase(k, 1)[
      *Measured speedup on Claude.ai by task complexity*
      #text(size: 13pt, style: "italic")[(years of schooling required to understand the task)]
      #v(0.3em)
      #let edbar(label, years, speedup, maxspeed, col) = {
        grid(columns: (6.5em, 2.2em, 1fr, 2em), gutter: 0.3em,
          text(size: 13pt, label),
          text(size: 13pt, fill: col, weight: "bold", str(speedup) + "×"),
          block(height: 0.9em, width: (100% * speedup / maxspeed), fill: col, radius: 2pt),
          none
        )
        v(0.2em)
      }
      #edbar("< High school",   10, 7,  20, rgb("#90A4AE"))
      #edbar("High school",     12, 9,  20, rgb("#FFB74D"))
      #edbar("Some college",    14, 10, 20, rgb("#FF8F00"))
      #edbar("College degree",  16, 12, 20, accent)
      #edbar("API (college)",   16, 16, 20, rgb("#1565C0"))
      #v(0.2em)
      #text(size: 12pt, style: "italic")[
        Source: Anthropic Economic Index, Jan 2026 (\~2M Claude conversations, Nov 2025) – *vendor-published, treat as directional*. Speedup = human-alone time / human-with-AI time.
      ]
    ],
    phase(k, 2)[
      *What this means for us as researchers*
      #v(0.3em)
      #text(size: 15pt)[
        #good-block[
         #bullet[More expertise you bring, more you gain.]
         #bullet[A PhD student at the frontier gets more leverage than someone doing routine tasks.]
        ]
        #v(0.2em)
        #bullet[Contradicts "AI levels the playing field" narrative]
        #bullet[Domain knowledge is amplified, not devalued]
        #bullet[The METR 19% slowdown: low end of this curve]
        #bullet[*Caveat*: data tops out at college-level tasks – no direct measurements of PhD-level work. Trend suggests further amplification; nobody has proved it.]
        #v(0.15em)
        #warn-block[
          #text(size: 14pt)[Success rate falls with complexity (70% → 66%). Human oversight becomes more important, not less.]
        ]
      ]
    ]
  )
})

// ============================================================
// CASE-STUDY REGION — diverges heavily between versions
// Both branches are markup-mode content blocks, so `#` prefixes
// on function calls are used exactly as at top level.
// ============================================================

#if version == "brookes" [

  // ── Section break — mograder leads ─────────────────────────
  #sectionslide("mograder — a worked example", subtitle: "Formative coding, summative understanding")

  // ── mograder intro (full, from original teaching deck) ─────
  #phased-slide(title: "mograder", phases: 3, k => {
    phase(k, 1)[#text(size: 16pt)[#good-block[
      *mograder* is an autograder for coding assignments. It provides fast formative feedback on code correctness, and allows summative assessment of understanding via written/oral components.
    ]
    #warn-block[
    *Motivation*
    I want to teach postgraduate students to use AI tools effectively, not ban them.]
    ]]
    twocol(
      phase(k, 2)[
        *The task*
        #v(0.2em)
        #text(size: 16pt)[
          #bullet[Generate / autograde / validate assignments]
          #bullet[Student and grading web interfaces]
          #bullet[Moodle API integration]
          #bullet[Robust security model]
          #bullet[Comprehensive docs · PyPI release · CI/CD]
        ]
      ],
      phase(k, 3)[
        *The setup*
        #v(0.2em)
        #text(size: 16pt)[
          #bullet[Claude Code bare metal on Mac and Linux]
          #bullet[Close supervision – reviewing every change]
          #bullet[Git as the safety net and progress log]
          #bullet[Iterative: short tasks, verify, commit, repeat]
        ]
      ]
    )
  })

  // ── Development process ────────────────────────────────────
  #slide(title: "Development process")[
    #text(size: 16pt)[
      #bullet[I wrote almost no code by hand. Almost every line was generated by Claude Code, and reviewed by me.]
      #bullet[*369 commits over 48 days* · 95% Claude co-authored, 5% manual touch-ups · 30 active days \
        (≈12 commits/day when working on it); busiest day: *36 commits*]
      #bullet[*4 days from empty repo to first tagged release*; released on PyPI after 13 days;\
        36 tagged versions]
     #bullet[*19k lines of Python* (53 modules) + *16k lines of tests* (482 tests, \~25 tests / kLOC src) + 2.5k lines docs]
    ]
    #align(center, image("figures/mograder_commits.png", width: 60%))
  ]

  // ── What the agent was good at ─────────────────────────────
  #slide(title: "What the agent was good at")[
    #bullet[*Boilerplate-heavy infrastructure* – FastAPI routes, SQLite schema, Moodle REST calls, CI/CD YAML configuration, Python packaging.]
    #bullet[*Verifiable tasks* – "does `pytest` pass?", "does `pip install` work?", "does the Moodle token round-trip?", "does the example notebook run/autograde without error?"]
    #bullet[*Recombining known patterns* – PEP 723 metadata + cell-hash embedding merged two things it already understood]
    #bullet[*Documentation and tests* – given a spec, write docstrings and unit tests first]
    #v(0.5em)
    #note[
      The agent is a very fast, tireless junior developer with broad knowledge
      and zero physical intuition.
    ]
  ]

  // ── What required human judgement ──────────────────────────
  #slide(title: "What required human judgement")[
    #bullet[*Security model design* – six-layer defence-in-depth was a deliberate choice (resource limits, timeouts, static safety checks, temp directory isolation, bubblewrap sandbox, integrity checking). The agent would have stopped at "run in a temp dir".]
    #bullet[*Assessment philosophy* – formative coding, summative written and oral components, students must explain code with their name on it. Practical experience with similar tools.]
    #bullet[*Architecture* – Marimo over Jupyter, sidecar JSONL over HTML parsing to extract machine-readable metadata, write-ahead logging (WAL) mode for SQLite operations.]
    #bullet[*Catching agent errors* – plausible-looking but broken async logic; incorrect Moodle API endpoints needed iterative testing and careful review to catch.]
    #v(0.4em)
    #note[
      Agents can deal with the 'How' but not the 'What' or the 'Why'. You cannot delegate the decisions that define what the software is for!
    ]
  ]

  // ── mograder assessment philosophy (new, Brookes-only) ─────
  #slide(title: "mograder — formative / summative separation")[
    #v(0.2em)
    #twocol(
      good-block[
        *Formative — the code*
        #v(0.2em)
        #text(size: 13pt)[
          #bullet[*Release notebook*: students receive the assignment with solutions stripped and check cells pre-populated]
          #bullet[*Instant feedback*: checks run as each cell is completed; an incorrect answer gets partial credit + targeted feedback, not pass/fail]
          #bullet[*Tamper-proof*: edit a check cell and the hash mismatch is detected]
          #bullet[*Workshop mode*: hosted in a static HTML page via WASM: works in a browser, no server or VLE. Instructors can release model solutions live.]
          #bullet[*Low-stakes, fast turnaround*: automated tests.]
        ]
      ],
      warn-block[
        *Summative — the understanding*
        #v(0.2em)
        #text(size: 13pt)[
          #bullet[*Written defence*: students explain their approach — why this algorithm, where it might fail]
          #bullet[*Oral mini-viva*: 10-15 minutes, student walks the marker through their submitted code. Random sample of students, allocated after submission. ]
          #bullet[*The student's name is on it.* It doesn't matter how the code was written; they still have to defend it.]
          #bullet[*Higher-stakes, hard to delegate*: human judgement.]
        ]
      ]
    )
    #note[#text(size: 13pt)[mograder allows delegating *pattern-matching* — did the code produce the right answer? — to the machine, but keeps the *human question* — did the student understand? — for humans.]]
  ]

  // ── Mograder Demo (URLs) ───────────────────────────────────
  #slide(title: "Mograder Demo")[
    #bullet[A *release notebook* – what students receive (solutions stripped, check cells present)]
    #bullet[*Formative checks* run as cells are completed]
    #bullet[An *incorrect* answer gets partial credit + targeted feedback rather than pass/fail]
    #bullet[*Tamper-proof submission*: edit a check cell and the hash mismatch is caught]
    #bullet[*Instructor dashboard*: all assignments, submissions and marks in one view]
    #bullet[*Workshop demo*: example workshop-mode, fully formative and hosted in a static HTML page (via WASM). Instructors can release model solutions live during workshops.]
    #v(0.4em)
    #align(center)[
      #text(size: 17pt)[
      #text(fill: accent2)[*Student dashboard:* #link("https://mograder-demo.jrkermode.uk")[`mograder-demo.jrkermode.uk`]] \
      #text(fill: accent2)[*Instructor dashboard:* #link("https://mograder-demo.jrkermode.uk/grader")[`mograder-demo.jrkermode.uk/grader`]] \
      #text(fill: accent2)[*Workshop demo*: #link("https://jameskermode.github.io/mograder/dashboard/notebooks/demo-workshop.html")[`jameskermode.github.io/mograder/dashboard/notebooks/demo-workshop.html`]]
      ]
    ]
  ]

  // ── Section break — compressed research context ────────────
  #sectionslide("Further examples", subtitle: "A quick tour of my recent AI-assisted codebases")

  // ── Heatmap (phase 1 only for Brookes) ─────────────────────
  #slide(title: "Can you spot when I started using Claude?")[
    #text(size: 13pt)[*GitHub contribution heatmap* (jameskermode · Apr 2025 – Apr 2026)]
    #v(-0.2em)
    #align(center, image("figures/heatmap.png", width: 96%))
  ]

  // ── 1k commits data (single slide for Brookes) ─────────────
  #slide(title: "1k Claude co-authored commits · 246k lines of code")[
    #text(size: 13pt)[
    #grid(columns: (1.15fr, 0.85fr), gutter: 1.2em,
      [
        *By repository — commits (blue) and kLOC added (orange)*
        #v(0.15em)
        #let tickbar(label, color, ticks) = grid(
          columns: (12.5em, 1fr), gutter: 0.4em, align: horizon,
          text(size: 8pt, label),
          stack(dir: ttb, spacing: 1pt,
            block(height: 0.35em, width: 100%, fill: color),
            grid(
              columns: (
                (0.5fr,),
                (1fr,) * (ticks.len() - 2),
                (0.5fr,),
              ).flatten(),
              ..ticks.enumerate().map(((i, t)) => align(
                if i == 0 { left } else if i == ticks.len() - 1 { right } else { center },
                text(size: 7pt, fill: rgb("#555"), str(t))
              ))
            )
          )
        )
        #tickbar("commits",    accent,         (0, 90, 180, 270, 360))
        #tickbar("kLOC added", rgb("#FF8F00"), (0, 20, 40, 60, 80))
        #v(0.2em)
        #let entries = (
          ("mograder",               "CI · bugs · features",  351,  77.4),
          ("HetSys/PX914",           "bugs · features · CI",  205,  74.0),
          ("SciML demos",            "CI · features · bugs",   88,  30.1),
          ("HetSys/isg2026-amentum", "features",               87,   9.8),
          ("ACEpotentials.jl",       "features · bugs · CI",   59,  12.1),
          ("QUIP",                   "CI · bugs (96%)",        45,   2.6),
          ("f90wrap",                "CI · bugs · tests",      42,   1.7),
          ("mograder-tauri",         "bugs · CI · other",      28,   1.8),
          ("audio-player",           "features",               18,   6.0),
          ("matscipy",               "CI · bugs",              18,   0.6),
          ("marimo-precompute",      "even mix",               16,   2.2),
          ("LACT",                   "bugs · features",        10,   1.4),
        )
        #grid(
          columns: (12.5em, 1fr), row-gutter: 7pt, column-gutter: 0.4em, align: horizon,
          ..entries.map(((r, k2, c, l)) => (
            stack(dir: ttb, spacing: 2pt,
              text(size: 10pt, r),
              text(size: 8pt, style: "italic", fill: rgb("#666"), k2),
            ),
            stack(dir: ttb, spacing: 1.5pt,
              block(height: 0.4em, width: (100% * c / 360), fill: accent),
              block(height: 0.4em, width: (100% * l / 80), fill: rgb("#FF8F00")),
            ),
          )).flatten()
        )
        #text(size: 8pt, style: "italic")[26 repos · `git log --numstat` · simulation data excluded · Mar 2025–Apr 2026]
      ],
      [
        *By contribution type*
        #v(0.15em)
        #let cat(label, n, total, col) = grid(
          columns: (8em, 1.8em, 1fr), gutter: 0.3em,
          text(size: 12pt, label), text(size: 12pt, str(n)),
          block(height: 0.75em, width: (100% * n / total), fill: col)
        )
        #cat("CI/CD & build",  252, 260, rgb("#E57373"))
        #cat("Bug fixes",      214, 260, rgb("#FFB74D"))
        #cat("New features",   211, 260, accent)
        #cat("Other",          133, 260, rgb("#B0BEC5"))
        #cat("Documentation",   60, 260, rgb("#81C784"))
        #cat("Demo / viz",      55, 260, rgb("#9575CD"))
        #cat("Tests",           38, 260, rgb("#4DB6AC"))
        #cat("Refactor",        30, 260, rgb("#90A4AE"))
        #cat("API compat",      17, 260, rgb("#A1887F"))
        #v(0.2em)
        #warn-block[
          #text(size: 11pt)[*25% is CI/CD + build infrastructure* – the unglamorous maintenance work that would otherwise never get done.]
        ]
        #v(0.2em)
        #text(size: 12pt, style: "italic")[*Cost log*: \~£400 over 6 months on Claude Max 5× (\~\$2,480 at metered rates). Specialist knowledge made this hard to delegate – counterfactual is "not done", not "done by someone else".]
      ]
    )
    ]
  ]

  // ── Atomistica (second-order effect) — kept per user request
  #phased-slide(title: "Second-order effects: Atomistica", phases: 4, k => {
    phase(k, 1)[
      #text(size: 16pt)[
        #bullet[*Atomistica:* (#link("https://github.com/atomistica/atomistica")[`github.com/atomistica/atomistica`]) Fortran library of interatomic potentials (ASE + LAMMPS compatible)
        maintained by Lars Pastewka in Freiburg.]
        #bullet[`numpy.distutils` removed in Python 3.12 – Atomistica's build system was broken]
        #bullet[I needed it for teaching, and thought it would be a good test of what Claude Code could handle on an unfamiliar Fortran codebase]
      ]
    ]
    twocol(
      phase(k, 2)[
        #good-block[
          *Oct 2025: my meson PR*
          #v(0.15em)
          #text(size: 15pt)[
            Migrated from `numpy.distutils` to Meson + `meson-python`. PR description: *"I did it using Claude Code so some careful testing is required before merging."* Merged with final fixes, Oct 20.
          ]
        ]
      ],
      phase(k, 3)[
        #block(fill: rgb("#F3E5F5"), radius: 4pt, inset: 0.7em)[
          *Dec 2025: Lars starts C++ rewrite*
          #v(0.15em)
          #text(size: 15pt)[
            PR 54: *"Complete rewrite of Atomistica in modern C++."* 72 files · 21,623 lines of new C++ · full reimplementation of all potentials, integrators, neighbour lists.
          ]
        ]
      ]
    )
    phase(k, 4)[
          #text(size: 15pt)[
      #note[Six weeks between "fix our build system" and "rewrite 15 years of Fortran in modern C++" – the willingness to attempt ambitious transformations spreads, across disciplines as well as codebases.]
          ]
    ]
  })

] else [

  // ── Research-version case-study section ────────────────────
  #sectionslide("Research codebases — some worked examples", subtitle: "ACEpotentials.jl · LAMMPS interface · GPU port · Atomistica")

  // ── Heatmap (2 phases) ─────────────────────────────────────
  #phased-slide(title: "Can you spot when I started using Claude?", phases: 2, k => {
    phase(k, 1)[
      #text(size: 13pt)[*GitHub contribution heatmap* (jameskermode · Apr 2025 – Apr 2026)]
      #v(-0.2em)
      #align(center, image("figures/heatmap.png", width: 96%))
    ]
    v(-0.3em)
    phase(k, 2)[
      #text(size: 13pt)[*Weekly commits across 26 repos: Claude co-authored vs other*]
      #v(-0.2em)
      #align(center, image("figures/transition.png", width: 96%))
    ]
  })

  // ── 1k commits (3 phases) ──────────────────────────────────
  #phased-slide(title: "1k Claude co-authored commits · 246k lines of code", phases: 3, k => {
    text(size: 13pt)[
    #grid(columns: (1.15fr, 0.85fr), gutter: 1.2em,
      phase(k, 1)[
        *By repository — commits (blue) and kLOC added (orange)*
        #v(0.15em)
        #let tickbar(label, color, ticks) = grid(
          columns: (12.5em, 1fr), gutter: 0.4em, align: horizon,
          text(size: 8pt, label),
          stack(dir: ttb, spacing: 1pt,
            block(height: 0.35em, width: 100%, fill: color),
            grid(
              columns: (
                (0.5fr,),
                (1fr,) * (ticks.len() - 2),
                (0.5fr,),
              ).flatten(),
              ..ticks.enumerate().map(((i, t)) => align(
                if i == 0 { left } else if i == ticks.len() - 1 { right } else { center },
                text(size: 7pt, fill: rgb("#555"), str(t))
              ))
            )
          )
        )
        #tickbar("commits",    accent,         (0, 90, 180, 270, 360))
        #tickbar("kLOC added", rgb("#FF8F00"), (0, 20, 40, 60, 80))
        #v(0.2em)
        #let entries = (
          ("mograder",               "CI · bugs · features",  351,  77.4),
          ("HetSys/PX914",           "bugs · features · CI",  205,  74.0),
          ("SciML demos",            "CI · features · bugs",   88,  30.1),
          ("HetSys/isg2026-amentum", "features",               87,   9.8),
          ("ACEpotentials.jl",       "features · bugs · CI",   59,  12.1),
          ("QUIP",                   "CI · bugs (96%)",        45,   2.6),
          ("f90wrap",                "CI · bugs · tests",      42,   1.7),
          ("mograder-tauri",         "bugs · CI · other",      28,   1.8),
          ("audio-player",           "features",               18,   6.0),
          ("matscipy",               "CI · bugs",              18,   0.6),
          ("marimo-precompute",      "even mix",               16,   2.2),
          ("LACT",                   "bugs · features",        10,   1.4),
        )
        #grid(
          columns: (12.5em, 1fr), row-gutter: 7pt, column-gutter: 0.4em, align: horizon,
          ..entries.map(((r, k2, c, l)) => (
            stack(dir: ttb, spacing: 2pt,
              text(size: 10pt, r),
              text(size: 8pt, style: "italic", fill: rgb("#666"), k2),
            ),
            stack(dir: ttb, spacing: 1.5pt,
              block(height: 0.4em, width: (100% * c / 360), fill: accent),
              block(height: 0.4em, width: (100% * l / 80), fill: rgb("#FF8F00")),
            ),
          )).flatten()
        )
        #text(size: 8pt, style: "italic")[26 repos · `git log --numstat` · simulation data excluded · Mar 2025–Apr 2026]
      ],
      [
        #phase(k, 2)[
          *By contribution type*
          #v(0.15em)
          #let cat(label, n, total, col) = grid(
            columns: (8em, 1.8em, 1fr), gutter: 0.3em,
            text(size: 12pt, label), text(size: 12pt, str(n)),
            block(height: 0.75em, width: (100% * n / total), fill: col)
          )
          #cat("CI/CD & build",  252, 260, rgb("#E57373"))
          #cat("Bug fixes",      214, 260, rgb("#FFB74D"))
          #cat("New features",   211, 260, accent)
          #cat("Other",          133, 260, rgb("#B0BEC5"))
          #cat("Documentation",   60, 260, rgb("#81C784"))
          #cat("Demo / viz",      55, 260, rgb("#9575CD"))
          #cat("Tests",           38, 260, rgb("#4DB6AC"))
          #cat("Refactor",        30, 260, rgb("#90A4AE"))
          #cat("API compat",      17, 260, rgb("#A1887F"))
          #v(0.2em)
          #warn-block[
            #text(size: 11pt)[*25% is CI/CD + build infrastructure* – the unglamorous maintenance work that would otherwise never get done.]
          ]
        ]
        #v(0.2em)
        #phase(k, 3)[
          #text(size: 12pt, style: "italic")[*Cost log*: \~£400 over 6 months on Claude Max 5× (\~\$2,480 at metered rates). Specialist knowledge made this hard to delegate – counterfactual is "not done", not "done by someone else".]
        ]
      ]
    )
    ]
  })

  // ── Commit Analysis ────────────────────────────────────────
  #phased-slide(title: "Commit Analysis", phases: 2, k => {
    twocol(
      phase(k, 1)[
        *Main activity types:*
        #v(0.2em)
        #text(size: 15pt)[
          #bullet[*Maintaining codebases*: CI/CD, bug fixes, API compat = 47% of commits – work that accumulates as debt otherwise]
          #bullet[*New features*: 211 commits – new ETACE backend in ACEpotentials.jl, Amentum HetSys ISG setup, mograder + tauri wrapper]
          #bullet[*Bridging expertise gaps*: QUIP's 45 commits almost entirely CI/build in a Fortran/Python/Meson stack; f90wrap and matscipy similar]
        ]
      ],
      phase(k, 2)[
        *Four repo archetypes*
        #v(0.2em)
        #text(size: 15pt)[
          #bullet[*Teaching*: highest commit volume – \
          agent as co-developer + infrastructure scaffolder]
          #bullet[*Research*: features + refactoring – \
          agent as collaborator]
          #bullet[*Shared infrastructure* (QUIP, matscipy, f90wrap): \
          CI and bug fixes dominate – agent as \
          maintainer-in-residence]
          #bullet[*Personal tools*: experimental, varied – \
          agent as sketchpad ]
        ]
      ]
    )
  })

  // ── ACEpotentials LAMMPS interface ─────────────────────────
  #phased-slide(title: "ACEpotentials.jl – LAMMPS interface", phases: 4, k => {
    phase(k, 1)[
      #text(size: 16pt)[
      #bullet[*Goal:* deploy trained ACE potentials in LAMMPS for production MD runs]
      #bullet[This used to be possible in older ACEpotentials.jl releases, but support was dropped due to lack of maintainer time to keep the ML-PACE C++ code up to date with ACE and LAMMPS changes]
      #bullet[*Challenge:* bridging Julia and C++, matching LAMMPS pair style conventions]
      ]
    ]
    v(0.2em)
    twocol(
      phase(k, 2)[
        #text(size: 16pt)[
         *First attempt: `juliac --trim`*
          Native compilation of Julia to a shared library via `juliac --trim` – new niche approach, sparse docs. Agent handled boilerplate and iterated on errors; I knew this was the right strategy and validated the force outputs.
        ]
      ],
      phase(k, 3)[
        #text(size: 16pt)[
          *Current: MLIR export*
          Now using MLIR-based compiler pathway with Reactant export to StableHLO. Models callable from Python/JAX or Enzyme C++, giving cleaner interop and better portability. Agent again handled the mechanical translation work; I directed the architectural shift.
        ]
      ]
    )
    v(0.3em)
    phase(k, 4)[
      #text(size: 16pt)[#good-block[
        Both versions: within *2x of hand-optimised C++* – accomplished in days rather than months.
        Agent excels at the foreign-function boundary boilerplate that would otherwise take weeks.
        Good test coverage makes me confident in correctness without needing to analyse every line of the generated code.
      ]]
    ]
  })

  // ── GPU NeighbourLists.jl ──────────────────────────────────
  #phased-slide(title: "GPU port of NeighbourLists.jl", phases: 4, k => {
    phase(k, 1)[
      #bullet[Task: GPU-accelerate `NeighbourLists.jl` for use in ML potential training and inference]
      #bullet[Baseline: single-threaded CPU implementation – a fair comparison point]
    ]
    v(0.3em)
    twocol(
      phase(k, 2)[
        *Agent contribution*
        #text(size: 16pt)[
          #bullet[Translated Julia neighbour-list to GPU kernels]
          #bullet[Handled thread indexing and memory layout]
          #bullet[Generated benchmarking harness]
          #bullet[Iterated on correctness against CPU reference]
        ]
      ],
      phase(k, 3)[
        *Human contribution*
        #text(size: 16pt)[
          #bullet[Understood algorithm well enough to specify it]
          #bullet[Validated correctness of neighbour lists (periodic BCs, cutoff, odd-shaped cells)]
          #bullet[Judged when performance was sufficient]
          #bullet[Integrated into ACEpotentials pipeline]
        ]
      ]
    )
    v(0.3em)
    phase(k, 4)[
      #good-block[
        Result: *100x speedup* over single-threaded CPU.
        Agents surprisingly effective at writing Julia code: mix of high quality training data, language design (e.g. type system).
      ]
    ]
  })

  // ── Atomistica (research, second-order effect) ─────────────
  #phased-slide(title: "Second-order effects: Atomistica", phases: 4, k => {
    phase(k, 1)[
      #text(size: 16pt)[
        #bullet[*Atomistica* (#link("https://github.com/atomistica/atomistica")[`github.com/atomistica/atomistica`]) is a Fortran library of interatomic potentials (ASE + LAMMPS compatible)
        maintained by Lars Pastewka in Freiburg]
        #bullet[`numpy.distutils` removed in Python 3.12 – Atomistica's build system was broken]
        #bullet[I needed it for teaching, and thought it would be a good test to try to fix it with Claude Code]
      ]
    ]
    v(0.25em)
    twocol(
      phase(k, 2)[
        #good-block[
          *Oct 2025: my meson PR*
          #v(0.15em)
          #text(size: 15pt)[
            Migrated from `numpy.distutils` to Meson + `meson-python`. PR description: *"I did it using Claude Code so some careful testing is required before merging."* Merged by Lars with final fixes.
          ]
        ]
      ],
      phase(k, 3)[
        #block(fill: rgb("#F3E5F5"), radius: 4pt, inset: 0.7em)[
          *Dec 2025: Lars starts C++ rewrite*
          #v(0.15em)
          #text(size: 15pt)[
            PR 54: *"Complete rewrite of Atomistica in modern C++."* 72 files · 21k lines of new C++ · full reimplementation of all potentials, integrators, neighbour lists.
          ]
        ]
      ]
    )
    v(0.25em)
    phase(k, 4)[
      #note[Six weeks between "fix our build system" and "rewrite 15 years of Fortran in modern C++" – the willingness to attempt ambitious transformations spreads.]
    ]
  })

  // ── Three ways (research framing) ──────────────────────────
  #phased-slide(title: "Three ways Agentic Coding accelerates research", phases: 4, k => {
    v(0.2em)
    twocol(
      [
        #phase(k, 1)[
          #block(fill: light, radius: 4pt, inset: 0.8em)[
            *1. Rapid prototyping*
            #v(0.2em)
            #text(size: 16pt)[
              The rate-limiting step is often not knowing whether an idea will work.
              Agentic coding enables testing concepts in hours rather than weeks,
              failing fast on unpromising directions.
              This changes the economics of exploration.
            ]
          ]
        ]
        #v(0.4em)
        #phase(k, 2)[
          #block(fill: light, radius: 4pt, inset: 0.8em)[
            *2. Bridging expertise gaps*
            #v(0.2em)
            #text(size: 16pt)[
              For research that spans discipllines,
              agentic coding provides working fluency across domains:
              implementing a sparse GP one day, debugging a LAMMPS Kokkos GPU interface the next.
            ]
          ]
        ]
      ],
      [
        #phase(k, 3)[
          #block(fill: light, radius: 4pt, inset: 0.8em)[
            *3. Maintaining complex codebases*
            #v(0.2em)
            #text(size: 16pt)[
              Research software accumulates technical debt.
              Agentic coding handles refactoring, test coverage, CI, and documentation
              that otherwise gets deferred indefinitely,
              enabling software releases rather than "code available on request."
            ]
          ]
        ]
        #v(0.4em)
        #phase(k, 4)[
          #bad-block[
            *What it won't accelerate*
            #v(0.2em)
            #text(size: 16pt)[
              Formulating research questions.
              Interpreting the physical meaning of results.
              Knowing when something is subtly wrong. \
              All these require domain expertise.
            ]
          ]
        ]
      ]
    )
  })

  // ── Mograder section break (research: supporting role) ─────
  #sectionslide("A larger case study – mograder", subtitle: "AI-assisted tools for AI-assisted learning")

  // ── Mograder compressed intro ──────────────────────────────
  #phased-slide(title: "mograder – a larger case study", phases: 3, k => {
    phase(k, 1)[
      #good-block[
        #text(size: 16pt)[*mograder* is an autograder for coding assignments: fast formative feedback on code correctness, plus summative assessment via written/oral components. Aim to support students to use AI tools effectively.]
      ]
    ]
    v(0.4em)
    phase(k, 2)[
      #twocol(
        text(size: 15pt)[
          *The coding task*
          #bullet[Generate / autograde / validate assignments]
          #bullet[Student and grading web interfaces]
          #bullet[Moodle API integration]
          #bullet[Security model · CI/CD · PyPI release]
        ],
        text(size: 15pt)[
          *The setup*
          #bullet[Claude Code bare metal, close supervision]
          #bullet[Git as safety net and progress log]
          #bullet[Iterative: short tasks, verify, commit, repeat]
          #bullet[Almost all Claude-generated, human-reviewed]
        ]
      )
    ]

    phase(k, 3)[
    #v(0.4em)
    #align(center)[
      #text(size: 17pt)[
      #text(fill: accent2)[*Student dashboard:* #link("https://mograder-demo.jrkermode.uk")[`mograder-demo.jrkermode.uk`]] \
      #text(fill: accent2)[*Instructor dashboard:* #link("https://mograder-demo.jrkermode.uk/grader")[`mograder-demo.jrkermode.uk/grader`]] \
      #text(fill: accent2)[*Workshop demo*: #link("https://jameskermode.github.io/mograder/dashboard/notebooks/demo-workshop.html")[`jameskermode.github.io/mograder/dashboard/notebooks/demo-workshop.html`]]
      ]
    ]
    ]
  })

  // ── Mograder numbers ───────────────────────────────────────
  #phased-slide(title: "mograder – the numbers", phases: 2, k => {
    phase(k, 1)[
      #v(0.2em)
      #text(size: 16pt)[
        #bullet[*369 commits over 48 days* · 95% Claude co-authored · busiest day: 36 commits]
        #bullet[*4 days from empty repo to first tagged release*; released on PyPI after 13 days;\
          36 tagged versions]
        #bullet[*19k lines Python* (53 modules) + *16k lines tests* (482 tests, \~25 tests/kLOC src) + 2.5k lines docs]
      ]
    ]
    v(0.3em)
    phase(k, 2)[
      #align(center, image("figures/mograder_commits.png", width: 72%))
    ]
  })

  // ── Mograder agent strengths vs human judgement (merged) ───
  #slide(title: "mograder – agent strengths vs. human judgement")[
    #twocol(
      good-block[
        *What the agent was good at*
        #v(0.2em)
        #text(size: 14pt)[
          #bullet[*Boilerplate infrastructure* – FastAPI routes, SQLite schema, Moodle REST, CI/CD YAML, Python packaging]
          #bullet[*Verifiable tasks* – does `pytest` pass? does `pip install` work? does the Moodle token round-trip?]
          #bullet[*Recombining known patterns* – PEP 723 metadata + cell-hash embedding merged two things it already understood]
          #bullet[*Docs and tests* – given a spec, write docstrings and unit tests first]
        ]
      ],
      bad-block[
        *What required human judgement*
        #v(0.2em)
        #text(size: 14pt)[
          #bullet[*Security model* – six-layer defence-in-depth (resource limits, timeouts, static checks, sandbox, integrity). Agent would have stopped at "run in a temp dir".]
          #bullet[*Assessment philosophy* – formative coding + summative oral/written; students must explain code with their name on it.]
          #bullet[*Architecture* – Marimo over Jupyter, sidecar JSONL, SQLite WAL mode]
          #bullet[*Catching agent errors* – plausible-looking but broken async, incorrect Moodle API endpoints]
        ]
      ]
    )
    #note[
        #text(size: 14pt)[
      Agents handle the *how*, not the *what* or the *why*. \
      The decisions that define what the software is for cannot be delegated.
        ]
    ]
  ]
]

// ── Wider landscape (shared) ─────────────────────────────────
#phased-slide(title: "The wider landscape: AI agents for science", phases: 5, k => {
  grid(columns: (1fr, 1fr), gutter: 0.8em,
    phase(k, 1)[
      #block(fill: rgb("#E8EAF6"), radius: 4pt, inset: 0.6em)[
        *Anthropic: C Compiler (Feb 2026)* \
        #text(size: 13pt)[
          16 parallel agents, \~2,000 sessions, \$20k → 100k lines of Rust compiling Linux 6.9. *But* Carlini: *"The thought of programmers deploying software they've never personally verified is a real concern."*
        ]
      ]
    ],
    phase(k, 2)[
      #block(fill: rgb("#E8F5E9"), radius: 4pt, inset: 0.6em)[
        *Google: AI Co-Scientist (Feb 2025)* \
        #text(size: 13pt)[
          Multi-agent Gemini 2.0 generates novel hypotheses. Drug-repurposing candidates for AML confirmed in vitro; independently reached an AMR hypothesis that took Imperial years. Beyond literature review: novel suggestions.
        ]
      ]
    ]
  )
  v(0.3em)
  grid(columns: (1fr, 1fr), gutter: 0.8em,
    phase(k, 3)[
      #block(fill: rgb("#FFF8E1"), radius: 4pt, inset: 0.6em)[
        *NVIDIA ALCHEMI (Dec 2025)* \
        #text(size: 13pt)[
          NVIDIA Inference Microservices (NIM) for batched conformer search + MD using MACE-MPA-0, TensorNet, AIMNet2. Universal Display: billions of OLED candidates, 10,000x faster than DFT on CPU. #link("https://github.com/NVIDIA/nvalchemi-toolkit")[Open-source agentic coding toolkit].
        ]
      ]
    ],
    phase(k, 4)[
      #block(fill: rgb("#FCE4EC"), radius: 4pt, inset: 0.6em)[
        *Argonne/RSC: agent (2026)* \
        #text(size: 13pt)[
          Digital Discovery 2026: autonomous MD pipelines – Atomsk, MLIP web-mining, LAMMPS on HPC, OVITO/Phonopy post-processing. All from natural language. "Run the right simulation" remains human territory.
        ]
      ]
    ]
  )
  v(0.25em)
  phase(k, 5)[
    #note[Agents handle mechanical complexity; domain expertise – what to simulate, whether results make sense – remains the human contribution.]
  ]
})

// ── Section break — Patterns ─────────────────────────────────
#sectionslide("Patterns that work", subtitle: "Four tool-agnostic practices with evidence behind them")

// ── Pattern 1: Hoard ─────────────────────────────────────────
#phased-slide(title: "Pattern 1 – Hoard things you know how to do", phases: 3, k => {
  phase(k, 1)[
    #note[
      Simon Willison: \
      "Knowing something is theoretically possible is not the same
      as having seen it done yourself."
    ]
  ]
  v(0.4em)
  phase(k, 2)[
    #bullet[Build a personal library of *working code examples* in your domain]
    #bullet[For me this means things like: canonical Python examples, code input templates, JAX jit patterns, file readers, neural network inference scripts]
    #bullet[Reference them in `CLAUDE.md` or in prompts: "use `~/examples/ace_calc.py` as a pattern for this interface"]
  ]
  v(0.4em)
  phase(k, 3)[
    #good-block[
      Agents only need you to figure out a trick once.
      After that they can recombine it into any similarly shaped future problem,
      including ones you haven't thought of yet.
    ]
  ]
})

// ── Pattern 2: Spec first ────────────────────────────────────
#phased-slide(title: "Pattern 2 – Spec first, implement second", phases: 3, k => {
  phase(k, 1)[
    #text(size: 16pt)[
    #bullet[Write the algorithm in pseudocode or maths before opening a session]
    #bullet[Validate the spec yourself: conserved quantities? edge cases? units?]
    #bullet[Start a new session to implement – clean context, written spec as the prompt, in planning mode first to force design negotiation before any code is written]
    ]
  ]
  phase(k, 2)[
    #if version == "brookes" [
      #codebox(
        raw("# SPEC.md – Score moderation\nInput:  raw 1D marks;  target = (mean, std) OR empirical CDF\nOutput: moderated marks (same length, same shape)\nChoose method: linear (mean+std match), quantile (CDF match), or piecewise linear (fix anchor marks).\nTest invariants:\n  - Spearman(raw, moderated) == 1.0        # rank preserved\n  - monotone non-decreasing over full mark range\n  - |mean(moderated) - target.mean| < 0.1\n  - endpoints fixed if configured: 0 -> 0, 100 -> 100")
      )
    ] else [
      #codebox(
        raw("# SPEC.md – Velocity Verlet integrator\nInput: positions r, velocities v, forces F, timestep dt\n1. v_half = v + 0.5*dt*F/m\n2. r_new  = r + dt*v_half\n3. Recompute F(r_new)\n4. v_new  = v_half + 0.5*dt*F_new/m\n\nTest: NVE total energy drift < 1e-4 eV over 1000 steps (LJ Ar, 94K)")
      )
    ]
  ]
  v(0.3em)
  phase(k, 3)[
    #warn-block[
    Never ask an agent to design the algorithm *and* implement it in one pass.
  ]
  ]
})

// ── Pattern 3: TDD ───────────────────────────────────────────
#phased-slide(title: "Pattern 3 – Red/green TDD", phases: 3, k => {
  phase(k, 1)[
    #bullet[Write tests that *fail for the right reasons* before any implementation]
    #bullet[The agent's job is then unambiguous: make the tests pass]
  ]
  v(0.3em)
  phase(k, 2)[
    For scientific computing, this *forces* you to encode physical correctness explicitly:
    #v(0.2em)
    #codebox(
      raw("def test_energy_conservation():\n    traj = run_md(n_steps=1000, ensemble='NVE')\n    drift = max(traj.energies) - min(traj.energies)\n    assert drift < 1e-4  # eV, LJ argon @ 94K")
    )
  ]
  v(0.3em)
  phase(k, 3)[
    #bullet[*You* must specify the tolerance – the agent cannot guess it]
    #bullet[The test becomes the documentation of what "correct" means]
    #note[
      Willison: "TDD produces more succinct and reliable agent output with minimal extra prompting"
    ]
  ]
})

// ── Pattern 4: Context management ────────────────────────────
#phased-slide(title: "Pattern 4 – Manage context obsessively", phases: 3, k => {
  phase(k, 1)[
    #warn-block[
      *Context degradation is the primary failure mode*.
      Broad consensus is that output quality starts dropping at \~40% of the context window.
    ]
  ]
  v(0.4em)
  phase(k, 2)[
    #bullet[`CLAUDE.md`: short, universally applicable – loads on *every* session]
    #bullet[`/clear` between tasks; `/compact` at natural checkpoints (commits, test passes)]
    #bullet[Similar tools available for other Agentic Coding systems]
    #bullet[Maintain `PROGRESS.md` – update at session end, paste in at session start (or use `git log`)]
  ]
  v(0.3em)
  phase(k, 3)[
    #codebox(
      raw("# PROGRESS.md\nLast session: Zygote AD path implemented, all tests pass\nNext: benchmark vs finite-differences on W (110) surface\nKnown issues: periodic boundary edge case in test_forces_pbc")
    )
  ]
})

// ── Section break — Demo ─────────────────────────────────────
#sectionslide("Demo – Claude Code live", subtitle: "Example but somewhat realistic teaching tool")

// ── Demo 1: prompt ───────────────────────────────────────────
#if version == "brookes" [
  #phased-slide(title: "Claude Code demo – score moderation from scratch", phases: 2, k => {
    let c-spec  = rgb("#C62828")
    let c-tdd   = rgb("#E65100")
    let c-stage = rgb("#00695C")
    let c-hoard = rgb("#1565C0")
    let c-tool  = rgb("#6A1B9A")
    let mark(col, body) = underline(stroke: 1.2pt + col, offset: 2pt, body)
    twocol(
      [
        *The prompt:*
        #v(0.25em)
        #block(
          fill: code-bg, radius: 4pt,
          inset: (x: 1em, y: 0.7em), width: 100%,
          {
            set par(leading: 0.4em)
            if k == 1 {
              text(font: "Monaco", size: 13pt)[Plan then implement a score-moderation utility in Python. Input: raw marks from a cohort (1D array) and a target distribution specified either as (mean, std) or as a target empirical CDF. Output: moderated marks that match the target. Write tests that verify: (i) rank order is preserved exactly (Spearman correlation between raw and moderated = 1.0); (ii) moderated mean is within 0.1 of target mean; (iii) endpoints are fixed if configured (0 → 0, 100 → 100); (iv) the transformation is monotone non-decreasing across the full mark range. Once validated, wrap it to read a Moodle gradebook CSV, produce moderated marks, and emit diagnostic plots (Q-Q plot of raw vs moderated, histogram overlay). Use uv + pyproject.toml, red/green TDD with pytest, numpy + scipy + matplotlib. Ask any clarifications first.]
            } else {
              text(font: "Monaco", size: 13pt)[#mark(c-spec)[Plan then implement] a score-moderation utility in Python. Input: raw marks from a cohort (1D array) and a target distribution specified either as (mean, std) or as a target empirical CDF. Output: moderated marks that match the target. Write tests that verify: (i) rank order is preserved exactly #mark(c-tdd)[(Spearman correlation between raw and moderated = 1.0)]\; (ii) #mark(c-tdd)[moderated mean is within 0.1 of target mean]\; (iii) #mark(c-tdd)[endpoints are fixed if configured (0 → 0, 100 → 100)]\; (iv) #mark(c-tdd)[the transformation is monotone non-decreasing] across the full mark range. #mark(c-stage)[Once validated, wrap it to read a Moodle gradebook CSV], produce moderated marks, and emit diagnostic plots (#mark(c-hoard)[Q-Q plot] of raw vs moderated, #mark(c-hoard)[histogram overlay]). Use #mark(c-tool)[uv] + #mark(c-tool)[pyproject.toml], #mark(c-tool)[red/green TDD] with #mark(c-tool)[pytest], #mark(c-hoard)[numpy + scipy + matplotlib]. #mark(c-spec)[Ask any clarifications first].]
            }
          }
        )
      ],
      phase(k, 2)[
        *Why the prompt is shaped this way:*
        #v(0.3em)
        #text(size: 13pt)[
          #bullet[#text(fill: c-spec, weight: "bold")[Pattern 2 — spec first.] Force the agent to surface the method choice and its downstream decisions (endpoint anchoring, CDF input shape, CSV column discovery) before writing code.]
          #bullet[#text(fill: c-tdd, weight: "bold")[Pattern 3 — red/green TDD.] Four layered invariants — rank, mean, endpoints, monotonicity. *You* decide each tolerance; the agent shouldn't guess them.]
          #bullet[#text(fill: c-stage, weight: "bold")[Staged build-up.] Get the moderation kernel correct in isolation, *then* wire it to the gradebook CSV and plots.]
          #bullet[#text(fill: c-hoard, weight: "bold")[Pattern 1 — hoard.] Name the known-working approaches: Spearman, Q-Q, numpy/scipy/matplotlib.]
          #bullet[#text(fill: c-tool, weight: "bold")[Pattern 4 — tooling \& context.] Conventions baked into the spec (and `CLAUDE.md`) so the agent doesn't reinvent them.]
        ]
      ],
      gutter: 1.2em
    )
  })
] else [
  #phased-slide(title: "Claude Code demo – pair potential from scratch", phases: 2, k => {
    let c-spec  = rgb("#C62828")
    let c-tdd   = rgb("#E65100")
    let c-stage = rgb("#00695C")
    let c-hoard = rgb("#1565C0")
    let c-tool  = rgb("#6A1B9A")
    let mark(col, body) = underline(stroke: 1.2pt + col, offset: 2pt, body)
    twocol(
      [
        *The prompt:*
        #v(0.25em)
        #block(
          fill: code-bg, radius: 4pt,
          inset: (x: 1em, y: 0.7em), width: 100%,
          {
            set par(leading: 0.4em)
            if k == 1 {
              text(font: "Monaco", size: 14pt)[Plan then implement a Lennard-Jones pair potential in Python. It should compute energy and forces for an array of pairwise distances. Write a test that checks the force is the negative gradient of the energy using finite differences, to a tolerance of 1e-6. Once validated, interface to ASE Atoms and the matscipy neighbour list, which allows for efficient vectorised operations rather than a quadratic-scaling double loop. Use uv to setup a new venv and manage deps via pyproject.toml. Use red/green TDD with pytest. Ask any clarifications first.]
            } else {
              text(font: "Monaco", size: 14pt)[#mark(c-spec)[Plan then implement] a Lennard-Jones pair potential in Python. It should compute energy and forces for an array of pairwise distances. Write a test that checks the force is the negative gradient of the energy using finite differences, to a #mark(c-tdd)[tolerance of 1e-6]. #mark(c-stage)[Once validated, interface to ASE Atoms] and the #mark(c-hoard)[matscipy neighbour list], which allows for efficient #mark(c-hoard)[vectorised] operations rather than a #mark(c-hoard)[quadratic-scaling double loop]. Use #mark(c-tool)[uv] to setup a new venv and manage deps via #mark(c-tool)[pyproject.toml]. Use #mark(c-tool)[red/green TDD] with #mark(c-tool)[pytest]. #mark(c-spec)[Ask any clarifications first].]
            }
          }
        )
      ],
      phase(k, 2)[
        *Why the prompt is shaped this way:*
        #v(0.3em)
        #text(size: 13pt)[
          #bullet[#text(fill: c-spec, weight: "bold")[Pattern 2 — spec first.] Force the agent to negotiate the design before writing a line.]
          #bullet[#text(fill: c-tdd, weight: "bold")[Pattern 3 — red/green TDD.] You must specify the tolerance; the agent shouldn't guess it.]
          #bullet[#text(fill: c-stage, weight: "bold")[Staged build-up.] Get the standalone kernel correct in isolation before plumbing it into a framework.]
          #bullet[#text(fill: c-hoard, weight: "bold")[Pattern 1 — hoard.] Hand the agent the names of approaches you already know work.]
          #bullet[#text(fill: c-tool, weight: "bold")[Pattern 4 — tooling \& context.] Conventions baked into the spec (and `CLAUDE.md`) so the agent doesn't reinvent them.]
        ]
      ],
      gutter: 1.2em
    )
  })
]

// ── Demo 1: reflection (research-only) ───────────────────────
// Research: authentic LJ reflection from the actual session.
// Brookes: reflection slide cut for time. The score-moderation
// demo earlier in the deck is presented as a static walkthrough
// (raw prompt → annotated prompt) without a live run, so a
// reflection follow-up is no longer needed.
#if version != "brookes" [
  #phased-slide(title: "Here's one I made earlier...", phases: 2, k => {
    twocol(
      phase(k, 1)[
        *Where I had to steer*
        #v(0.2em)
        #text(size: 14pt)[
          #bullet[Claude's first plan was numpy-only; I asked for second JAX-only one. I asked for both hand-derived + autodiff, co-validated. The dual-path design came from that correction – not the prompt.]
          #bullet[Benchmarks showed native ASE was competitive with JAX. Flagging that as suspicious was my job. The agent measures what you point it at.]
          #bullet[*Red/green in practice:* every red test was an import or bad kwarg. The 1e-6 FD test passed on first green. No physics bug ever surfaced via TDD.]
        ]
      ],
      phase(k, 2)[
        *Where the agent surprised me*
        #v(0.2em)
        #text(size: 14pt)[
          #bullet[Its first clarifying question offered the cutoff-shift options unprompted ("shifted: energy continuous at `r_c`, forces discontinuous") – *Pattern 2* (spec first) paying off immediately.]
          #bullet[After the ASE anomaly, Claude diagnosed the cause itself: "19 of 20 MD steps have different pair counts, so JAX re-jits every call" – and implemented pad-to-max-size unprompted.]
          #bullet[Skills (`brainstorming`, `test-driven-development`, `verification-before-completion`), task lists, and memory notes ran the session autonomously after the plan changes – no `/clear` needed.]
        ]
      ],
      gutter: 1.2em
    )
    v(0.15em)
    phase(k, 2)[
      #text(size: 10pt, style: "italic", fill: rgb("#555"))[`claude-opus-4-6` · 7 user turns · 116 tool calls · 31 tests · 2 backends agree to 1e-12. *Session cost*: \~\$15 at metered API rates (\~\$2–3 amortised on a Max subscription). Equivalent agent work is feasible on any frontier-model harness — Cursor, Codex, Gemini CLI.]
      #v(0.1em)
      #text(size: 10pt, style: "italic", fill: rgb("#555"))[*Energy* – forward-pass work is on \~623 k *fresh* tokens (cached reads are KV lookups, \~0). Rough guess \~*0.1–1 kWh across the session* – a few kettle-boils. Dwarfed by one DFT run. JAX+padded kernel is 7.8× faster than ASE native LJ: one MD campaign repays it many times.
      Repo: #link("https://github.com/jameskermode/LJ-demo")[`github.com/jameskermode/LJ-demo`]]
    ]
  })
]

// ── Section break — Anti-patterns ────────────────────────────
#sectionslide("Anti-patterns", subtitle: "Where it's especially easy to go wrong")

// ── Anti-pattern 1 — Unreviewed code (shared) ────────────────
#phased-slide(title: "Anti-pattern 1 – Unreviewed code on collaborators", phases: 3, k => {
  phase(k, 1)[
    #note[
      Willison: "If you open a PR with code you haven't validated yourself,
      you're delegating your actual work to other people who could have
      prompted an agent themselves."
    ]
  ]
  v(0.4em)
  phase(k, 2)[
    In a research group context:
    #bullet[Don't push simulation code to a shared repo without running it and understanding it]
    #bullet[Review the *PR description* too: agents write convincing summaries]
    #bullet[Include evidence of testing: a benchmark plot, diff against reference data, timing numbers]
  ]
  v(0.4em)
  phase(k, 3)[
    #bad-block[
      *The principle:* You are responsible for code with your name on it,
      regardless of how it was produced: in a paper, a PR, or your thesis.
    ]
  ]
})

// ── Anti-pattern 2 — Trust (version-specific examples) ───────
#if version == "brookes" [
  #phased-slide(title: "Anti-pattern 2 – Trusting output you can't verify", phases: 3, k => {
    phase(k, 1)[
      The software version: agent writes plausible-looking but broken async logic.

      *Discipline-specific versions are more dangerous:*
      #bullet[*Data analysis*: a regression that runs without error but inverts signs on a categorical coding – numbers are produced, conclusions invert]
      #bullet[*Science / engineering*: wrong units in a physical calculation]
      #bullet[*Any domain*: library API that "works" but with semantics subtly different from expected]
    ]
    v(0.4em)
    phase(k, 2)[
      #note[
        Mineault (2026): "A clear skill from scientific training is the ability to call
        bullshit. Have the agent generate lots of diagnostic plots – individually
        low-utility, collectively they convince you the data is correct."
      ]
    ]
    phase(k, 3)[
      The agent has no notion of disciplinary plausibility. That's up to us.
    ]
  })
] else [
  #phased-slide(title: "Anti-pattern 2 – Trusting output you can't verify", phases: 3, k => {
    phase(k, 1)[
      The software version: agent writes plausible-looking but broken async logic.

      *The scientific version is more dangerous:*
      #v(0.3em)
      #bullet[LAMMPS `pair_style` with wrong parameterisation – runs without error, wrong physics]
      #bullet[ASE constraints that silently don't constrain what you think]
      #bullet[Units error in force constants: eV/Å vs eV/Å², off by a factor of ~3.8 Å]
    ]
    v(0.4em)
    phase(k, 2)[
      #note[
        Mineault (2026): "A clear skill from scientific training is the ability to call
        bullshit. Have the agent generate lots of diagnostic plots – individually
        low-utility, collectively they convince you the data is correct."
      ]
    ]
    phase(k, 3)[
      The agent has no notion of physical plausibility. That's up to us.
    ]
  })
]

// ── Anti-pattern 3 — Stateful notebooks (shared) ─────────────
#phased-slide(title: "Anti-pattern 3 – Stateful notebooks", phases: 3, k => {
  phase(k, 1)[
    #note[
      Mineault (2026): "Jupyter notebooks don't play well with agents: plots are
      embedded as base64, eating context, and agents don't know the state of your kernel."
    ]
  ]
  v(0.4em)
  twocol(
    phase(k, 2)[
      #bad-block[
        *Jupyter problems*
        #text(size: 16pt)[
          #bullet[Hidden kernel state]
          #bullet[Base64 plots bloat context window]
          #bullet[Cell execution order ambiguity]
          #bullet[Agent can't verify its own output]
        ]
      ]
    ],
    phase(k, 3)[
      #good-block[
        *Solutions*
        #text(size: 16pt)[
          #bullet[*Marimo*: reactive execution, no hidden state]
          #bullet[`/marimo-pair` agent tool to edit and run cells]
          #bullet[CLI scripts + PNGs for data pipelines]
          #bullet[Notebooks only for final, linear narrative]
        ]
      ]
    ]
  )
})

// ── Anti-pattern 4 — Over-engineering by default (shared) ────
#phased-slide(title: "Anti-pattern 4 – Over-engineering by default", phases: 3, k => {
  phase(k, 1)[
    #note[
      Models are trained to be agreeable. The agent will never tell you a feature
      is unnecessary, never say "you're done", never suggest you stop. Combined with
      build cost being near-zero, this creates a strong pull toward over-engineering.
    ]
  ]
  v(0.4em)
  twocol(
    phase(k, 2)[
      #bad-block[
        *Symptoms*
        #text(size: 16pt)[
          #bullet[Speculative features no one asked for]
          #bullet[Defensive code / fallbacks for cases that can't happen]
          #bullet[Premature abstractions and helper layers]
          #bullet["While we're here..." scope creep]
          #bullet[Endless polish – the agent always finds one more thing]
        ]
      ]
    ],
    phase(k, 3)[
      #good-block[
        *Antidotes*
        #text(size: 16pt)[
          #bullet[Spec the *stop condition* up front; declare done when the spec is met]
          #bullet[Treat agreeable suggestions skeptically – push back, ask "do we need this?"]
          #bullet[Periodically prune: delete unused code, undo speculative abstractions]
          #bullet[Resist the temptation of "just one more iteration"]
        ]
      ]
    ]
  )
})

// ── Outlook (version-specific) ───────────────────────────────
#if version == "brookes" [
  // Trimmed 5→3 bullets for time. Dropped: training-pipeline bullet
  // (overlaps with the lecturer guide later) and the AI-literacy bullet
  // (already in the closing summary).
  #let bullets = (
    [*The substitution ratio.* \~6 months of infrastructure work for \~£400 of Claude Max subscription vs \~£30–60k of postdoc-equivalent labour. Close to two orders of magnitude.],
    [*"Substitution" isn't quite the right frame.* Most of this work needed specialist domain knowledge that couldn't be cleanly delegated. Most would simply not have been done – closer to "new capability" than "redirected costs".],
    [*New grant line item:* "AI tooling" alongside compute costs, with consequences for how RSE/PDRA costs are justified and how their day-to-day roles develop.],
    [*Where do early-careers learn?* Unglamorous CI / build / maintenance and small new features was always how junior researchers built expertise. If agents do it, the training pipeline needs reworking (who will supervise the agents?)],
    [*Domain expertise is the bottleneck.* Leverage shifts to people who know the field, and what is possible. ],
    [*None of these have settled answers.* We are running an uncontrolled experiment in real time!]
  )
  #phased-slide(title: "Outlook – implications for research and teaching", phases: bullets.len(), k => {
    v(0.2em)
    text(size: 16pt)[
      #for i in range(k) [#bullet(bullets.at(i))]
    ]
  })
] else [
  // Outlook bullets list (research). The unannounced "Warwick trial" bullet
  // that exists in the live talk has been removed for the public version.
  #let bullets = (
    [*The substitution ratio.* I've done \~6 months of infrastructure work for ~£400 of Claude Max subscription (≈ \$2500 at per-token API rates) vs ~£30–60k of postdoc-equivalent labour. Close to two orders of magnitude.],
    [*"Substitution" isn't quite the right frame.* Most of this work required specialist domain knowledge that couldn't be cleanly delegated. Most of it would simply not have been done – closer to "new capability" than "redirected costs".],
    [*Plausible new grant line item:* "AI tooling" alongside HPC compute costs, with consequences for how RSE/PDRA costs are justified and how their day-to-day roles develop.],
    [*Where do early-careers learn?* Unglamorous CI / build / maintenance and small new features was always how junior researchers built tacit expertise. If agents do it, the training pipeline needs reworking – not least so the next generation can supervise the agents at all.],
    [*Domain expertise is the bottleneck.* Leverage shifts toward people who already know the field, and know what should be possible – with knock-on effects for PhD supervision, PDRA career structures, and the value of institutional knowledge.],
    [*None of these have settled answers.* We are running an uncontrolled experiment in real time!]
  )
  #phased-slide(title: "Outlook – funding & training implications", phases: bullets.len(), k => {
    v(0.2em)
    text(size: 14pt)[
      #for i in range(k) [#bullet(bullets.at(i))]
    ]
  })
]

// ── The metacognition problem (shared) ───────────────────────
#slide(title: "Back to Struggle-as-Pedagogy")[
  #v(0.25em)
  #block(fill: light, radius: 4pt, inset: (x: 1.2em, y: 0.8em), width: 100%)[
    #text(size: 16pt, style: "italic")[
      "Using the tools proficiently is feasible when you have gone through the hard work of writing your own code by yourself, failing repeatedly, picking yourself back up; I don't know of another way of getting to that level of metacognition.
      #v(0.3em)
      How do you develop that when the AI is making the mistakes for you, invisibly?
      #v(0.3em)
      This is likely to be a challenge for junior researchers as the tools get commoditized."
    ]
    #v(0.3em)
    #text(size: 13pt, style: "italic", fill: rgb("#555"))[— Patrick Mineault, *Claude Code for Scientists* (Jan 2026)]
  ]
  #v(0.5em)
  #warn-block[
    *Open question:*
    #v(0.15em)
    #text(size: 16pt)[
      How do we help new researchers develop metacognition about code when failure is abstracted away?
      #v(0.15em)
      No settled answer - here's my partial idea...
    ]
  ]
]

// ── Stage-by-stage guide (version-specific: PhD vs lecturer) ─
#if version == "brookes" [
  #phased-slide(title: "Provisional Advice for Lecturers", phases: 2, k => {
    phase(k, 1)[
      #block(fill: light, radius: 4pt, inset: 0.75em, width: 100%)[
        #text(size: 14pt)[
          *For your own prep and marking*
          #v(0.15em)
          #bullet[Delegate: conversion between handouts and slide decks, worked-example generation, first-draft marking rubrics, synthetic test data, feedback templates]
          #bullet[Don't delegate: grade judgements on individual students, exam writing, references, confidential correspondence]
          #bullet[An agent can produce 20 variants of a practice question in minutes — useful for randomised coursework]
        ]
      ]
    ]
    phase(k, 2)[
      #block(fill: light, radius: 4pt, inset: 0.75em, width: 100%)[
        #text(size: 14pt)[
          *In your course design*
          #v(0.15em)
          #bullet[Which assessments can you redesign around the assumption students have AI access?]
          #bullet[Which genuinely need invigilation, oral components, or structured defence?]
          #bullet[Assignment briefs should name what's allowed — silence defaults to "everyone's guessing"]
          #bullet[Stage permission: foundational exercises without AI, later work with AI + a written or oral defence]
        ]
      ]
    ]
  })

  #phased-slide(title: "Provisional Advice For Students", phases: 2, k => {
    phase(k, 1)[
      *UG and PGT* - metacognition problem most acute, risk losing 'productive struggle'
      #text(size: 13pt)[
        #bullet[Engage department/school on policy early. "Evolving" is the honest status of most UK-HE AI guidance in 2026]
        #bullet[Declaration policy in your course handbook, not left to the last-minute reminder]
        #bullet[Teach your students to supervise the agent, not just to prompt it. That is the key skill]
      ]
    ]
    phase(k, 2)[
      *PhD students* - build intuition in years 1-2, leverage in years 3-4
      #text(size: 13pt)[
          #bullet[Do the core foundational exercises in training and first research projects manually]
          #bullet[Friction here builds the mental model of failure modes you will need later to supervise an agent]
          #bullet[Start hoarding working examples as you go (Pattern 1) – future-you will thank present-you!]
          #bullet[Fine to use AI for boilerplate (plotting, file I/O, CI, docstrings) from day one (in my opinion, check supervisor's view)]
          #bullet[Spec-first becomes essential – novel work means you are the source of novelty, not the agent]
          #bullet[Delegate the mechanical: input scaffolding, API wrangling, figure plotting, benchmarking harnesses]
          #bullet[Keep one regular "no-AI" problem for skill maintenance – recall the Dec-2025 Anthropic comprehension result]
          #bullet[Red/green TDD against relevant domain, not just code: the agent cannot guess your tolerances]
      ]
    ]
  })
] else [
  #phased-slide(title: "Provisional Advice for PhD students", phases: 3, k => {
    phase(k, 1)[
      #block(fill: light, radius: 4pt, inset: 0.75em, width: 100%)[
        #text(size: 14pt)[
          *Year 1–2: build intuition first*
          #v(0.15em)
          #bullet[Do the core foundational exercises in training and first research projects manually]
          #bullet[Friction here is educational: it builds the mental model of failure modes you will need later to supervise an agent]
          #bullet[Start hoarding working examples as you go (Pattern 1) – future-you will thank present-you!]
          #bullet[Fine to use AI for boilerplate (plotting, file I/O, CI, docstrings) from day one (in my opinion, check supervisor's view)]
        ]
      ]
    ]
    phase(k, 2)[
      #block(fill: light, radius: 4pt, inset: 0.75em, width: 100%)[
        #text(size: 14pt)[
          *Year 3+: leverage, carefully*
          #v(0.15em)
          #bullet[Spec-first becomes essential – novel work means you are the source of novelty, not the agent]
          #bullet[Delegate the mechanical: input scaffolding, API wrangling, figure plotting, benchmarking harnesses]
          #bullet[Keep one regular "no-AI" problem for skill maintenance – recall the Dec-2025 Anthropic comprehension result]
          #bullet[Red/green TDD against *physics* (or other relevant domain), not just code: the agent cannot guess your tolerances]
        ]
      ]
    ]
  })
]

// ── Responsible Use (version-specific: Warwick-anchored vs. generic) ──
#if version == "brookes" [
  #slide(title: "Guidance on Responsible Use of AI in Research")[
    #v(0.25em)
    #text(size: 14pt)[
      #bullet[Declare substantive AI use following funder, publisher, and institutional policy: UKRI permits AI usage in proposal writing with caution, Wellcome requires declaration, most publishers want a line in Methods or Code Availability.]
      #bullet[Most existing policies were written for prose, not code. If generated code shaped a result, disclose it.]
      #bullet[You are responsible for every equation, figure, and line of code with your name on it. If an agent contributed, you need to understand and verify that contribution.]
      #bullet[Reproducibility is even more important in the AI age: pinned dependencies, fixed random seeds, good tests. `git log` with Claude trailers is a partial audit trail, I suggest keeping it.]
      #bullet[Never paste confidential material into standard LLMs without agreement of co-authors/collaborators, because of the risk of data leakage: unpublished manuscripts, industry-partner data, student work, proposals or papers you are reviewing. UKRI specifically prohibits AI in proposal review; most publishers prohibit it for manuscript review.]
      #bullet[Agree conventions with your collaborators and co-authors early; set expectations with your students in the course handbook, not after the fact.]
      #bullet[Most UK universities have an institutional AI policy, or are drafting one in 2026 — check yours for approved tools, data-handling rules, and any enterprise-licensed assistant your institution provides.]
    ]
  ]
] else [
  #slide(title: "Guidance on Responsible Use of AI in Research")[
    #v(0.25em)
        #text(size: 14pt)[
        #bullet[Declare substantive AI use following funder, publisher, and university policy: UKRI permits AI usage in proposal writing with caution, Wellcome requires declaration, most publishers want a line in Methods or Code Availability.]
        #bullet[Most existing policies were written for prose, not code. If generated code shaped a result, disclose it.]
        #bullet[You are responsible for every equation, figure, and line of code with your name on it. If an agent contributed, you need to understand and verify that contribution.]
        #bullet[Reproducibility is even more important in the AI age: pinned dependencies, fixed random seeds, good tests. `git log` with Claude trailers is a partial audit trail, I suggest keeping it.]
        #bullet[Never paste confidential material into standard LLMs without agreement of co-authors/collaborators, because of the risk of data leakage: unpublished manuscripts, industry-partner data, proposals or papers you are reviewing. UKRI specifically prohibits AI in proposal review; most publishers prohibit it for manuscript review.]
        #bullet[Agree conventions with your supervisor/collaborators early.]
        #bullet[At Warwick, advised to use MS Copilot for university information as there's a data security agreement in place. If you are not using university information, you may use other AI assistants, provided you have the correct licence to access them.]
        #note[#text(size: 14pt)["If you want to generate generic computer code that does not contain any university information, you may use any AI assistant, provided you have the correct license to do so." #link("https://warwick.ac.uk/services/ris/research-integrity/airesearch/")[warwick.ac.uk/services/ris/research-integrity/airesearch]]]
    ]
  ]
]

// ── Summary (shared, placed just before Discussion so it's the final synthesis) ──
#phased-slide(title: "Summary", phases: 5, k => {
  twocol(
    [
      #phase(k, 1)[
        *Three acceleration mechanisms*
        #v(0.15em)
        #text(size: 15pt)[
          #bullet[*Rapid prototyping* – explore and fail fast]
          #bullet[*Bridging expertise gaps* – fluency across domains]
          #bullet[*Maintaining codebases* – control technical debt]
        ]
      ]
      #v(0.3em)
      #phase(k, 2)[
        *Four patterns*
        #text(size: 15pt)[
          #bullet[Hoard]
          #bullet[Spec first]
          #bullet[Red/green TDD]
          #bullet[Manage context]
        ]
      ]
    ],
    [
      #phase(k, 3)[
        *Four anti-patterns*
        #v(0.15em)
        #text(size: 15pt)[
          #bullet[Dumping unreviewed code on collaborators]
          #bullet[Trusting output you haven't physically verified]
          #bullet[Stateful notebooks]
          #bullet[Over-engineering by default]
        ]
      ]
      #v(0.3em)
      #phase(k, 4)[
        *What Agentic Coding won't accelerate*
        #v(0.15em)
        #text(size: 15pt)[
          #bullet[Formulating questions]
          #bullet[Interpreting physical meaning]
          #bullet[Knowing when something is subtly wrong]
        ]
      ]
    ]
  )
  phase(k, 5)[
    #block(fill: accent2, radius: 4pt, inset: 0.7em, width: 100%,
      text(fill: white, size: 16pt,
        [Writing code is cheap now. Delivering *correct* code – and *knowing* it's correct – is not. \
        Domain expertise is what turns a capable agent into a useful scientific instrument.]
      )
    )
  ]
})

// ── Discussion (version-specific) ────────────────────────────
#if version == "brookes" [
  #slide(title: "Discussion")[
    #v(1em)
    #block(fill: light, radius: 6pt, inset: 1.4em, width: 100%)[
      #text(size: 21pt, weight: "bold")[
        In your discipline, what can a student now do with AI that we used to call evidence of understanding?
      ]
      #v(0.8em)
      #text(size: 18pt, style: "italic", fill: rgb("#444444"))[
        And what still counts?
      ]
    ]
  ]
] else [
  #slide(title: "Discussion")[
    #v(1em)
    #block(fill: light, radius: 6pt, inset: 1.4em, width: 100%)[
      #text(size: 21pt, weight: "bold")[
        Where in your own research would you trust an agent's output without verification –
        and where would you never trust it?
      ]
      #v(0.8em)
      #text(size: 18pt, style: "italic", fill: rgb("#444444"))[
        What is the difference between those two cases?
      ]
    ]
  ]
]

// ── Resources (shared) ───────────────────────────────────────
#slide(title: "Resources")[
  #grid(
    columns: (1fr, 1fr), gutter: 1.4em,
    [
      *Guides & writing*
      #v(0.2em)
      #text(size: 13pt)[
        #bullet[*Simon Willison* – Agentic Engineering Patterns (Feb 2026+)
          #linebreak()#text(size: 11pt, fill: accent)[#link("https://simonwillison.net/guides/agentic-engineering-patterns/")[simonwillison.net/guides/agentic-engineering-patterns/]]]
        #bullet[*Patrick Mineault* – Claude Code for Scientists (Jan 2026)
          #linebreak()#text(size: 11pt, fill: accent)[#link("https://neuroai.science/p/claude-code-for-scientists")[neuroai.science/p/claude-code-for-scientists]]]
        #bullet[*MIT Missing Semester* – Agentic Coding (2026)
          #linebreak()#text(size: 11pt, fill: accent)[#link("https://missing.csail.mit.edu/2026/agentic-coding/")[missing.csail.mit.edu/2026/agentic-coding/]]]
        #bullet[*mograder* – the case study
          #linebreak()#text(size: 11pt, fill: accent)[#link("https://jameskermode.github.io/mograder/")[jameskermode.github.io/mograder/]]]
      ]
    ],
    [
      *Claude Code plugins*
      #v(0.2em)
      #text(size: 13pt)[
        #bullet[*obra/superpowers* – skills framework & methodology
          #linebreak()#text(size: 11pt, fill: accent)[#link("https://github.com/obra/superpowers")[github.com/obra/superpowers]]]
        #bullet[*marimo-team/marimo-pair* – agents inside a marimo notebook
          #linebreak()#text(size: 11pt, fill: accent)[#link("https://github.com/marimo-team/marimo-pair")[github.com/marimo-team/marimo-pair]]]
      ]
    ],
  )
  #v(0.5em)
  #grid(
    columns: (auto, 1fr), gutter: 1.4em, align: horizon,
    image("figures/repo_qr.png", width: 3.2cm),
    [
      #text(size: 16pt, weight: "bold")[Slides + source for both decks]
      #v(0.2em)
      #text(size: 14pt, fill: accent)[
        #link("https://github.com/jameskermode/agentic-coding-seminar")[github.com/jameskermode/agentic-coding-seminar]
      ]
      #v(0.15em)
      #text(size: 12pt, style: "italic", fill: rgb("#666"))[Released under CC-BY-4.0 · slides themselves produced with Claude Code (see README).]
    ],
  )
]

] // end of #let deck(version, handout: false) = [...]
