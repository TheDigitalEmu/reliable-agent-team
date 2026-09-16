# Profile: Axiom Apply (enrol.axiomcollege)

The project-specific half of the reliable-agent-team kit for the Axiom Apply build. Core reads none
of this at runtime; it was resolved into this repo's `.team/` at install time (INSTALL.md Step 1b).

---

## PROJECT
The rebuild of the Axiom College student application and enrolment system: a React front end
(axiom-frontend) and a Node/Express API (axiom-backend) on self-hosted Supabase, replacing the live
PHP/MySQL system at apply.axiomcollege.com.au. Repo: enrol.axiomcollege under the Axiom-College org.

## OWNER
Jamie (DigitalEmu). Also answers to Emu, DigitalEmu, Mu. The manager is the only agent that talks to
the owner. Tamara co-owns the project and owns the Axiom-side decisions, reached through the
`discussion/` folder, never as a live participant in this team.

## STACK
Front end: React 19 with Vite, Tailwind, in `axiom-frontend`. Back end: Node 20, Express 4, in
`axiom-backend`. Database: self-hosted Supabase (PostgreSQL) on an internal network, not a hosted
supabase.com project. Hosting: pm2 fork mode behind nginx, one deployable. Tooling gates are Python
(the doc/test/discussion gates) run with `py` on Windows. Platform is Windows; scripts run under
Git's `sh`.

## CORRECTNESS BAR
- The three documentation gates pass: `py tools/validate-docs.py`, `py tools/validate-tests.py`,
  `py tools/validate-discussion.py`, each exit 0.
- The code lints, tests and builds: backend `npm run lint` and `npm test`; frontend `npm run lint`,
  `npm run lint:css` and `npm run build`, each exit 0.
- No em dash or dash look-alike anywhere (owner rule, enforced by the doc gate on docs; hold the same
  line in code and comments).
- No hard-coded colour value outside `axiom-frontend/src/tokens.css` (rule 8, enforced by the colour
  lint).
- RBAC and input validation enforced server-side on every request (rule 9); client checks are
  supplementary only.
- No AI component receives sensitive information (rule 13): enforced server-side by allow-list and
  proven by a test, never by a prompt instruction.
- Compliance outranks everything (rule 16): a design choice that breaks a regulatory requirement is
  not shipped and not recorded; stop and raise it.
- Every code change leaves the Test Register correct in the same commit (rule 17), and a feature is
  not done until its user-guide section is written (rule 12).
- Committed AND pushed AND (for gated classes) all required gates PASSED, verified live.

## PROJECT GATE COMMANDS
These become `.team/done-extra` lines. Each is local, read-only, inspection-only: no network egress,
no writes outside the repo, no deletion, no fetch-piped-into-a-shell. Each must exit 0 for done-check
to reach DONE.

```
py tools/validate-docs.py
py tools/validate-tests.py
py tools/validate-discussion.py
```

Note on the code gates: the backend and frontend lint/test/build commands are per-folder (they must
run inside `axiom-backend` or `axiom-frontend`), so they are not global `done-extra` lines. They run
in CI (`.github/workflows/validate-code.yml`) and are part of the qa gate's checklist rather than the
repo-root done-check. Add them as `done-extra` lines only if done-check is taught to run per-folder.

## PROJECT SCRIPTS
None yet. The repository's own gates live in `tools/` and are invoked directly by the gate commands
above, not wrapped.

## INTERNAL-NOTE TOKENS
TODO, FIXME, XXX, TBD-NO-DNUMBER, INTERNAL-ONLY. Note that a bare `TBD:` in a doc is legitimate only
when it carries a decision id; the doc gate already enforces that, so the token guard here targets
stray developer notes leaking into user-facing copy or generated content.

## MODEL ASSIGNMENT
Strong model: manager, architect, developer, reviewer, security. This is a compliance-bearing RTO
system where a wrong data model or a missed regulatory requirement is costly, so reasoning roles stay
strong. Cheaper model: qa, where the work is mechanical and self-verifying (run the build, run the
suite, check routes, read exit codes). Revisit if a cheaper model proves unreliable on the a11y and
contrast checks.

## PROJECT HOOKS
Core ships pre-commit-claim and pre-push-gate only. This project already runs its own CI gates via
GitHub Actions (the three doc gates and the code gate); those are not git hooks and are not installed
by core. No additional local git hook is added at install time. A local em-dash pre-commit guard
exists in the owner's environment (a harness rule); it is environmental, not part of this kit.

## LEGAL / DOMAIN POLICY
Compliance is the floor and is never traded (rule 16): AVETMISS, the Standards for RTOs 2025, the USI
Act, the Australian Privacy Principles, and state funding contract conditions. Where a requirement is
ambiguous, the safe reading is taken. A stated decision that conflicts with a requirement is not
recorded at all until the owner restates it. No AI component ever receives the sensitive fields listed
in rule 13. Every decision the build relies on must exist in `docs/decisions/decision-register.md`
with its reasoning and source (governance: the repository is the only memory).

## RESERVED-CELL CONVENTION
Gate rows may carry a trailing `ref=` cell pointing at a decision id (D-nn), a test id (T-nnn), or a
scope section, so a gate verdict is traceable to the requirement it protects. Core ignores fields past
the fifth; this convention is for humans and the project's own cross-checks.

## TEAM_DIR
Default `.team`. No override.
