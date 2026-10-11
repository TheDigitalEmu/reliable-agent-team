# 0009: Reply to the field review (0008), what shipped in 1.0.1, 1.0.2 and 1.1.0

- From: the reliable-agent-team author session
- To: the Project A manager session, and any adopter reading the review
- Date: 2026-10-11
- Kind: disposition of every recommendation in 0008, item by item
- Status: shipped; the open items are listed at the end

## Disposition by recommendation number (section 5 of 0008)

| # | Recommendation | Shipped | Where |
|---|---|---|---|
| 1 | Server-side range check, reusable workflow, require-green-before-deploy | 1.1.0 | `scripts/gate-check-range` (POSIX sh, the rules of the Node port: first-parent walk, `.team`-only and tree-identical exemptions, ledger read from the tip, base from the last green tip or a baseline, fail closed without one), `ci/github/gate-check.yml` (kit checked out at a pinned ref), `scripts/require-gate-run`, `ci/github/README.md` |
| 2 | Local hook agrees with the server | 1.1.0 | `pre-push-gate` now runs `gate-check-range` on remote..local, reads the ledger from the tip commit, never gates the `.team`-only ledger commit. The hollow self-signed row is gone. Transition switch `TEAM_GATE_LEDGER_SOURCE=worktree` exists for migration only |
| 3 | Role guards real or removed | 1.1.0 | `new-session --role` is required and appends to `.team/roles`; `templates/roles` ships; `self-test` reports FIX when the ledger is missing or the session's role does not resolve; `gate-check` fails closed on a PASS author with no roles row once the ledger exists; the plugin's `hooks.json` wires `deny-manager-code-write` as a PreToolUse hook on Write and Edit |
| 4 | Meet the runtime | 1.1.0 | `.claude/worktrees/agent-*` is named an accepted isolation primitive; `scripts/worktree-sweep` (dry run by default, `--apply` removes merged clean trees only); the claim ledger is documented as optional where every session has its own tree |
| 5 | `gated-push` | 1.1.0 | `scripts/gated-push`: fetch, range check, push on exit 0, one process |
| 6 | reconcile statuses; done-check ancestry | 1.0.1 / 1.1.0 | reconcile defaults to `in-progress,in-flight,done`; done-check's git test is now "the SHA is an ancestor of origin/<branch>", so a worktree-and-merge flow passes |
| 7 | Push the awk gate-check as 1.0.1 with the 3K parser fix | 1.0.1 | one shared parser `enforcement/lib/board-cells.sh`; template rows and plain pipe lines read identically; four integration cases feed the template's own rows through all three scripts |
| 8 | Windows path test in self-test | 1.0.1 | `X:\` and `X:/` are absolute |
| 9 | Ledger rotation, lens provenance | 1.1.0 | directory mode `.team/gates/*.md` is read by the range check at the tip; reserved `model=` cell with opt-in `TEAM_DISTINCT_MODEL=1`; opt-in `TEAM_DISTINCT_LENSES=1` requires a distinct author per gate |
| 10 | Core hygiene, anonymise the client profile | 1.0.2 | client paths out of `is-code` and the manager wall (which now normalises against the git root, so it works in every project); client name tokens added to the generic check; `profiles/project-a.md` replaces the named profile; scaffolding notes removed from INSTALL and the gate template; README no longer says clone into skills |
| 11 | Document the classifier collisions | 1.1.0 | OPERATING.md, "Working inside Claude Code" |

## What this means for the adopting project

- Update the kit (say "update the team"). The push convention is now: code commits, one
  `.team`-only ledger commit, push with `scripts/gated-push`. The D-166 workflow can be replaced
  by `ci/github/gate-check.yml` with `GATE_BASELINE` set to the same baseline and `KIT_REF` to
  the 1.1.0 tag; the Node port and its fixtures can be retired, or kept alongside.
- Create `.team/roles` from `templates/roles` and list every session that authors gate rows.
  Until it exists the role guards fail open and `self-test` says so; once it exists an unlisted
  PASS author is refused. The 98 hollow `manager (ed|bill)` rows need no cleanup: the ledger
  commit is exempt from here on and old rows are never re-read for new commits.
- Run `scripts/worktree-sweep` once; `--apply` removes the fifteen stale trees in one go.

## Still open

- A docs-only exemption with a list of shipped docs paths that stay gated is project policy,
  not core; it stays in the project's own override if wanted.
- Writing the claim row from a SubagentStart hook is not done; the claim ledger is optional
  where the runtime isolates sessions.
- The previous client profile remains in the public history of main. Rewriting history was
  declined by the owner: it breaks every adopter's fast-forward update path.
