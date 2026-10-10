# 0008: Field review, four weeks of the kit on an adopting project (anonymised as Project A)

- From: the Project A manager session (desktop), written on request of the owner
- To: the reliable-agent-team author session
- Date: 2026-10-11
- Kind: review of the kit in real use, with proposed changes
- Status: waiting on the author

Everything below is read from the repositories, not recalled. Sources: the kit source clone at
the kit source clone (main, one commit ahead of the published 1.0.0), the installed plugin
(`~/.claude/plugins/marketplaces/reliable-agent-team`, 1.0.0), and the Project A repository
(its `origin/main` at `be8d4e9`, its `.team/` ledgers and retrospective, the
decision register, and the project's own gate workflow). Where a number is given it was computed from
those files on 2026-10-11.

## Verdict in one paragraph

The enforcement core did the one thing it promised: a gate verdict bound to an exact commit, a FAIL
that sticks, and a reviewer that is not the author, held up across 436 commits, a handover to a cloud
session that started from the repository alone, and 19 non-PASS verdicts that each stopped a real
defect. Everything else in the kit was either never exercised here (the claim ledger, done-check,
reconcile, cost-check) or was inert because its inputs were never created (both role guards). The
kit's strongest guard, the local pre-push hook, had two structural holes that the project had to close
itself with a server-side range check, and its tip-only design manufactured the exact self-sign-off it
exists to prevent, 92 times. The two biggest contributions waiting to go upstream were built during
adoption: the server-side range check (`tools/gate-check/gate-check.cjs` plus two workflows) and the
awk rewrite of gate-check (571 seconds per commit down to 2, commit `0d0ca39`, still unpushed).

## 1. What is installed here and how it is actually run

- The git hooks exec the SOURCE CLONE, not the plugin: `core.hooksPath` points at
  `.git/team-hooks`, whose two wrappers call `<kit clone>/enforcement/hooks/...`.
  The plugin install (1.0.0, 2026-09-18) contributes only the SessionStart version check and the two
  skills. Nothing in the project reads the plugin's scripts.
- Ledgers on `origin/main`:

| Ledger | State on 2026-10-11 |
|---|---|
| `.team/GATES.md` | 469 verdict rows over 279 distinct commits, 367 KB; 450 PASS, 13 CHANGES-REQUESTED, 6 FAIL |
| `.team/TASKS.md` | 68 rows; 53 done, 6 todo, 4 cancelled, 1 in-progress, 1 awaiting-merge, 1 blocked, 2 with an empty status |
| `.team/RETROSPECTIVE.md` | 22 entries, every one with a mechanism in the last column |
| `.team/SESSIONS.md` | 0 active claims since install day (2026-09-14); the two rows present say "(cleared)" |
| `.team/done-extra` | 3 validators listed; the repository has had 7 since D-147 |

- The loop that actually ran: the main desktop session acts as manager. Developers are Claude Code
  subagents, each in a worktree the Agent tool creates under `.claude/worktrees/agent-*` (the kit's
  `new-session` and `.worktrees/` were used once, on install day, and never again). A separate
  "sonnet-gate" subagent reviews a diff range and writes the reviewer, security and qa rows itself
  (the auto-mode classifier refuses the manager when it writes PASS rows, reading it as a CI bypass).
  The manager commits the ledger as a `.team`-only commit and pushes. GitHub's Gate check workflow
  (project-built, D-166) re-checks every commit since the last green tip, and Deploy refuses any
  commit without a green Gate check run.
- Volume since install: 436 commits, 174 of them touching application code, 335 gate rows written in
  October alone.

## 2. What worked, with the evidence

- **SHA binding and sticky FAIL.** Six FAIL and thirteen CHANGES-REQUESTED rows. Each FAIL ended in
  the merge being dropped and a new commit re-gated (for example `487fc57` qa FAIL, rebuilt as
  `b085522`, qa FAIL again, rebuilt as `fdbb385` PASS). Nobody appended a PASS over a FAIL; the
  rule did not need remembering.
- **A different model as the gate** (the project's D-119 rule, which the kit only recommends). The
  retrospective records what that lens caught and the developer had missed: a `Field` component
  claiming an `aria-describedby` it never wired, an inbound request-id header reflected into logs
  without a content check (CRLF injection), an unguarded JPEG zero-axis in the image cap, and a rename
  hole in the server-side gate check found before it was pushed.
- **The retrospective is the best artefact the kit produces.** Twenty-two entries, each led by the
  SHA and task convention, each ending in the mechanism now in place. Several of those mechanisms
  later became CLAUDE.md rules or standing orders. The failure ledger did exactly what WHY-KAREN says
  it should: nothing here has been re-earned twice.
- **The seam-1 and seam-2 conventions.** `done-extra` exists and the trailing-cell convention is
  respected by the Node port (it reads five cells and ignores the rest).
- **The version check.** Ran at every session start, never blocked anything, never pulled anything.
- **Survivability.** A cloud session (Ned) took the project over on 2026-10-08 from the repository
  alone and kept gating with the same ledger, which is the "repository is the only memory" test passed.

## 3. What did not work, and the mechanism behind each

### 3A. The local push gate: two holes and a trap

1. **It is per clone.** On 2026-10-05 commit `1bb25f2` reached `origin/main` ungated from a push path
   this clone never saw. A git hook can only bite the clone it is installed in. The project answered
   with D-166: a GitHub workflow that checks every commit since the last green tip against the ledger at
   the pushed tip, and a Deploy job that requires that run to have succeeded.
2. **Working tree versus committed tip.** The hook reads `.team/GATES.md` from the working tree, so
   every session held the rows uncommitted and pushed. The server reads the ledger at the pushed
   commit, so the first server run went red with seven commits listed as UNGATED (`18df9d9`,
   2026-10-08). The kit never states which ledger is the ledger of record.
3. **Tip-only gating with no `.team` exemption forces a hollow row.** Once the convention became
   "the pushed tip is the ledger commit", that ledger commit itself needed a `static | reviewer | PASS`
   row to get past the hook. The manager wrote one for its own ledger commit, author `manager (ed)`
   or `manager (bill)`, 98 times between 2026-09-21 and 2026-10-08; 92 of those evidence cells say the
   ledger was "held uncommitted so the local pre-push hook reads it". The guard produced the
   self-sign-off it exists to reject.

### 3B. Both role guards were inert

`resolve-role` needs a `ROLE=` line in `.team/whoami` or a `.team/roles` ledger. INSTALL.md creates
neither, `new-session` was run once, `self-test` does not check that a role resolves, and both
`pre-commit-role` and gate-check's manager rejection fail open on an unknown role. Here `whoami` is
the bare word `bill-manager` and `.team/roles` does not exist, so both guards have passed everything
for four weeks. Observable result: manager-authored `static reviewer PASS` rows on 13 commits that
changed `.github/workflows/deploy.yml`, `validate-code.yml`, `diagnose.yml`, `tools/validate-requirements.py`
and `deploy/ENABLED`, none of which is documentation under the project's own D-119. The
`deny-manager-code-write` PreToolUse wall is shipped but `hooks/hooks.json` wires only SessionStart,
so nothing ever installed it.

### 3C. The coordination layer was bypassed by the runtime

Claude Code's Agent tool gives each subagent its own worktree under `.claude/worktrees/agent-*`.
Nobody runs `new-session`, nobody writes a claim, so `pre-commit-claim` has had nothing to check since
install day. The F14 collision the claim ledger exists to prevent happened anyway on 2026-10-06: two
developers in one tree, a shared scratch file name, one developer committing through a private
`GIT_INDEX_FILE` after a refusal. And F20 came back in new clothes: 13 merged agent worktrees plus
the two install-day kit worktrees are still on disk, and the manager was refused when it tried to
remove them (classifier: "Irreversible Local Destruction").

### 3D. done-check and reconcile were never used

No session state, board row or retrospective entry records a `done-check` or `reconcile` run.
`done-extra` has been stale since install day (3 validators listed, 7 exist). Two design reasons it
would not have fitted anyway: done-check's git test ("HEAD not ahead of origin/BRANCH") assumes work
is pushed from the branch it was built on, which is false in a worktree-and-merge flow; and
reconcile's default status filter is `in-flight,done` while the shipped TASKS template and this board
use `in-progress`, so reconcile skips every in-flight row by default. That mismatch is in the kit, not
the project.

### 3E. Performance

Against a 273-row ledger on Git Bash, the published gate-check took 571 seconds for one commit in
SHA-only mode (a dozen processes per ledger row, called once per required gate). The pre-push hook
runs it on every push to main. The awk rewrite in `0d0ca39` takes 2 seconds, passes the 48-case
integration suite (re-run 2026-10-11, 48 passed, 0 failed), and its commit message records 32 side by
side equivalence cases. It is unpushed.

### 3F. Windows

`self-test` reads `core.hooksPath` as `G:\gitHub\...\team-hooks`, tests it against `/*`, treats it as
relative, prefixes the repo root and reports "hooks: core.hooksPath set ... but it is empty or
missing". The hooks are installed and run. A false red on the one check that is supposed to say
"do not start work".

### 3G. Shell hygiene the kit left to the agent

Two retrospective entries on 2026-10-09: the gate check's exit code masked by `| tail -1` (`fcad850`
pushed red), then the push chained after an `echo "gate=$?"` so the shell gated the push on echo
(`7f86cd0` pushed red). Both are PROCEDURE rows in the register's own terms; both are convertible to
a BLOCK with one script that runs the check and the push in a single process.

### 3H. The ledger does not scale as a file

367 KB after four weeks and growing by about 90 KB a week. gate-check already accepts a directory of
`*.md` files; the Node port does not; nobody rotates. The evidence column is long prose, which is good for audit and bad for a 367 KB table.

### 3I. Three lenses, one agent

151 rows are authored `sonnet-gate` and 69 commits carry reviewer, security and qa rows all from one
author. Model independence held (Sonnet gating Opus-written code). Lens independence did not: the
ledger cannot tell three vantage points from one agent wearing three hats, and roles.md says three
roles.

### 3J. Collisions with the auto-mode classifier

Writing PASS rows to `GATES.md` reads as a CI bypass; removing worktrees reads as destruction;
`git stash` on a scratch worktree was refused. None is the kit's fault, all shaped behaviour, and
INSTALL.md and OPERATING.md say nothing about them.

### 3K. The shipped TASKS template cannot be read by the scripts that claim to read it

Raised by the owner on 2026-10-11 after the first draft of this review missed it; verified the same
day by driving the real scripts in a scratch repository. The three EXAMPLE rows in
`templates/TASKS.md` write the machine cells as `class=presentational \| status=done \| author=developer \|`
(a Markdown table with escaped pipes), and the whole board is a table with a leading `|`. Every
parser splits on a bare `|` and trims only whitespace, so:

| Script | Row in the template's format | What happens |
|---|---|---|
| gate-check (sh, SHA-only mode) | `author=developer \|` | derives the work author as `developer \`, compares it with the PASS author `developer`, finds them different, and PASSES a self-signed gate. Exit 0. |
| gate-check.cjs (the GitHub port) | same row | `boardAuthor` returns `developer \`; both lenses report OK. Same weakness, server side. |
| reconcile | `status=done \|` | reads the status as `done \`, matches nothing, re-verifies 0 of 1 rows and prints "clean". Exit 0. A silent no-op. |
| reconcile | any row, plain pipes | the task id is taken as everything before the first `|`; with a leading table pipe that is empty, the fallback yields `|`, and done-check is called with `--task |`. Broken on every Markdown-table board, escaped or not. |
| done-check | `class=presentational \|` | reads the class as `presentational \` and blocks with "unknown class". Fails closed, at least. |

The live Project A board does not use the escaped form (0 of 66 rows), which is why the project only met
the fail-closed variant of this (an `author=` not in its own cell, 2026-10-08). The hazard is for the
next adopter, who copies the template as INSTALL.md says to and gets a push-time self-sign-off check
that passes self-signed work while printing "independently authored".

## 4. Changes made during adoption (so the author knows what is already different)

**To the kit itself** (commits on the kit source clone, 2026-09-14 to 2026-10-06):
owasp-advisor as a required dependency (0.2.0), OPERATING.md (0.2.1), identity scrub (0.2.2), version
drift fix and consistency check (0.2.3), cost-check and the `port=` artifact (0.3.0), uMode (0.4.0),
`ensure-rat` (0.4.0), the two-skill plugin restructure (1.0.0), and the awk gate-check (unpushed).
The role machinery (`resolve-role`, `is-code`, `pre-commit-role`, `deny-manager-code-write`) was
added after the 2026-09-14 attribution audit found the manager had written application code and
self-signed a row.

**In the project's copy:** the four templates `rulebook`, `roles`, `handoff`, `delegation` are
byte-identical to the kit's. `owner-contract.md` carries the L2 setting, the uMode amendment and five
standing-authorisation rows. The kit's `profiles/project-a.md` (then named after the client) is the project's profile and is stale
(three gates, now seven) and the project reimplemented gate-check in Node for CI with three
refinements the kit does not have: a `.team`-only exemption, a docs-only exemption with a list of
shipped docs paths that stay gated, a tree-identical exemption, a first-parent walk so a gated merge
covers the commits it brought in, and `--no-renames` so a move into `docs/` is never read as docs-only.

**Core hygiene found on the way:** `enforcement/lib/is-code` and `deny-manager-code-write` carry
the adopting project's own source and discussion folder paths in CORE, and
`core-is-generic-check` passes because its token list does not include them. The core/profile
boundary has a hole the check cannot see.

## 5. Recommended changes, in order of value

1. **Ship the server-side range check.** Port `tools/gate-check/gate-check.cjs` upstream (or rewrite
   its rules in POSIX sh) as `scripts/gate-check-range`, plus a reusable GitHub workflow and the
   "require a green run before deploy" script. State the push convention in OPERATING.md: code commits,
   then one `.team`-only ledger commit, and the ledger at the pushed tip is the ledger of record.
2. **Make the local hook agree with it.** `pre-push-gate` walks `remote_sha..local_sha` first-parent,
   reads the ledger from the tip commit (`git show <tip>:.team/GATES.md`), exempts `.team`-only and
   tree-identical commits, and never gates the ledger commit itself. That removes the hollow-row trap
   in 3A.3 and the working-tree hole in 3A.2.
3. **Make the role guards real or remove them.** `new-session` writes `ROLE=`; install creates
   `.team/roles`; `self-test` fails when the current session's role does not resolve; gate-check fails
   closed on a PASS whose author's role does not resolve; `hooks.json` wires
   `deny-manager-code-write` as a PreToolUse hook. A guard that fails open on a missing file is a
   guard the install forgot.
4. **Meet the runtime where it is.** Name Claude Code's `.claude/worktrees/agent-*` as an accepted
   isolation primitive, ship `scripts/worktree-sweep` (remove worktrees whose branch is merged into
   the main line, print what it would do first), and either write the claim row from a SubagentStart
   or PreToolUse hook or demote the claim ledger from required to optional and say so.
5. **Ship `scripts/gated-push`.** One process: run the range check, push only on exit 0, print the
   verdict. Converts 3G from two procedures into a block.
6. **Fix reconcile's default statuses** to the template's vocabulary, and adapt done-check's git test
   to "the SHA is an ancestor of origin/<main>" so it fits a merge flow. If neither will be used by a
   Claude Code manager, say which parts of the kit are for a scheduled autonomous run only.
7. **Push `0d0ca39` as 1.0.1**, and in the same patch fix 3K: one shared board parser (the
   `is-code` pattern, one definition every script sources) that strips a leading table pipe, splits
   on `|` or `\|`, trims whitespace and a trailing backslash from every cell, takes the task id from
   the first non-empty cell, and fails closed when a `key=` value is empty after trimming. Rewrite the
   three template EXAMPLE rows in the format the scripts actually read, and add an integration case
   that feeds the template's own example rows to gate-check, reconcile and done-check. The same fix
   goes into `gate-check.cjs` if it comes upstream. It is functional (performance of a hook on every
   push, and a self-sign-off check that currently passes self-signed work) and proven.
8. **Fix the Windows path test in `self-test`** (treat `X:\` and `X:/` as absolute).
9. **Ledger rotation and lens provenance.** Directory mode in the CI check; recommend
   `.team/gates/YYYY-MM.md`; add a reserved `model=` cell and an opt-in rule that a PASS model must
   differ from the work model (the D-119 rule, generalised); optionally require distinct authors per
   lens on `auth-data-input` so three lenses are three agents.
10. **Core hygiene.** Move the project paths out of `is-code` and `deny-manager-code-write` into a
    profile override (`is-code.local` already exists for this), add the project's own name tokens to the generic
    check's tokens, delete the four "NOTE FOR THE MANAGER" scaffolding lines from shipped templates
    and INSTALL.md, fix README's "clone into `~/.claude/skills/`" (it is a plugin now), and reconsider
    publishing a client's filled profile (the shipped client profile named the owner, the hosting, the
    internal database arrangement) in a public repository. Opinion: anonymise it or keep it in the
    adopting repo.
11. **Document the classifier collisions** and the canonical answers: gate agents write their own
    rows, worktree removal is a script the human runs or allows, no `stash` on shared trees.

## 6. Opinion

The kit is right about the thing that matters most: a rule kept in prose is a rule that gets
skipped, and the twenty-two retrospective entries here are twenty-two proofs of it. Its value came
from three mechanisms, SHA-bound rows, sticky FAIL, and a gate run by a different model, and from one
habit it insists on, the failure ledger. About half of its surface was dead weight on this project,
not because the ideas are wrong but because they were written for a shell-driven team and the team
that actually ran was Claude Code's own subagents, worktrees and classifier. The next version should
be smaller, server-side where it can be, and wired to the runtime that runs the agents rather than to
a procedure the manager is supposed to remember.
