# TASKS: the shared task board

The single source of truth for all work: done, in flight, outstanding. The log records events; this
board records current state. Both are mandatory and cross-check each other.

Every session, every time:
1. ON WAKE: read this whole board AND SESSIONS.md.
2. BEFORE STARTING: find your task (or add it), set it `in-progress` with your session name and date,
   and claim your files in SESSIONS.md. Commit immediately.
3. ON FINISH: set it `done` with the commit/branch, or `blocked` with why. Commit and push.

Status vocabulary (encodes the definition of done):
- `todo` : not started.
- `in-progress` : being worked, with an owner claimed.
- `in-review` : work handed back, gates running.
- `awaiting-merge` : gates PASSED, built but not yet on the main line. NOT done.
- `blocked` : cannot proceed; the row states why and the proposed unblock.
- `done` : committed AND pushed AND (if it needs gates) all required gates PASSED, verified on the
  main line. Only this counts as done.
- `cancelled` : no longer needed; the row states a one-line reason. Never silently drop a task.

Each row carries a `verified:` note with the actual evidence (a curl result, a git rev-list count, a
DB query), because the board is reconciled against reality, not trusted on its label.

## Machine-read format (the binding contract with the scripts)

`scripts/done-check` and `scripts/reconcile` read each board row by splitting it on `|` and pulling
`key=value` tokens. So every row MUST carry its machine fields as key=value cells, in ANY order. The
scripts read these keys: `class=`, `status=`, `author=`, `artifact=` (yes|no), `url=` or `path=`,
`sha=`. The first cell is the human task id/name and is matched by the task id you pass to the script.
Human-readable prose can live in extra cells; the scripts ignore any cell that is not a known
key=value. This keeps ONE board that both a human and the parser read. Do not move the machine fields
into a separate file, and do not drop the `key=` prefixes: a bare column is invisible to the scripts.

Status values the scripts recognise: `todo`, `in-progress`, `in-review`, `awaiting-merge`, `blocked`,
`done`, `cancelled` (as above). `reconcile` re-checks rows whose `status=` is `in-progress` or `done`.

---

## BOARD

| task | fields (key=value, script-read) | verified (human) |
|---|---|---|
| T1-nav-widget (EXAMPLE) | class=presentational \| status=awaiting-merge \| author=developer \| sha=51a5095 \| artifact=yes \| url=https://example.test/ | reviewer PASS, qa PASS on 51a5095; not yet merged to main |
| T2-info-page (EXAMPLE) | class=static \| status=done \| author=researcher \| sha=9df74e2 \| artifact=yes \| url=https://example.test/info | reviewer PASS; GET /info 200; 4 sourced rows render |
| T3-recover-qa-screenshots (EXAMPLE) | class=presentational \| status=todo \| author=- | - |
