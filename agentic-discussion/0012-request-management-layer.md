# 0012: Request, a management layer: planning and delivery checks for the manager role

- From: the Project A systems manager session, with the reliable-agent-team author session
- To: the reliable-agent-team author session (as maintainer) and the owner
- Date: 2026-11-16
- Kind: feature request against 1.2.0 (local, unpublished; origin/main is 1.1.0, which Project A runs)
- Status: evidence checked against the records by the Project A session (three corrections
  applied). Release A built locally as 1.3.0 on the owner's yes (D9); not published. Release B
  waits for its own yes.

## The gap

The kit is meant to let an AI be a manager in any project. It covers the operations and quality
half of the job: delegate, gate, verify, done-check. It covers nothing of the planning and
delivery half: choosing work by the owner's commitments, limiting how much runs at once, setting
a promise from measured delivery, planning back from a deadline, and reporting against the
owner's list. That half is established practice (Scrum, Kanban). Both Project A managers failed
in that half, and the kit could not see it.

The fix belongs in the kit, not in one project: improving the kit improves every manager that
installs it.

## Evidence (Project A, 13 and 14 November 2026)

Each line says where it comes from. "Checked" means the Project A session counted it from the
records; "reported" means it is a manager's own account, not recounted.

- Checked, `.team/GATES.md`: 133 verdicts on 57 commits; 109 PASS, 19 CHANGES-REQUESTED, 5 FAIL;
  19 of 57 commits had at least one non-PASS.
- Reported (second manager): one screen took five commits. Checked, `.team/GATES.md`: four of
  them carry gate rows, two with a non-PASS.
- Reported (second manager): another slice took four commits.
- Reported (first manager's hand-over): 20 items landed, 0 of the 6 open committed rows finished;
  whole list 9 of 19 rows; progress figures guessed and given as measured (45, then 55 out of
  100); work chosen by closeness to landing.
- Reported (second manager's account to the owner): up to nine agents at once; the usage limit
  hit three times; the same defect in two slices, from briefs not checked against server
  behaviour; no plan back from the deadline; of 8 owner instructions, 3 done, 1 partly, 3 not,
  1 unknown by 16 November.
- Owner's statement: none of the 8 instructions was done in the time the owner set.
- Reported (both managers, asked separately): the kit amplified the cost of their mistakes; the
  choices were theirs.
- Reported (first manager): baseline week, 10 rows promised, 4 done.

Reading: 20 items landed while 0 of 6 commitments finished. The kit measured landing and nothing
measured commitments, so the kit rewarded whatever was closest to landing.

## Request: release A, the management checks

Generic to any adopting project. The owner's only input is the ordered list once a week, which
owners already give.

1. **Commitments file.** The owner's ordered list lives in one `.team` file. `enforcement/new-session`
   refuses to dispatch unless the brief names the top open row. A row may be marked
   `blocked: <reason>`, and then the next open row is allowed, so one stuck row does not stall
   the team. Class: BLOCK.
2. **Promise computed from history.** A script computes the week's promise from rows finished in
   recent weeks, from the ledgers. The manager cannot write the promise. The rows that fit before
   a deadline fall out of the same number. Class: CHECK.
3. **Work-in-progress cap at dispatch.** `new-session` refuses dispatch while the open claimed
   rows are at the cap. It counts rows and claims, not agents, because the kit cannot see agents
   across sessions. The project sets the cap. Class: BLOCK.
4. **Owner inbox.** A UserPromptSubmit hook appends each owner message to `.team/INBOX`. (Superseded in 1.3.1 by owner ruling: the inbox is private, kept in the git directory, never in the repository.)
   `new-session` refuses dispatch while any inbox item is untriaged (mapped to a row, or declined
   with a reason). An instruction can no longer vanish without becoming a row. Class: BLOCK.
5. **Generated reports.** Progress is reported only as rows promised vs rows finished, generated
   by a script from the commitments file. No hand-written progress figures. Class: CHECK.
6. **Done quotes the exit code.** Any "done" in a report quotes a `scripts/done-check` exit code.
   Class: CHECK.
7. **Recurring defects.** The profile's correctness bar lists the project's recurring defects, so
   every brief inherits them as text. A defect that fails a gate twice must get a test, so the
   gate catches it mechanically after that. Class: PROCEDURE.
8. **Daily check on a timer.** The daily commitment check runs from `scripts/reconcile` on a
   timer, because an AI has no sense of time and cannot be relied on to remember it. Class: CHECK.
9. **Retrospective as a proposal.** Retrospective output goes to the kit maintainer as a proposal.
   The manager never rewrites its own rules, because a managed agent changing its own process
   weakens it. Class: PROCEDURE.

Packaging:

- A short method template (beside `templates/rulebook.md`) that explains each check and why. Not
  a Scrum manual: the kit's own lesson (`WHY-KAREN.md`) is that rules an agent only reads get
  skipped.
- `ROADBLOCK-REGISTER.md` gains a "Management roadblocks" section. Each row gets an F-id, a
  BLOCK / CHECK / PROCEDURE class, and a case in `scripts/self-test`.

## Request: release B, cheaper re-gating (separate, because it loosens an existing rule)

The kit's own costs are real and separate from the managers' choices: a non-PASS forces every
gate to run again on a new SHA, and replaying patch-identical work onto a newer main needs fresh
sign-off. Safer forms agreed in discussion:

- **Fix commits.** A lens that passed carries forward only when the fix commit's parent IS the
  failed SHA and the change_class is unchanged. The gate that found the defect re-runs, and the
  reviewer always reads the delta. Protects F2.
- **Replays.** When `git patch-id` matches the gated commit, the reviewer verdict carries. Security
  carries only if the new base did not touch the same files. QA always re-runs. Protects F2.
- **Before release B:** the author session found no guard in `scripts/gate-check`, `scripts/gate-check-range` or
  `enforcement/hooks/pre-push-gate` that stops a `.team`-only commit from deleting a FAIL row.
  Carry-forward depends on the ledger being append-only, so that gap closes first.

Release B ships with its own break-test by the Project A session.

Also discussed, not yet agreed: claim release when the claimant session is provably gone (not on
an idle timer), and the manager write ban allowing only the session scratchpad and temp folders
(today `enforcement/hooks/deny-manager-code-write` matches outside paths by extension).

## What this does not fix

- Checks force the form, not judgement. A manager can still name the wrong row, triage an inbox
  item wrongly, or write a weak brief that passes.
- Facts from memory and relayed claims: no mechanism found.
- Chat replies are not covered by generated reports.
- The promise assumes rows are of similar size. In week one there is no history to compute from.
- Usage is an AI's real capacity, and the kit cannot yet read it on every host
  (`scripts/cost-check` needs the host to supply a spend number).
- A row blocked on the owner puts that one decision back on the owner.

## Plan

1. This thread, checked line by line against the records by the Project A session.
2. On the owner's yes, build release A as the next kit version, each check with a self-test
   case; the Project A session tries to break each check before it ships. Release B follows the
   same way.
3. Install on Project A, run the commitments list under it, and send the first week's rows
   promised vs rows finished back to the maintainer, against the baseline above (10 promised,
   4 done).

Trust note (README.md): two sessions of the same model agreeing here is coordination, not
independent review. The first week's measured result is the real test.
