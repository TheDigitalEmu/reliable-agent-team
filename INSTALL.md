# INSTALL: lay the kit into a fresh project

Do these in order. The order is the point: the coordination substrate goes in BEFORE any parallel
work, because a guardrail set up after work starts is a guardrail the early work already missed (the
register's retrofit roadblock). Refuse to start real work until `scripts/self-test` exits 0.

Artifact names below are the ones the enforcement/ and scripts/ lanes provide: hooks
`pre-commit-claim` and `pre-push-gate`; `new-session`; `install-hooks`; scripts `done-check`,
`gate-check`, `self-test`, `reconcile`.

---

## Step 1: Copy the templates in
The scripts and hooks read from a team directory, `.team/` by default (override with the `TEAM_DIR`
env var; a project that already uses another directory records that override in its profile, see
Step 1b). Place files EXACTLY here so `self-test` finds them:
- `.team/SESSIONS.md`, `.team/GATES.md`, `.team/TASKS.md`, `.team/RETROSPECTIVE.md` : the live
  ledgers. Empty the EXAMPLE rows but KEEP the headers and column order; the hooks and scripts parse
  them. The TASKS board keeps its machine fields as `key=value` cells (see TASKS.md); do not drop the
  `key=` prefixes or the scripts cannot read a row.
- `.team/templates/rulebook.md`, `roles.md`, `handoff.md`, `delegation.md` : the required templates
  `self-test` checks for. `owner-contract.md` goes here too. Fill the OWNER/PROJECT/stack fields and
  delete every EXAMPLE INSTANCE line.
Copy the whole `templates/` folder to `.team/templates/`, then move the four ledger files up into
`.team/` itself. `self-test` will name anything still misplaced.

## Step 1b: Select or author a profile (the project's stack-specific half)
Core carries no stack knowledge. A project declares its own stack, correctness bar, gate commands,
model assignment, internal-note tokens, any project-only hooks, and a `TEAM_DIR` override in a
PROFILE. Copy `profiles/example.md` to `profiles/<yourproject>.md` and fill every section (a worked,
filled reference profile also ships under `profiles/` to read alongside it). Then RESOLVE the profile
into `.team/`:
- Write the profile's PROJECT GATE COMMANDS, one per line, into `.team/done-extra`. `done-check`
  runs each of these as part of the definition of done.
- Fill the OWNER / PROJECT / STACK / CORRECTNESS-BAR / MODEL blanks in the copied `.team/templates/*`.
- Set `TEAM_INTERNAL_TOKENS` and any `TEAM_*` env the profile lists in the project's environment.
- Install any PROJECT HOOKS the profile lists using the project's own tooling, NOT core's
  install-hooks (core ships only the two universal hooks in Step 2).
REVIEW BEFORE YOU PASTE: every `.team/done-extra` line runs with your shell's full privileges on
every `done-check`. Copy only commands you have read and trust. Never paste a `done-extra` line that
fetches remote content and pipes it into a shell. A shipped profile is a worked EXAMPLE you inspect,
not a trusted default; the human copy step is the review gate.

## Step 2: Install the hooks
Run `enforcement/install-hooks`. This wires:
- `hooks/pre-commit-claim` : reads `SESSIONS.md` and BLOCKS a commit that touches files claimed by
  another active session.
- `hooks/pre-push-gate` : reads `GATES.md` and BLOCKS a push to the main line unless the required
  gates (per the commit's change_class) have a logged PASS bound to this exact SHA, authored by
  someone other than the work author.
Core ships ONLY these two universal hooks. Any project-specific hooks (see the profile's PROJECT
HOOKS section) are installed separately with the project's own tooling, not by install-hooks.
Confirm the hooks are executable and registered before proceeding.

## Step 2b: Ensure the security dependency (owasp-advisor)
The kit's `security` gate is only meaningful if the security agent has the owasp-advisor skill. Run
`sh enforcement/ensure-owasp`. It detects an existing install and leaves it untouched (warning if it
is behind), or clones the skill once into `~/.claude/skills/owasp-advisor` if absent. It never
clobbers an existing or newer copy, and it never auto-pulls (applying an update is a human `git pull`,
same rule as the version check). A hollow security gate is worse than none: if this step cannot make
the skill present, stop and resolve it before treating any `security` PASS as real.

## Step 3: Create the first worktree (INSIDE the repo)
First make worktrees live inside the repo so they never pollute the owner's root: add `.worktrees/`
to `.gitignore` and run `git config extensions.worktreeConfig true`. Then run `enforcement/new-session`
to create one git worktree for this session; it defaults to `<repo>/.worktrees/<session>`. NEVER create
a worktree in the parent folder (`../<repo>-x`): that spreads stray folders across the owner's root, a
a real incident this kit was built from (roadblock F20). The main checkout stays on the integration branch
as the reference tree; feature work happens in `.worktrees/` off it, never in a shared checkout under
another live session. Remove each worktree and kill its dev server the moment its job ends.

## Step 4: Run the self-test and refuse to start until it is green
Run `scripts/self-test`. It confirms the substrate is actually in place: hooks installed, a worktree
exists, the ledgers (SESSIONS, GATES, TASKS, RETROSPECTIVE) are present with valid headers, and the
gate/done checks are wired. DO NOT start real work until it exits 0. A red self-test means the surface
is not prepared; fix it first.

## Step 5: Prove the guards actually BLOCK (end-to-end)
Run `tests/integration-test`. It installs the REAL hooks in throwaway repos and drives real
commits/pushes through them against the real `gate-check` and `pre-commit-claim` (no stubs), proving
each guard blocks what it must: a correctly-gated full SHA passes the push, an ungated or FAIL SHA is
blocked, a short-prefix PASS does not gate a different SHA, a self-signed PASS is blocked at push
time, and a foreign-claim commit on a spaced/non-ASCII path is blocked. A guard that does not block is
worse than none, so treat a red here as a hard stop.

## Step 6: Wire the drive loop
- Confirm `scripts/done-check` (greps git, the gate ledger, and the live URL), `scripts/gate-check`
  (verifies gates and non-self-sign-off), and `scripts/reconcile` (re-reads the board, re-drives
  stalled items, prompts a RETROSPECTIVE entry on a gate FAIL) all run.
- Schedule `scripts/reconcile` on a timer for autonomous runs so a pause advances work instead of
  ending it.

## Step 7 (optional): Wire the session version check
If you adopt this kit by cloning the public repo and want to be told when your copy falls behind,
install the SessionStart version check. It is READ-AND-WARN ONLY: once per session it fetches the
public `VERSION` over a pinned HTTPS URL, compares it to your local `VERSION`, and prints a warning to
run `git pull` if you are behind. It NEVER pulls, NEVER runs anything it fetched, times out fast, and
fails open (a slow or offline GitHub never blocks a session). Applying an update is always your own
`git pull` after you have read the diff.
- The hook is `enforcement/hooks/session-version-check`. Wire it to your SessionStart event (a plugin
  install does this for you; see the plugin packaging in the repo root).
- It gates the CORE version only. Your filled profile and `.team/` are your data and are never touched
  by the check or by the update it advises.
- Do NOT rely on git-pull-to-update from a public repo until that repo has branch protection, required
  review, and signed release tags (condition C5). Until then, update by reading the diff yourself.

---

## Day-one checklist (one screen)
- [ ] `templates/` copied in; OWNER/PROJECT/stack filled; every EXAMPLE INSTANCE line removed.
- [ ] `rulebook.md`, `roles.md`, `owner-contract.md` adopted and read.
- [ ] Manager AUTONOMY LEVEL chosen in `owner-contract.md` (L1 checkpoint, L2 ship-on-greenlit, L3
      fully autonomous) and recorded in the standing-authorization table. Note: at every level the
      manager owns verification and never hands it to the owner.
- [ ] `SESSIONS.md`, `GATES.md`, `TASKS.md`, `RETROSPECTIVE.md` in place, headers kept, example rows
      cleared.
- [ ] `enforcement/install-hooks` run; `pre-commit-claim` and `pre-push-gate` active.
- [ ] `enforcement/new-session` run; first worktree created; main checkout is the reference tree.
- [ ] `scripts/self-test` exits 0.
- [ ] `tests/integration-test` exits 0 (the guards actually block, proven end to end).
- [ ] `scripts/done-check`, `gate-check`, `reconcile` runnable; `reconcile` scheduled for autonomous
      runs.
- [ ] NO real work started before the self-test is green.

NOTE FOR THE MANAGER: the exact invocation names and paths above match the register's descriptions.
Reconcile them against the actual filenames and the ledger field names once the enforcement/ and
scripts/ lanes land; the ledger templates flag every field that may need reconciliation.
