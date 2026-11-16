# Management method: planning and delivery

The rulebook covers the quality half of managing (delegate, gate, verify). This covers the
delivery half. It is short on purpose: each rule below is a CHECK the kit runs, and this file only
says what it does and why. A rule that is only read gets skipped (`WHY-KAREN.md`).

Turn it on by copying `templates/COMMITMENTS.md` to `.team/COMMITMENTS.md` (and optionally
`templates/wip-cap`). Thread `agentic-discussion/0012` holds the evidence it was built from.

## The owner's only input

The ordered list, once a week, in `.team/COMMITMENTS.md`. Nothing else here asks the owner for
anything, except a row the team cannot move without the owner's decision.

## The checks

| # | Rule | Enforced by | Why |
|---|---|---|---|
| 1 | Work the list in order. A producer session (architect, researcher, developer) starts only on the top open row, or joins a row already active. A stuck row is blocked with a reason, and the next row becomes the top. Every agent a manager starts names its row (`Row: <id>`), no exceptions; obligations the project's rules require weekly get a `standing` row. | `new-session --row` and the Agent-tool hook `hooks/dispatch-agent` run `commitments dispatch` (BLOCK) | F21: managers chose what was closest to landing; 20 items landed, 0 of 6 commitments finished. |
| 2 | The week's promise is computed from rows finished in the last 3 complete weeks. The manager never writes a promise. | `commitments promise` (CHECK) | F22: promises were set by guess and missed twice. |
| 3 | Progress is reported only by the script, as rows promised vs rows finished. No hand-written percentages. | `commitments report` (CHECK) | F23: guessed figures (45, then 55 out of 100) were given as measured. |
| 4 | At most `wip-cap` rows active at once (default 2). | `commitments dispatch` (BLOCK) | F24: up to nine agents at once; the usage limit hit three times. |
| 5 | Every owner message to the manager is logged and must be mapped to a row or declined with a reason before the next dispatch. | `hooks/owner-inbox` plus `commitments dispatch` (BLOCK) | F25: of 8 owner instructions, none was done in the time the owner set. |
| 6 | A row is done only when done-check exits 0; the script stamps it. | `commitments done` (CHECK) | F26: "done" from memory. |
| 7 | The project's recurring defects live in the profile's RECURRING DEFECTS section and every brief carries them. A defect that fails a gate twice gets a test. | `templates/delegation.md`, profile (PROCEDURE) | F27: the same server defect in two slices, from briefs not checked against the server. |
| 8 | The commitment report runs on the reconcile timer. | `scripts/reconcile` (CHECK) | F28: an AI has no sense of time; a daily check it must remember does not happen. |
| 9 | A retrospective that wants a process change writes a proposal to the kit maintainer. The manager never edits its own rules. | rulebook section 11 (PROCEDURE) | F29: a managed agent rewriting its own process weakens it. |

## Limits (stated plainly)

- The checks force the form, not judgement: a manager can still triage a message wrongly or write
  a weak brief that passes.
- The list and the cap are working-tree files the manager can edit; edits show in git history,
  they are not blocked.
- The promise assumes rows of similar size, and the first week has no history.
- Facts from memory and relayed claims in chat: no check.
- State changes run one at a time under `.team/.commitments.lock`. A lock left by a killed
  process is reclaimed by the next change within a few seconds, and the reclaim is written to
  `.team/commitments.log` (so are standing-row releases, with who released them). A lock whose
  holder is still alive is never taken: others refuse with BUSY until it finishes.
- The role is per checkout (`.team/whoami`), not per chat. Other chats sharing the manager's
  checkout count as the manager; give them their own worktree and whoami.
- A running standing row (`standing: active`) holds a place under the cap until
  `scripts/commitments release <id>`; a manager that forgets to release it loses that place.
- Every agent's role is read from `.team/whoami` at the repo top. A session whose role does not
  resolve is denied the Agent tool while the checks are on.
