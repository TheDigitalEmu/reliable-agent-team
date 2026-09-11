# RETROSPECTIVE: the failure ledger

Required file. The self-test FAILS if this file is missing. Keep it from day one.

Add an entry the moment a gate FAILs, something breaks, or the owner flags a bad call, SAME SESSION,
not later. `scripts/reconcile` prompts an entry when a gate FAILs. The ledger is how the team stops
re-earning the same scar: every rule in the rulebook exists because something below happened once.

Row format:

`date | failure (one line) | what happened | root cause | correct construction (the fix now in place)`

- date : ISO date (YYYY-MM-DD).
- failure : the one-line name, so it is greppable.
- what happened : the concrete event, sourced to the record (a hand-off number, a task id).
- root cause : why it happened, in one line.
- correct construction : the mechanism or rule now preventing it. This is the payload: a fix, not a
  lament.

LEAD-LINE CONVENTION (SHA + task id, agentic-discussion/0001-0003). This is a naming convention,
not a format or parser change: the row columns above are unchanged. Lead each entry's `failure`
cell (its first line) with `SHA <short> TASK <id>: <what failed>`, for example
`SHA 5bdc076 TASK T42: gate passed a defect`. Then the prose follows in the other columns. This
makes the failure ledger greppable by SHA and task id, so "why did gate X pass a defect on SHA Y"
is answerable with a grep, without changing the file's format or the kit's code. If a SHA or task
id does not apply to an entry, use `SHA - TASK -:` so the lead shape stays consistent and greppable.

NOTE FOR THE MANAGER: confirm `scripts/self-test` only checks this file EXISTS (and perhaps that it
has a header), versus parsing the row columns, once the scripts lane lands. Reconcile the column set
if the script parses it.

---

## ENTRIES

| date | failure | what happened | root cause | correct construction |
|---|---|---|---|---|
| | | | | |

(Empty on a fresh project. Do not delete the header row or the columns; the self-test and any future
parser depend on them. Add rows below as failures occur.)
