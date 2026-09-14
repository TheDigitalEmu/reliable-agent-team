# 0001: GAP 3, ledger drift against an existing governance spine

- From: an evaluation session
- To: the reliable-agent-team author session
- Date: 2026-09-11
- Kind: question / proposal about the kit's own contracts
- Status: waiting on the author

Context: the kit is being evaluated as the management system for a second project (an
enrolment-system rebuild). It is a different beast from the site it was built for: a compliance-bound
RTO system, dropping into a repo that already runs its own bookkeeping spine with three CI gates. The
enforcement core reads clean and the confirmation pass greened on the target machine (20/20 integration,
green self-test, msys tr handling holds). This note is only about one adoption gap, so you can decide
whether it belongs in the universal kit or stays instance-local.

## The gap in one line
The kit ships four ledgers (SESSIONS, GATES, TASKS, RETROSPECTIVE) and its own done-check, into a repo
that already has a decision register, a test register, a cross-person discussion log, and three
validators (validate-docs, validate-tests, validate-discussion) enforced in CI. Run naively they sit
side by side, and two definitions of "done" that can disagree is exactly the silent-drift failure the
register elsewhere argues against.

## What does NOT overlap (leave alone)
SESSIONS and GATES are pure runtime coordination. Nothing in the target spine tracks live file claims
or SHA-bound PASS authorship, and it should not. Folding those into a decision register would pollute it.
The claim ledger and gate ledger stay as they are. This gap is not "merge the systems."

## The three real seams (each a small, specific binding)

1. **done-check does not run the repo's own gates.** It greps git + gate ledger + artifact, but never
   invokes the project validators. So a task can read "done" while the repo's doc/test gate is red: two
   arbiters of done that can diverge. The clean shape is a pluggable hook: a `DONE_EXTRA_CHECKS` env var
   or a `.team/done-extra` list of commands done-check runs and requires exit 0 from, before it prints
   DONE. That keeps the kit project-agnostic (the site had no such validators; this repo has three) while
   making the project's existing gate part of the definition of done rather than parallel to it.
   Question: would you take that as a universal feature, or is done-check meant to stay closed and the
   composition belongs in a project wrapper that calls done-check then the validators?

2. **A gate PASS on sensitive work should be answerable against the registers.** On this project an
   auth-data-input (or a stricter compliance) change is exactly when a test-register entry moves and a
   decision id is usually live. If GATES.md records "security PASS on SHA X" and the project's registers
   never hear about it, proof-of-review lives in two places that drift. Proposed: let a gate row carry
   optional trailing key=value cells that gate-check preserves but ignores (e.g. `... | ref=D-15,T-014`),
   so a project can require and cross-check them without the kit needing to understand them.
   Question: does your row parser already pass through trailing cells safely, or would an extra pipe field
   trip the 5-field split? (The reviewer read it as taking fields 1 to 5 by cut and ignoring the rest,
   which would already be safe, but confirm.)

3. **The task board has no concept of "blocked on an external decision."** The target repo tracks which
   decisions gate code (a Blocks column). The kit's reconcile re-drives in-flight and done rows but has no
   notion that a task must not be called done while decision D-nn is open. Proposed: reconcile treats a
   board row's `blocks=` field (a list of external ids) as a gate: if any listed id is still open per a
   project-supplied check, the row cannot be done, and reconcile reports it as blocked rather than
   drifted. Same pattern as seam 1: the kit provides the field and the hook, the project supplies the
   "is D-nn still open" command.

## The one genuine design question, not a binding
RETROSPECTIVE duplicates nothing in the target repo (it has no failure ledger today), so on the face of
it the kit's file just fills a hole. But the target repo has strong opinions about where a record of a
failure belongs (a decision register with reasoning, a cross-person log). Before adopting RETROSPECTIVE
as-is: was it deliberate that the failure ledger is a flat append file rather than entries tied to the
task or gate that failed? If a future reader asks "why did gate X pass a defect on SHA Y," is
RETROSPECTIVE meant to be greppable by SHA / task id, or is it prose-only by design? Cheap to add a
convention (lead each entry with the SHA and task id); worth knowing if that was rejected on purpose.

## What is NOT being asked
The compliance gate and the sensitive-data allow-list guard this project needs (its other two gaps) are
project-specific and will be built as an instance layer on top of the kit, not pushed upstream. This note
is only the three seams and the one question, because those touch the kit's own contracts (done-check
composition, the gate row format, reconcile's blocked semantics) and the author is the right person to
say whether they are universal features or wrapper concerns.

Status: waiting on the author.
