# GATES: the gate ledger

The machine-readable record of every gate verdict. `scripts/gate-check` and the pre-push-gate hook
read this file to decide whether a commit may merge/push. One row per gate verdict.

Row format, the exact columns the scripts parse. Keep the columns and order stable:

`commit_sha | change_class | gate | verdict | author | date | evidence`

- commit_sha : record the FULL 40/64-char SHA the verdict is bound to. gate-check matches
  one-directionally (the commit being checked must be a prefix of this row's SHA), so a short/
  abbreviated SHA here will NOT satisfy a longer, more specific commit. A PASS is about THIS commit
  only; a new commit on the branch invalidates it and needs a fresh row.
- change_class : `auth-data-input` | `presentational` | `static`. Decides which gates are required
  (see rulebook section 3): auth-data-input needs reviewer + security + qa; presentational needs
  reviewer + qa; static needs reviewer.
- gate : `reviewer` | `security` | `qa`.
- verdict : `PASS` | `FAIL` | `CHANGES-REQUESTED`. Only `PASS` satisfies a gate. A `FAIL` or
  `CHANGES-REQUESTED` (or any non-PASS token) for a (gate, SHA) is STICKY: it BLOCKS that gate even
  if a later `PASS` row for the same SHA is appended. Clear a blocked gate by re-gating a NEW commit,
  not by appending a PASS to the old one.
- author : the agent that ran this gate. MUST NOT equal the work author of the commit (gate-check
  fails a self-sign-off; the compare is case-insensitive and trimmed). The work author comes from the
  hand-off `work author` field. At PUSH time the pre-push hook has only a SHA, so it derives the work
  author from the task board (`author=` on the task line carrying this `sha=`); keep that field
  populated so self-sign-off is enforced mechanically on push, not just when gate-check is run by hand.
- date : ISO date (YYYY-MM-DD).
- evidence : short proof, e.g. `typecheck exit 0; tests N pass 0 fail; GET / 200`. For a FAIL, the
  defect in one line.

A commit is cleared to merge only when every gate its change_class requires has a `PASS` row bound to
THAT commit_sha, each by an author who is not the work author.

NOTE FOR THE MANAGER: confirm these field names/order match `scripts/gate-check`'s parser once the
scripts lane lands. The register describes the row as "commit_sha, change_class, gate, verdict,
author"; `date` and `evidence` are added here as the auditable proof columns and should be reconciled
against the script (they may be optional or named differently).

---

## GATE VERDICTS

| commit_sha | change_class | gate | verdict | author | date | evidence |
|---|---|---|---|---|---|---|
| a1b2c3d (EXAMPLE) | presentational | reviewer | PASS | reviewer | 2026-09-09 | typecheck exit 0; lint clean; build clean; scope matches spec; no dead code |
| a1b2c3d (EXAMPLE) | presentational | qa | FAIL | qa | 2026-09-09 | keyboard-open never moved focus into panel; Escape did not close hover-opened panel; 2/2 reproduced |
