# Reliable Agent Team

> **If you were told to "install this": read `INSTALL.md` and follow it in order.**
> That file is the authoritative, step-by-step procedure. Do the steps in order,
> do not start real work until `scripts/self-test` exits 0, and never weaken a
> guard to make a step pass. To RUN the team day to day after install, read
> `OPERATING.md`. Everything else in this README is context.

A buildable kit for standing up an agent team whose reliability comes from ENFORCEMENT, not from
agents remembering to behave. This is the answer to a specific failure: a described rule is a rule
an agent can forget, and every failure this kit was built from was a known rule
skipped. So this kit does the opposite of describe. Every rule here ships as machinery that fails
LOUD when it is broken: a hook that blocks the commit, a script that blocks the merge, a check that
greps git and the live URL before it will print "done." Read `WHY-KAREN.md` for the account of the
failure this kit answers.

This kit ships as a Claude Code plugin with two skills (see `.claude-plugin/` and `skills/`): `install`
(lay the kit into a project) and `update` (fetch and apply the latest version of the kit, on the plain
word "update", no git command typed). It needs none of that to adopt by hand: point an agent at this
repo, say "install this", and have it follow `INSTALL.md`. See `ROADBLOCK-REGISTER.md` for the design
spine.

## The design principle
Reliability is a failure RATE you drive down with enforcement plus real usage, not a state a document
confers. No document makes a team "reliable." Machinery that makes the wrong action fail immediately,
plus honest measurement across many projects, drives the rate down. This kit supplies the machinery.
It does not promise reliability; it removes the specific roadblocks that made this project unreliable,
and it is honest that it is n equals 1 (see the Limits section of `ROADBLOCK-REGISTER.md`).

## What is in here
- `ROADBLOCK-REGISTER.md` : the spine. Every known roadblock (failure mode), each paired with the
  concrete MECHANISM that removes it, and whether that mechanism is installable machinery or a
  procedure. This is the document that decides everything else.
- `enforcement/` : the actual guards a new project copies in (git hooks, a gate ledger checker, a
  worktree setup, a done-check). Installed, not described.
- `scripts/` : the runnable checks (definition-of-done check, team self-test, reconcile).
- `templates/` : copy-paste starting artifacts (rulebook, role definitions, claim ledger, delegation
  log format, hand-off template) so a new team starts from working files.
- `why/` : the reasoning, demoted here on purpose. Humans read this; the machinery does not need it.
- `INSTALL.md` : the ordered procedure to lay all of this into a fresh project, and the self-test to
  confirm it took.

## Distribution and staying current
This kit ships as a PUBLIC repo: anyone can read and clone it, and only the owner can write to it.
It is packaged as a Claude Code plugin (see `.claude-plugin/`) plus a SessionStart version check
(`enforcement/hooks/session-version-check`). Once per session the check fetches the public `VERSION`
over a pinned HTTPS URL, compares it to your local `VERSION`, and warns you to `git pull` if your copy
is behind. It is READ-AND-WARN ONLY: it never pulls, never runs anything it fetches, times out fast,
and fails open, so a slow or offline GitHub never blocks a session. Applying an update is always your
own `git pull` after you have read the diff. Claude Code has no per-run check; per-session is the
finest granularity that exists, so the check runs at session start, not per message. The full design
and its security conditions are recorded in `agentic-discussion/DECISIONS.md` (D6) and the distribution
rows of `ROADBLOCK-REGISTER.md`. When a change bumps `VERSION` (and so tells the wild to pull) is
defined in `VERSIONING.md`. Why any of this care is warranted, read `WHY-KAREN.md`.

## Portability (what this ships for, and what it does not)
The packaging is Claude Code specific: a plugin, a SessionStart hook, and a clone into
`~/.claude/skills/`. The strongest guards are git lifecycle (a pre-commit claim hook, a pre-push
SHA-bound gate), so they only bite work that flows through git commits and pushes. On a host without
that lifecycle, or a different agent runtime, those hooks never fire and that work is ungated. What is
portable is the SHAPE, not this packaging: in-repo worktrees only; "done" is a script's exit against a
real artifact, not a claim; the producer never signs off its own work (if the only second party is a
human or a different model, that IS the reviewer); a scheduled reconcile so a pause advances instead of
dying; never weaken a check to go green. A non-Claude-Code host adopts the shape and writes its own
thin checks against its real artifacts (a file exists, a service answers, a command exits 0); it does
not install this plugin as-is. Two primitives a non-git or metered host needs are shipped and
portable: `scripts/cost-check` (a spend ceiling you feed the host's usage number to) and done-check's
`port=` artifact (proves a live service actually answers, not just that code was committed).

## The core / profile split
Everything in this kit is written to be project-agnostic (the CORE). Any project's specifics (its
language, framework, host, security controls, gate commands, and any project-only hooks) live in a
PROFILE under `profiles/`, never in core. Core knows only git, POSIX sh, the ledgers, worktrees,
change classes, the three gate roles, and the seam-1 EXTRA hook by which a project injects its own
commands. A profile is resolved into the adopting repo's `.team/` by a human at install time; core
reads only `.team/` at runtime and never reads `profiles/`. Copy `profiles/example.md` to start a new
project's profile; `profiles/` also ships a worked, filled reference profile you can read alongside it.
