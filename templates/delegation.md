# Delegation brief template

Copy this for every delegation. Fill every field before dispatch. On most platforms a running worker
cannot be steered mid-run, so everything it needs goes in the brief UP FRONT. A brief missing the
lane or the acceptance bar produces boilerplate or the wrong thing built confidently.

Save as a hand-off file `NNNN-manager-to-<role>-<slug>.md` and log it in the delegation index before
dispatch.

---

## Delegation NNNN: <slug>

- From: manager
- To: <role>
- Date: YYYY-MM-DD
- Type: delegation

### Outcome
The result to produce, stated as an outcome, not a task. Not "go build the teams section" but "the
teams section renders every sourced team with photo, region, and links, from live data".

### Scope boundary (in AND out)
- IN: <explicit list of what this delegation covers>
- OUT: <explicit list of what it does NOT cover>. Every noun here is a boundary the worker cannot
  overreach because it was told about it.

### Isolated lane
- Files/globs the worker may write: <exact paths>
- Branch / worktree: <branch name> in <worktree path>
- The worker claims these in SESSIONS.md before touching them. If it needs something outside this
  lane, it hands off to the role that owns that lane rather than reaching across.

### Acceptance bar (stated up front, not discovered at review)
- Correctness bar: <the project's concrete acceptance staples, from the active profile's CORRECTNESS
  BAR section. Stack-neutral example: build and tests green, lint clean, no security regression,
  commit + push + verify live. The concrete bar comes from the profile, not from this template>.
- DEPTH standard (REQUIRED for research/content tasks): what "deep enough" means. e.g.
  multi-paragraph sourced profiles rather than a name-and-link list; every claim carrying its source
  URL and checked-date; the hard cases covered. A thin-but-correct draft that meets a
  correctness-only bar still fails this bar.
- change_class: `auth-data-input` | `presentational` | `static` (this sets the gate set the work will
  face).

### Inputs and assumptions (named)
- Inputs: <live project refs, existing schema, tokens read from env and never printed/committed>.
- Assumptions: <state each one so the worker can correct you if it is wrong instead of silently
  building on it>.

### REQUIRED-TOOLS pre-dispatch checklist (roadblock F13)
Confirm the worker's session actually has the tools the task needs BEFORE dispatch. Do not send a
worker at a wall its tools cannot climb.
- [ ] Tools this task requires: <e.g. a browser for an image hunt; web fetch for sourcing; a shell +
      test runner for a build; DB access for a query>.
- [ ] The assigned role's session has them.
- [ ] Bot-blocked or special-access sources have a workable door named (own-site og:image,
      aggregators, a human), not just "go find images".

### Required hand-off
The worker writes its hand-off file (`templates/handoff.md`) BEFORE handing control back. If it is
not logged, it did not happen and the manager rejects it.
