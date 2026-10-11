# Operating the team

How to run a team day to day once the kit is installed. If it is NOT installed
yet, read `INSTALL.md` first and do not start until `scripts/self-test` exits 0.
This guide is for the human owner and the manager agent. The rules here are the
same ones the machinery enforces; the machinery is the backstop, this is the
routine.

## The shape of it

One manager agent talks to you. It breaks your objective into tasks, hands each to
a specialist, tracks them in the ledgers, and enforces the gates. Specialists
never talk to you and never sign off their own work. You give one-line objectives;
the manager owns the outcome and reports back. Roles and who-signs-what are in
`templates/roles.md`; what you decide versus what the manager just does is in
`templates/owner-contract.md`.

## Set this once: the manager's autonomy level

In `owner-contract.md`, pick L1, L2, or L3 and record it in the standing-order
table.

- L1 Checkpoint: manager pauses at each checkpoint for you to look before going on.
- L2 Ship-on-greenlit (default): manager builds, gates, verifies itself, ships
  what you greenlit, then reports. Stops only for genuinely new irreversible or
  outward-facing actions.
- L3 Fully autonomous: manager owns the whole outcome from a one-line instruction
  and brings back only the finished result or a real business decision.

At every level the manager verifies the work itself by looking at the real
artifact. It never hands verification to you. You are not the QA.

## The daily loop

1. Start a session: `enforcement/new-session --role <role> <name> <branch>`. The role
   is required: it is written to the session's `.team/whoami` and to the shared
   `.team/roles` ledger, which is what lets a manager be refused as a gate author or
   a code writer. new-session creates one git worktree for the session (inside the
   repo, never your root) so two sessions cannot damage each other's files, and
   writes a claim row in `.team/SESSIONS.md`.
2. Work happens in that worktree. The pre-commit hook blocks a commit that touches
   files another live session has claimed. Commit and push freely; unpushed work
   does not count as done.
3. Gate before merge. A change cannot reach the main line until the gates for its
   change class have a logged PASS bound to that exact commit, from someone other
   than the author. The pre-push hook checks EVERY commit in the push against the
   ledger as committed at the tip (see "Pushing to the main line" below), and the
   same check runs on the server if you install `ci/github/gate-check.yml`.
4. Call it done with `scripts/done-check`, not from memory. It greps git (pushed,
   on the branch), the gate ledger (required PASSes present), any live artifact,
   and the project's own extra checks in `.team/done-extra`. "Done" is the script's
   exit code.
5. On a pause or a long autonomous run, `scripts/reconcile` re-reads the board and
   re-drives stalled or drifted items so work advances instead of dying.

## The change classes (they set which gates run)

- static: reviewer only. Inert content, no runtime behavior, no data path.
- presentational: reviewer + qa. Runtime behavior, no data path.
- auth-data-input: reviewer + security + qa. Touches auth, data access, or input.

The handoff carries the class; `gate-check` reads it and enforces the matching
set. Pick the class honestly; under-classing skips a gate you needed.

## The security gate is real only with owasp-advisor

The `security` gate means a second party reviewed the code against OWASP
standards with the owasp-advisor skill and logged a PASS. That skill is a
read-only review protocol: it reads code and produces a scored, evidence-backed
report. It does NOT run the target, send traffic, fuzz, or exploit. It is not a
penetration test. Without the skill the gate is a hollow checkbox.
`enforcement/ensure-owasp` (run at install) makes the skill present. If it is
missing, do not treat a security PASS as real. And note the honest limit: if the
reviewer is another turn of the same model that produced the code, that is not an
independent lens (see ROADBLOCK-REGISTER Limits). For anything critical, the
independent check is a human or a different model.

## The rules you and the manager hold (the machinery backs these, it is not all of them)

- Producer never signs off its own work. Collapsing two roles removes a check.
- "Done" is evidence, not a claim. Built is not done, pushed is not merged, passed
  once is not still passing.
- The manager verifies by looking at the real artifact, not by trusting a handoff.
- No worktrees in your root. Each session cleans up its own worktree and any dev
  server it started.
- Keep a failure ledger (`RETROSPECTIVE.md`). Most rules exist because something
  broke; a team with no failure ledger re-earns every scar.
- Anything compliance or safety-critical needs a human sign-off. An agent thread
  is not independent review.

## Pushing to the main line (the convention the hook and the server enforce)

1. Code commits, each with its gate rows in `.team/GATES.md` bound to its FULL sha.
2. ONE `.team`-only commit on top that carries those rows (and the board and roles
   rows that go with them). It needs no gate row of its own: a commit that changes
   only `.team/` is exempt. The manager never writes a hollow PASS for it.
3. Push with `scripts/gated-push`. It fetches, runs `scripts/gate-check-range` on
   remote..HEAD, and pushes only on exit 0, in one process, so nothing can be chained
   wrong. The pre-push hook runs the same check again inside the push.

The ledger of record is `.team/` AS COMMITTED AT THE PUSHED TIP. A ledger held in the
working tree is invisible to the server and, since 1.1.0, to the local hook too. If a
push is refused with "the tip carries no committed ledger", you skipped step 2.

Retrofit onto an existing repository: set `TEAM_GATE_BASELINE` (and `GATE_BASELINE` in
the workflow) to the last commit before adoption; history before it is never gated.

## Working inside Claude Code (what the runtime does for you, and against you)

- Subagents get their own worktrees under `.claude/worktrees/agent-*`. Those count as
  session isolation. The claim ledger still works but is optional when every session
  has its own tree; keep it for shared checkouts.
- Finished worktrees pile up because an agent asking to delete a directory is refused
  as destruction. `scripts/worktree-sweep` prints what is merged and clean; the human
  runs `--apply` (or allows it once).
- The auto-mode classifier reads a manager writing PASS rows as a CI bypass. The
  answer is structural, not a workaround: the gate agents write their own rows, the
  manager only commits the ledger. It also refuses `git stash` on a shared tree; do
  not stash, commit to the session branch instead.
- The manager wall (`deny-manager-code-write`) is wired by the plugin as a PreToolUse
  hook on Write and Edit. It acts only when the session's role resolves to manager,
  so a session started without `--role` is unguarded, and `self-test` says so.

## When something is off

- A commit is blocked: another session claimed the file (see `.team/SESSIONS.md`),
  or the push is not gated for this exact commit. The hook message names which.
- A push is refused with a list of SHAs: each named commit lacks the rows its class
  needs in the ledger AT THE TIP. Add them, commit `.team` on top, push again.
- A PASS is refused as "no row in the roles ledger": the gate author is not in
  `.team/roles`. Add the row (new-session does this) rather than loosening the check.
- `done-check` refuses: it names the missing piece (unpushed, a missing gate, a
  down artifact, a failing extra check). Fix that piece; do not override.
- The board drifted: run `reconcile` to re-verify and re-drive.

## Where the deeper detail lives

- `templates/rulebook.md`: the full law the team obeys.
- `templates/roles.md`: role definitions and separation of duties.
- `templates/owner-contract.md`: your decisions, standing orders, autonomy.
- `ROADBLOCK-REGISTER.md`: every failure mode and the mechanism that removes it.
- `why/reasoning.md`: why the mechanisms are shaped this way.
- `WHY-KAREN.md`: the failure this whole kit answers.
