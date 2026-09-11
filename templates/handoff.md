# Hand-off template

Every worker writes one of these BEFORE handing control back. Every gate verdict is logged the same
way. The scripts read the fields marked (machine-read); keep their names stable. File name:
`NNNN-<from>-to-<to>-<slug>.md`, zero-padded and incrementing. Append one line to the delegation
index (`DELEGATION-LOG.md`) with the number, date, from, to, type, summary, verdict.

Numbering collides under concurrency. If two sessions grab the same number, renumber one and leave a
`note` row in the index recording the renumber. Never silently rewrite the sequence.

---

## Hand-off NNNN: <slug>

- task id: <T-id from TASKS.md>            (machine-read: links the board row)
- from: <role>
- to: <role, usually manager>
- type: `delegation` | `review-verdict` | `checkpoint` | `question-to-owner` | `blocker`
- change_class: `auth-data-input` | `presentational` | `static`   (machine-read: sets required gates)
- work author: <the agent that PRODUCED this work>   (machine-read: gate-check fails if a gate author
  equals this)
- commit_sha: <the SHA this hand-off is about>        (machine-read: binds the work/verdict to a tip)
- date: YYYY-MM-DD

### Task / context
What this was, with the scope boundary restated.

### Input / assumptions
The inputs used and the assumptions made.

### Result / verdict
For a build: what was produced. For a gate: `PASS` | `FAIL` | `CHANGES-REQUESTED`, with reasons.
State plainly what is verified versus what is only implemented. Do not round "built" up to "done".

### Evidence block (machine-read: the done-check and gate-check look here)
Concrete, checkable proof, not assertions:
- exit codes: e.g. `typecheck: exit 0`; `test suite: 11 pass, 6 skip, 0 fail`.
- live URLs: e.g. `GET / -> 200, title "..."`; `GET /admin -> 307 /signin`.
- git: e.g. `on origin/main @ <sha>`; `git log origin/BRANCH..HEAD empty`.
- artifact: for a UI change, a screenshot path or a live URL the gate can re-fetch. No artifact, no
  done.
- DEPTH self-attestation (research/content): state how the deliverable meets the depth standard from
  the brief, not just that it is correct.

### Gates owed
Which gates this change_class still requires and are not yet PASSED. `NONE` only when all required
gates have a logged PASS bound to this commit_sha. If any are owed, this is not done.

### Follow-ups
Open items and who owns them.
