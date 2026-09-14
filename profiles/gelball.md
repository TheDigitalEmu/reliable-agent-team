# Profile: Gelball

The first, reference profile. It captures, in one document, everything this kit's core deliberately
does NOT know: the stack, the correctness bar, the gate commands, the project scripts, the
internal-note tokens, the model assignment, the project-only hooks, and the team-directory override.
Core reads NONE of this at runtime; a human resolves it into the adopting repo's `.team/` at install
time (see INSTALL.md Step 1b). A profile is purely additive and removable: delete it and clear the
`.team/done-extra` lines it produced, and core reverts to its three-gate no-op behaviour.

ASCII only, no em dashes or dash look-alikes, per this project's punctuation policy (below).

---

## PROJECT
Gelball.com: a community hub and directory for gelball (legality by region, fields and venues,
retailers, Discord and Facebook indexes, and an events calendar).

## OWNER
Emu, business owner of Gelball.com. The manager is the only agent that talks to the owner.

## STACK
Next.js + TypeScript (strict) + Tailwind, wired to Supabase (Postgres + Auth + RLS). Deployable to
Vercel or DigitalOcean; the code is kept host-portable. Free text only; core never reads this.

## CORRECTNESS BAR
The concrete acceptance staples the delegation and hand-off templates reference generically:
- typecheck, lint, build, and tests green.
- 0 forbidden dashes (no em dashes or dash look-alikes: U+2014, U+2013, U+2015, U+2212).
- No RLS weakened; row-level security stays enforced on every public table.
- No service-role key in the client bundle or any `NEXT_PUBLIC_*` variable.
- Committed AND pushed AND (for gated classes) all required gates PASSED, verified live.

## PROJECT GATE COMMANDS
The exact shell commands that become `.team/done-extra` lines (one per line). Each must exit 0 for
`done-check` to reach DONE. These are the seam-1 payload, stated here so they are reviewable in one
place. All are LOCAL, READ-ONLY, INSPECTION-ONLY commands: no network egress, no writes outside the
repo, no deletion, no fetch-piped-into-a-shell (security condition C1).

```
npx tsc --noEmit
npm run build
sh profiles/gelball/public-copy-guard.sh
```

Notes:
- `npx tsc --noEmit`: typecheck only, emits nothing.
- `npm run build`: the project build; local, no deploy.
- `public-copy-guard.sh`: run as a pre-ship audit over drafted public copy; it only matches strings
  in memory (no network, no writes beyond a self-removed temp file).
- The forbidden-dash scan is enforced by the punctuation PROJECT HOOK (below), which the project
  installs with its own tooling; it is not shipped by this kit as a script.

REVIEW-BEFORE-YOU-PASTE reminder: these lines run with your shell's full privileges on every
`done-check`. Copy only what you have read and trust.

## PROJECT SCRIPTS
Project-supplied scripts under `profiles/gelball/`, invoked ONLY through the seam-1 EXTRA hook or a
scheduled reconcile call, never by name from core:
- `public-copy-guard.sh`: BLOCK guard for roadblock F7. Throws if an internal-note token appears in a
  value bound for a public column. Wired as a `.team/done-extra` line and as a pre-ship audit.
  Read-only by design (string matching only).
- `breadth-check.sh`: CHECK for roadblock F3. Counts distinct source hosts across a content set and
  fails below a floor. Run at content-review time. Read-only by design; it does NOT fetch the URLs it
  discovers.

## INTERNAL-NOTE TOKENS
The value for `TEAM_INTERNAL_TOKENS`, consumed by `public-copy-guard.sh` (newline- or
comma-separated, case-insensitive substring match). Gelball's list:

```
confirm
verify before publishing
reviewer note
resolves Jamie seed
TODO
FIXME
DRAFT
do not publish
internal only
placeholder
```

## MODEL ASSIGNMENT
The per-role model choice (the difficulty tier from roles.md resolved to a concrete model):
- All roles on the strong model, EXCEPT qa.
- qa on a cheaper model: its work (run the suite, exercise a checklist) is concrete and easy to
  confirm, so the cheaper model is the right trade.

## PROJECT HOOKS
Git hooks NOT shipped by core (core ships only pre-commit-claim and pre-push-gate). Gelball installs
these itself with its own tooling:
- Punctuation / dash-block hook: blocks any write containing a forbidden dash. Enforces the
  0-forbidden-dashes staple above.
- Public-copy guard: `profiles/gelball/public-copy-guard.sh`, wired as a pre-commit or pre-ship audit
  so an internal-note token cannot reach a public field.

## CONTENT LAYOUT
Used by `breadth-check.sh`:
- content dir: `content/`
- file globs: `*.md`, `*.mdx`, `*.json`, `*.txt`, `*.html`
- breadth floor: 3 distinct source hosts

## LEGAL / DOMAIN POLICY
Core states the generic no-fabrication rule; the domain specifics live here:
- Legality-by-region claims are sourced with a source URL and a checked-date, and are never stated as
  legal advice. A claim that cannot be sourced does not ship.
- Facts are sourced by the research role, never invented by the builder.

## RESERVED-CELL CONVENTION
Declaration only (core ignores fields past the fifth already): Gelball may cross-reference gate rows
against its own registers (for example `ref=` a decision or task id) and use a `blocks=` external
decision field. These are documented here; they change no parser.

## TEAM_DIR
Gelball's instance uses `.claude/` instead of the default `.team/`. Record it as the `TEAM_DIR`
override in the project's environment at install time.
