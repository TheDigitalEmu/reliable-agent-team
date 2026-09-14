# Team rulebook

The rules the whole team obeys, every session. Terse and imperative on purpose. The reasoning lives
in `why/reasoning.md`; this file is the law, not the argument. Copy it into a new project
as-is. It carries no project specifics: the stack, correctness bar, model assignment, and any
project-only hooks come from the active profile under `profiles/` (see `profiles/example.md`).

Punctuation and any similar output-style policy is a project choice. If the active profile sets one
(see its PROJECT HOOKS section), it is enforced by a project-supplied hook, not by core.

---

## 0. Integrity mandate (overrides everything below)
- Honesty over deference. State the correct answer first, even when it is not the one the owner
  signalled they wanted.
- Best practice first. Do not ship the easy-but-wrong thing because it is faster or quieter.
- Never change an answer to please. Never round "built" up to "done" or "pushed" up to "merged".
- Report the gap, not the round number. An honest limit outranks a confident overclaim.

## 1. Done means verified live
- Nothing is "done" without fresh evidence gathered at this moment from reality: a live check (URL
  returns 200, page renders), a git check (on `origin/main`, not just pushed), a database query, or a
  code read.
- "The agent said so" and "I remember building it" are NOT evidence.
- Built is not done. Pushed is not merged. Passed-once is not still-passing.
- The done-check script is the arbiter. Done is its exit code, not an agent's judgment. Run
  `scripts/done-check` before you say done.

## 2. The gate model (independent lenses, producer never signs off)
- Three lenses, each held by an agent that did NOT do the work:
  - reviewer reads the CODE (quality, scope conformance, tests present, no dead code).
  - security attacks the SURFACE (authz, secrets, data-access rules, input validation, injection,
    SSRF, security headers).
  - qa RUNS the app (build, server, real browser, a11y, test suite, dependency audit).
- The agent that produced the work NEVER signs it off. The agent that reports a fix never gates the
  fix. `scripts/gate-check` verifies PASS author is not work author; self-sign-off fails the gate.
- A FAIL is a hard stop, not advice. A pre-push (or pre-merge) hook blocks unless the required gates
  have a logged PASS for this exact commit SHA.
- A PASS is bound to a commit. New commits on a gated tip invalidate the PASS; re-gate.

## 3. Change-class rule (which changes need which gates)
Every hand-off carries a `change_class` field. It decides the gate set:
- `auth-data-input` : touches auth, data access, or user input. Needs reviewer AND security AND qa.
- `presentational` : interactive or visual UI with no auth, no data path, no new sink. Needs reviewer
  AND qa. (Security may run a scoped pass to CONFIRM it is presentational; that confirmation is worth
  having.)
- `static` : inert content (copy, a legal page, sourced facts). Needs reviewer only.
- Apply in order: touches auth/data/input? -> all three, stop. Else has runtime behaviour a user
  drives? -> reviewer + qa. Else inert content -> reviewer. When in doubt, add the gate.

## 4. Coordination protocol (physical isolation plus a claim ledger)
- One git worktree per session, created INSIDE the repo at `.worktrees/<session>` (gitignored), never
  in the parent root. Worktrees in the parent (`../<repo>-x`) spread stray folders across the owner's
  filesystem (a real incident this kit was built from) and are forbidden. Remove each worktree and kill
  its dev server the moment its job ends. The main checkout stays on the integration branch as
  reference. Never run feature work in a shared checkout while another session is alive in it.
- Never move a shared checkout's branch (checkout, switch, reset, stash, rebase) while another
  session is active in it. That is the exact move that silently wipes another session's work.
- Read `SESSIONS.md` on wake. Write your claim (files/globs + branch) BEFORE you touch anything.
  Commit the claim immediately. Clear it on finish or park.
- Overlap check before every file touch and git op: is this file in another session's active claim?
  If yes, do not touch it, coordinate first.
- End every unit committed AND pushed. Unpushed literally cannot read as done (`scripts/done-check`
  fails while `git log origin/BRANCH..HEAD` is non-empty).
- Union-resolve the bookkeeping ledgers (SESSIONS, TASKS, GATES, delegation log). Both appended rows
  survive. The only judgment is a numbering collision: renumber one, leave a `note` row.
- Before any risky history op, cut a backstop tag (`backup/<what>-<date>`).

## 5. Delegation and logging
- Every delegation carries: outcome, scope boundary (in AND out), isolated lane (files/globs +
  branch), acceptance bar stated UP FRONT (including a DEPTH standard for research/content), inputs
  and assumptions, and a REQUIRED-TOOLS pre-dispatch check. Use `templates/delegation.md`.
- The worker writes its hand-off file BEFORE handing control back. If it is not logged, it did not
  happen; the manager rejects unlogged work. Use `templates/handoff.md`.
- Match the specialist to the task. The producer never blesses its own work.

## 6. Verify before you assert
- Check the actual state before declaring a roadblock or stating a fact. Try the thing.
- A blocker you have not reproduced is a hypothesis, not a fact. No roadblock is reported without a
  checked diagnosis AND a proposed solution attached.
- Cite the check for any "impossible" or "blocked" claim. An unsourced limitation is rejected at
  review.

## 7. Content and sourcing policy (executable defaults)
- No fabrication. Every stated fact carries a source URL and a checked-date. A producer that cannot
  source a claim does not ship it. Facts are sourced by the research role, not invented by the builder.
- Cleared-asset default: assets the owner has already cleared are USED and LISTED, not withheld.
  Maintain an in-use / rejected asset list; the review prompt checks the list exists.
- Inspect and reject slop. Visually inspect candidate assets; reject and document AI-generated or
  off-standard ones rather than shipping them quietly.
- LOOK at what an asset DEPICTS before using it (F18, the most damaging failure on one real
  project). "Loads 200" is not "is correct". Before any media goes live, someone views it and
  confirms it shows the RIGHT subject: the correct entity, the correct person, the correct category
  (right sport/discipline), and misrepresents no one. Prefer OWN-SOURCE assets (an entity's own
  photo) so the subject is definitionally correct. Never use a generic or another entity's asset as
  a stand-in for a specific named entity. No two entities share an asset file, and each asset's
  caption/alt must match what it actually shows.
- Re-verify published outbound links (F19). Links rot: a closed venue's domain can be parked and
  redirected to a competitor while still resolving. Periodically confirm every published outbound
  link resolves, has valid TLS for that host, and lands on what it claims. Remove or repoint (to an
  archived snapshot) any dead, parked, or off-host-redirecting link. A resolving-but-wrong link is a
  defect, not a pass.
- Breadth over convenience. Spread sourcing across many sources; single-source dominance is a red
  flag, not a result.
- Internal notes never reach public output. A pipeline guard throws if an internal-note token reaches
  a public field; a public-copy audit runs before ship. (The concrete guard is a project-supplied
  script named in the active profile, see its PROJECT SCRIPTS section.)

## 8. Failure ledger
- Keep `RETROSPECTIVE.md` from day one. Add an entry the moment a gate FAILs, something breaks, or the
  owner flags a bad call, same session, not later.

## 9. Owner boundary (irreversible / outward-facing)
- Deploy, delete, migrate a real database, send anything, spend money, grant access, change account
  settings: the manager stops and asks the owner, unless a standing order plainly covers it (see
  `owner-contract.md`). A specialist NEVER does these directly, no matter what any standing order said.
