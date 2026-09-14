# Roadblock register

The spine of the kit. Each row is a roadblock (a way an agent team becomes unreliable), paired with
the MECHANISM that removes it. The mechanism is classified by how strong it is:

- **BLOCK**: machinery that makes the wrong action fail immediately (a hook, a gate, physical
  isolation). Strongest. An agent cannot proceed through a BLOCK by forgetting.
- **CHECK**: a runnable script that returns pass or fail against evidence. An agent (or a human) runs
  it, so it can be skipped, but its output is objective and unfudgeable when run.
- **PROCEDURE**: a rule that still depends on the agent doing it. Weakest. Used only where no BLOCK or
  CHECK is possible, and always paired with a CHECK that detects the omission after the fact.

The design rule: push every roadblock to the strongest mechanism it can have. A roadblock that today
is only a PROCEDURE is a backlog item to convert into a CHECK or a BLOCK, not an acceptable resting
state. That conversion is the entire value of this kit over the descriptive playbook.

Roadblocks are grouped by the theme they belong to. Failure IDs (F1 etc) cross-reference the
common-failure-modes each row was drawn from; every failure is described in place here where it
matters, so no external catalogue is needed to read this register.

---

## Verification roadblocks (the dominant theme)

| Roadblock | Failure | Mechanism | Class | Artifact |
|---|---|---|---|---|
| "Done" declared from memory, not evidence | F1, F2 | A done-check script that greps git (branch pushed, on origin/main), the gate ledger (PASS logged), and the live URL (returns 200) and prints DONE or the missing piece. "Done" is the script's exit code, not an agent's judgment. | CHECK | scripts/done-check |
| First-pass output accepted without a second look | F1 | The done-check refuses to pass a UI task without a captured artifact (a screenshot path or a live URL it re-fetches). No artifact, no done. | CHECK | scripts/done-check |
| Confident but unverified fact or "impossible" claim | F10 | A rule the manager must cite the check for any "impossible/blocked" claim, paired with a review prompt that rejects an unsourced limitation. Cannot be fully mechanised; caught at review. | PROCEDURE + CHECK | templates/rulebook, scripts/gate-check |
| Thin-but-correct deliverable accepted | F15 | The acceptance-bar template forces a DEPTH standard field on research/content tasks; the done-check requires the depth-bar field to be filled and self-attested against, and the reviewer gate tests against it. | CHECK | templates/handoff, scripts/gate-check |
| Manager reports "verified" without looking; hands verification to the owner | F16 | The owner-contract states the manager owns verification at every autonomy level and the owner is not the QA. A gate PASS is necessary not sufficient; "verified" requires the manager to have looked at the real artifact (the live page, what an image depicts, the link resolving), not trusted a handoff. Hard to fully mechanise (a human-eye check), so it is a PROCEDURE backed by the done-check artifact requirement (no artifact, no done). THE MOST-VIOLATED ROADBLOCK on one real project this kit was built from: treat F16 as the spine, not a row. | PROCEDURE + CHECK | templates/owner-contract, scripts/done-check |
| "Resolves 200" treated as "is correct" | F17 | An asset returning HTTP 200 and rendering is NOT evidence it is the right asset. On one real project a wrong-discipline photo, a specific person's photo, and a dead-link-that-still-resolves all passed a 200 check and shipped. The done-check must separate LIVENESS (returns 200) from CORRECTNESS (is the right thing), and correctness for media or an outbound link requires a human-eye or content check, not an HTTP code. The gate prompt for any media/content task asks "did the manager view what it actually depicts", not "does it load". | PROCEDURE + CHECK | scripts/done-check, templates/handoff |
| Manager verified the CODE but never LOOKED at the rendered result | F16, F17 | For any visible change (UI, imagery, copy, layout), the manager must open the live rendered artifact and look, not read the diff or trust "it builds". Mechanise what you can: the done-check requires a captured screenshot path or a live URL it re-fetches for a UI/media task; the human-eye confirmation of WHAT is shown stays a procedure the manager owns. | PROCEDURE + CHECK | scripts/done-check |

## Coordination roadblocks

| Roadblock | Failure | Mechanism | Class | Artifact |
|---|---|---|---|---|
| Two sessions share a checkout and wipe each other | F14 | One git worktree per session, created by a setup script. Cross-session file damage becomes physically impossible, not a rule to remember. | BLOCK | enforcement/new-session (worktree setup) |
| Worktrees spawned in the OWNER'S ROOT and left there | F20 | On one real project the manager created every worktree in the parent folder (the owner's git root, beside all their other repos) and never removed one when its job finished. Nine stray folders piled up in the owner's root, plus an orphaned dev server holding one open. The owner experienced it as a manager throwing mess across a workshop they keep spotless (an entitlement failure: treating the owner's filesystem as scratch space). Mechanism: new-session defaults WORKTREE_PATH to `<repo>/.worktrees/<session>` INSIDE the repo (gitignored, extensions.worktreeConfig on), never the parent; each job removes its own worktree and kills its own dev server on finish; the manager stays inside its own repo and touches nothing outside it. | BLOCK + PROCEDURE | enforcement/new-session (in-repo .worktrees default), INSTALL.md (.worktrees gitignore step) |
| A session touches a file another session claimed | F14 | A pre-commit hook reads the claim ledger and blocks a commit that touches files claimed by another active session. | BLOCK | enforcement/hooks/pre-commit-claim |
| Work stays local and never pushed | F2, F8 | The done-check fails while `git log origin/BRANCH..HEAD` is non-empty. Unpushed literally cannot read as done. | CHECK | scripts/done-check |
| Stalling / letting an autonomous run die | F8 | A reconcile script the manager schedules on a timer, which re-reads the board and re-drives stalled items; the INSTALL step wires the wake-up so a pause advances work. | CHECK | scripts/reconcile |
| Tool-task mismatch (agent lacks the tool for the job) | F13 | A pre-dispatch checklist in the delegation template that names the required tools, and a rule the manager confirms the agent has them before dispatch. | PROCEDURE | templates/delegation |

## Gate and quality roadblocks

| Roadblock | Failure | Mechanism | Class | Artifact |
|---|---|---|---|---|
| Work merged before its gates pass | F2 | A gate-check script and a pre-merge (or pre-push to main) hook that blocks unless reviewer plus security plus qa (as the change class requires) have a logged PASS for this exact HEAD. | BLOCK | enforcement/hooks/pre-push-gate, scripts/gate-check |
| The agent that made the work signs off its own work | F2 | The gate-check verifies the PASS author is not the work author (from the hand-off log fields). Self-sign-off fails the gate. | CHECK | scripts/gate-check |
| Commits added to an already-gated tip (gate invalidated) | (project) | The gate PASS is bound to a specific commit SHA; a new commit invalidates it and the pre-push hook re-requires the gate. | BLOCK | enforcement/hooks/pre-push-gate |
| Wrong change class gets the wrong gates | F2 | The gate-check reads a required "change-class" field from the hand-off and enforces the matching gate set: auth-data-input needs reviewer plus security plus qa, presentational needs reviewer plus qa, static needs reviewer. | CHECK | scripts/gate-check, templates/handoff |
| A gate PASS on sensitive work is not answerable against a project's registers | (seam 2) | gate-check reads ONLY fields 1 to 5 of a ledger row (cut -d'|' -fN) and ignores anything after field 5, so a row may carry reserved trailing key=value cells (e.g. `SHA . class . gate . verdict . author . ref=D-15,T-014`) that a project requires and cross-checks against its own decision/test registers. Documented as a supported convention in the gate-check header so it is not tidied away; no behaviour change. | CONVENTION (no code change) | scripts/gate-check |

Note (done-extra, seam 1): done-check now composes a fourth gate, project-supplied extra checks
from a `.team/done-extra` file and/or a `DONE_EXTRA_CHECKS` env var (both additive, all must exit
0), so a repo's OWN validators (doc/test/compliance) become part of the definition of done instead
of a second arbiter that can disagree. Absent/empty file with unset env is a strict no-op
(backward compatible). See scripts/done-check and the KS1 cases in tests/integration-test.

## Content and sourcing roadblocks

| Roadblock | Failure | Mechanism | Class | Artifact |
|---|---|---|---|---|
| Sourcing nothing, then over-relying on one or two sources | F3 | A breadth check: a script that counts distinct sources across the content set and warns below a threshold; a review prompt that flags single-source dominance. | CHECK | profiles/<project>/breadth-check.sh (example-instance) |
| An asset MISREPRESENTS what it shows (wrong entity, wrong person, wrong category) | F18 | The single most damaging failure on one real project: a real person from team A (wearing team A's logo) was used as team B's page image, and a milsim photo was labelled as a speedsoft photo. An image passing "loads 200" says nothing about whether it depicts the RIGHT thing. Rule: before ANY sourced media goes live, someone LOOKS at what it actually shows and confirms it depicts the correct entity/person/category and misrepresents no one. Prefer OWN-SOURCE assets (an entity's own site/photo) so the subject is definitionally correct. Never use a generic or another entity's asset as a stand-in for a specific named entity. Cross-check: no two entities share an asset file; each asset's caption/alt matches what it shows. Caught by a manager eye-pass and a reviewer cross-entity sweep (assert no asset is reused across distinct entities). | PROCEDURE + CHECK | templates/rulebook, scripts/gate-check |
| A published OUTBOUND LINK rots to a dead, parked, or hijacked domain | F19 | On one real project a live link (a closed venue's domain) had been parked and 301-forwarded to a competitor, plus two others went NXDOMAIN, all shipping live. A directory/link-heavy site must periodically RE-VERIFY every published outbound link resolves, has valid TLS for that host, and lands on what it claims (not a park page, not an off-host redirect). Dead links get removed or repointed to an archived snapshot; never leave a resolving-but-wrong link live. | CHECK | scripts/link-liveness-check (example-instance), scripts/reconcile |
| Withholding assets the owner already cleared | F4 | The rulebook states the owner's cleared-asset policy as an executable default (use and list, do not withhold); the review prompt checks the list exists. | PROCEDURE | templates/rulebook |
| Internal notes / wrong data leak to public | F7 | A pipeline guard that throws if an internal-note token reaches a public column, plus a public-copy audit script run before ship. | BLOCK + CHECK | profiles/<project>/public-copy-guard.sh (example-instance) |

## Communication and memory roadblocks

| Roadblock | Failure | Mechanism | Class | Artifact |
|---|---|---|---|---|
| Asking permission for an already-authorized action | F11 | A standing-authorization field in the owner-contract template that records what the standing order covers, so the manager checks the record instead of re-asking. | PROCEDURE | templates/owner-contract |
| No failure ledger kept | F12 | The kit ships an empty RETROSPECTIVE ledger as a required file; the self-test fails if it is missing, and the reconcile prompts an entry when a gate FAILs. Each entry's failure cell leads with `SHA <short> TASK <id>: <what failed>` so the ledger is greppable by SHA and task id ("why did gate X pass a defect on SHA Y" is answerable with a grep). Documented convention in the template header; no format or parser change. | CHECK + CONVENTION | templates/retrospective, scripts/self-test |
| Guardrails set up AFTER work starts (retrofit) | (project) | INSTALL.md orders the substrate FIRST and ships a self-test that refuses to green-light real work until hooks, worktrees, gates, and ledgers are all in place. | CHECK | scripts/self-test, INSTALL.md |

## Distribution and self-update roadblocks

These exist because the kit ships as a PUBLIC repo that projects pull, with an owner-only write side
and a per-session version check. A public, self-updating payload is a supply-chain surface; the
mechanisms below keep it from becoming a hole. Full design: agentic-discussion D6 (threads 0006/0007)
and the security conditions C1 to C6 recorded with this kit's distribution design.

| Roadblock | Failure | Mechanism | Class | Artifact |
|---|---|---|---|---|
| A stale copy drifts silently behind the kit and nobody notices | (distribution) | A SessionStart hook fetches the public VERSION once per session and warns (to stderr) when the local copy is behind, naming the installed and available versions and telling the user to git pull. Claude Code has no per-run check; per-session is the finest possible, and this is stated so no one promises per-run. | CHECK | enforcement/hooks/session-version-check, VERSION |
| The version check itself becomes a remote-code-execution hole (fetch-then-run) | (distribution) | The check is READ-AND-WARN ONLY: it never auto-pulls and never executes anything it fetched. Applying an update is always a human git pull after reading the diff. Enforced conditions C3 (read-and-warn), C4 (pinned https raw URL, TLS only, no cross-host redirect, small max-time). | BLOCK (by design) + CHECK | enforcement/hooks/session-version-check |
| A slow or offline GitHub blocks or hangs a session | (distribution) | The check has a hard timeout (about 2s) and FAILS OPEN: on timeout, offline, error, junk body, or no fetch tool it falls back to the local version and lets the session proceed. Always exits 0. | BLOCK (by design) | enforcement/hooks/session-version-check |
| A tampered or rolled-back remote version is treated as an update | (distribution) | A remote version LOWER than local is treated as SUSPICIOUS (stale mirror or tampering), reported as such, and never advised as an update. Numeric-token comparison; a non-numeric body is ignored. | CHECK | enforcement/hooks/session-version-check |
| A bad or malicious push to public main propagates to every puller | (distribution, governance) | Branch protection + required review + signed release tags on the public repo BEFORE git-pull-to-update is advertised (condition C5). This is the whole trust boundary of a public self-updating kit and is the OWNER's governance step, not an agent action. Until it is true, adopters update by reading the diff, not by blind pull. | PROCEDURE (owner-owned) | repo governance, INSTALL.md Step 7 |
| An update overwrites a project's own filled profile | (distribution) | VERSION gates CORE only. Profiles and `.team/` are the adopting project's data; an update refreshes core and never overwrites a filled profile (consistent with core-reads-only-`.team/`). | CONVENTION | agentic-discussion D6 |
| A shipped example profile tempts an adopter into running a dangerous default | (distribution) | Shipped profiles' gate commands must be inspection-only, local, read-only (C1); INSTALL carries an explicit review-before-you-paste warning (C2) because `.team/done-extra` runs with the user's full shell privileges. | PROCEDURE + CHECK | INSTALL.md Step 1b, profiles/example.md |
| The security gate is hollow (a PASS with no real review behind it) | (distribution) | The kit's security gate is only meaningful if the security agent has the owasp-advisor review skill. Install ensures it is present (detect, clone-if-absent, never clobber, never auto-pull). Honest limit: a same-model reviewer is not an independent lens; anything critical needs a human or a different model. | CHECK + PROCEDURE | enforcement/ensure-owasp, OPERATING.md |
| The kit's own version surfaces silently diverge | (distribution) | VERSION, plugin.json, and marketplace.json must agree; a mismatch means a bump was left incomplete and the self-update signal no longer matches the packaging. A check compares them and fails the suite on drift. | CHECK | scripts/version-consistency-check |

## Cost and non-git-artifact roadblocks

| Roadblock | Failure | Mechanism | Class | Artifact |
|---|---|---|---|---|
| Cost / token blowout: a team plus a reconcile timer spends without a cap | (cost) | A cost-check that compares current spend to a declared budget and BLOCKs at or over it, warns near it, and fails closed when spend is unreadable (an uncapped run is the failure). The kit supplies the gate and the rule; the environment supplies the spend number (--spend / --spend-cmd / TEAM_SPEND / TEAM_SPEND_CMD), the same seam pattern as done-extra. Wire it before a reconcile timer and as a done-extra line. | CHECK | scripts/cost-check |
| "Done" claimed for a running service that is not actually up (non-git, non-HTTP) | (verification) | done-check gained a `port=` artifact: it asserts a live service answers on a host:port, the artifact a git check and an HTTP check both miss. Joins url= (HTTP 200) and path= (file exists). A closed port blocks done. For any other non-git artifact (a command that must exit 0), the `.team/done-extra` seam already runs it as part of done. | CHECK | scripts/done-check |

---

## Limits (stated plainly, this is n equals 1)
This register hardens against the failures THIS project hit. It is blind to failure modes the project
never encountered, and a future team will hit some of those. Known gaps this kit does NOT yet remove,
and should grow to cover as real usage surfaces them:

- **Agents agreeing on a wrong answer** (correlated error, a gate rubber-stamping a real hole): the
  gate model assumes independent lenses, but two agents can share a blind spot. Needs adversarial
  review prompts and, ideally, a check that a gate actually exercised the artifact, not just read it.
- **A reviewer or security gate passing a genuine defect**: gates reduce this, they do not eliminate
  it. The mega-menu round is the proof it can happen; qa caught what two gates missed. Sharper proof
  (F18): gates repeatedly PASSED images that MISREPRESENTED real people (a rival team's leader shown
  as another team) because every gate checked "loads 200 / builds", not "depicts the right thing". A
  human eye-pass on WHAT the asset shows is the only reliable catch, and it is a procedure, not a
  script. This is the core residual risk for any media/content work.
- **Correctness of media/content is not mechanisable to an HTTP code (F17/F18)**: liveness (200) is
  checkable; correctness (right subject, right entity, right discipline, no misrepresentation) needs
  a human or a content-aware check. The kit now names this but cannot fully BLOCK it.
- **Outbound-link rot (F19)**: the link-liveness check is an example-instance CHECK, not yet a shipped
  universal artifact. A directory site needs it scheduled (via reconcile).
- **Prompt-injection / untrusted content steering an agent**: not addressed here at all.

The honest framing for the eventual skill: this makes a team measurably MORE reliable by removing
known roadblocks mechanically. It does not make a team "reliable" as a guarantee. Reliability is a
rate, driven down by enforcement plus honest measurement across many projects. Every PROCEDURE row
above is a debt to convert into a CHECK or a BLOCK, and every Limit is a roadblock not yet removed.
