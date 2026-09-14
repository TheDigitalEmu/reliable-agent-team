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

1. Start a session: `enforcement/new-session <name> <branch>`. This creates one
   git worktree for the session (inside the repo, never your root) so two sessions
   cannot damage each other's files. It writes a claim row in `.team/SESSIONS.md`.
2. Work happens in that worktree. The pre-commit hook blocks a commit that touches
   files another live session has claimed. Commit and push freely; unpushed work
   does not count as done.
3. Gate before merge. A change cannot reach the main line until the gates for its
   change class have a logged PASS bound to that exact commit, from someone other
   than the author. The pre-push hook enforces this.
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

## When something is off

- A commit is blocked: another session claimed the file (see `.team/SESSIONS.md`),
  or the push is not gated for this exact commit. The hook message names which.
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
