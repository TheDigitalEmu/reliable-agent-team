# SESSIONS: the live claim ledger

The shared radar for every concurrent session. READ THIS FILE ON WAKE, before any work. WRITE your
claim BEFORE you touch any file. CLEAR your row on finish or park. Commit the claim immediately so
other sessions see it.

The overlap check (run in your head before every file touch and every git op):
1. Is this file (or its directory) in anyone else's ACTIVE CLAIMS row? If yes: do not touch it,
   coordinate first (message that session by name, or raise it with the owner).
2. Am I about to run a git op that moves a shared checkout (checkout, switch, reset, stash, rebase)
   while another session is alive in it? If yes: do not. Work in your own worktree.
3. Am I about to push or commit? Then my claim row must already be recorded here.

Row format (one row per active session), the exact columns the pre-commit-claim hook and self-test
read. Keep the columns and order stable:

`session | worktree/branch | files/globs claimed | task | status | updated`

- session : short session name (role + purpose), e.g. `developer (nav-widget)`.
- worktree/branch : the worktree path and branch, e.g. `.worktrees/nav off design/nav-widget`. Worktrees
  live INSIDE the repo at `.worktrees/` (gitignored), never in the parent root.
- files/globs claimed : exact paths or globs you will write, comma-separated.
- task : one-line what you are doing. Add a "Did NOT touch: ..." promise when near a shared hot spot.
- status : `active` | `parked` | `blocked` | `done`.
- updated : ISO date (YYYY-MM-DD).

NOTE FOR THE MANAGER: confirm these column names/order match the pre-commit-claim hook's parser once
the enforcement lane lands, and reconcile if they differ.

---

## ACTIVE CLAIMS

| session | worktree/branch | files/globs claimed | task | status | updated |
|---|---|---|---|---|---|
| (EXAMPLE INSTANCE) developer (nav-widget) | .worktrees/nav off design/nav-widget | src/components/SiteNav, NavWidget, nav/{navData,icons} | Category nav widget. Did NOT touch shared tokens/globals/root layout. NOT merged: reviewer + qa owed. | parked | 2026-09-09 |

## KNOWN CONCURRENT SESSIONS (radar)
Who is alive and what they own, including sessions on other projects so it is clear they are NOT an
overlap.

- (EXAMPLE INSTANCE) qa (overhaul) : read-only gate worktree .worktrees/qa-overhaul, exercising the
  assembled tip. Not writing feature source. (A session on an unrelated project would be listed here
  too, so it is clear it is NOT an overlap.)

## PARKED WORK
Branches that exist but are idle. One line each with the branch ref.

- (EXAMPLE INSTANCE) design/nav-widget : built, pushed, awaiting reviewer + qa gates.

## INCIDENT LOG
Record every coordination incident so it is never repeated from ignorance.

- (EXAMPLE INSTANCE) 2026-09-08: two chats shared one checkout; the auth chat branch-switched it
  mid-run and wiped the theme QA session's untracked screenshots and a test file, no git record.
  Root cause: shared working tree + uncommitted work + no claim ledger. Fix: one worktree per session
  + this ledger.
