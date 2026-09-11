# Profile: <yourproject>

Copy this file to `profiles/<yourproject>.md` and fill every section. This is the project-specific
half of the kit: everything core deliberately does NOT know. Core reads NONE of this at runtime; a
human resolves it into the adopting repo's `.team/` at install time (see INSTALL.md Step 1b). A
profile is additive and removable: delete it and clear the `.team/done-extra` lines it produced, and
core reverts to its three-gate no-op behaviour.

See `profiles/gelball.md` for a worked, filled example.

---

## PROJECT
<one line: what the project is>

## OWNER
<the business owner's name; the manager is the only agent that talks to the owner>

## STACK
<language, framework, host(s). Free text only; core never reads this.>

## CORRECTNESS BAR
<the concrete acceptance staples the delegation and hand-off templates reference generically, e.g.:>
- <typecheck / lint / build / tests green>
- <any output-style rule, e.g. a punctuation constraint>
- <any security invariant, e.g. no privileged key in the client bundle; data-access rules not weakened>
- <committed AND pushed AND (for gated classes) all required gates PASSED, verified live>

## PROJECT GATE COMMANDS
<the exact shell commands that become `.team/done-extra` lines, one per line. Each must exit 0 for
done-check to reach DONE. Keep these LOCAL, READ-ONLY, INSPECTION-ONLY: no network egress, no writes
outside the repo, no deletion, no fetch-piped-into-a-shell.>

```
<command 1>
<command 2>
```

REVIEW-BEFORE-YOU-PASTE: these lines run with your shell's full privileges on every done-check. Copy
only what you have read and trust. Never paste a done-extra line that fetches remote content and
pipes it into a shell.

## PROJECT SCRIPTS
<list any project-supplied scripts under `profiles/<yourproject>/`, one line each on what it does and
how it is wired (which done-extra line or scheduled reconcile call runs it)>

## INTERNAL-NOTE TOKENS
<the value for `TEAM_INTERNAL_TOKENS`, consumed by a public-copy guard if the project uses one;
newline- or comma-separated, case-insensitive substring match>

## MODEL ASSIGNMENT
<the per-role model choice: which roles run on the strong model, which on a cheaper one>

## PROJECT HOOKS
<any git hooks NOT shipped by core. Core ships only pre-commit-claim and pre-push-gate; everything
else the project installs itself with its own tooling>

## CONTENT LAYOUT
<only if the project uses a breadth check: content dir, file globs, breadth floor>

## LEGAL / DOMAIN POLICY
<any project-specific content rule. Core states the generic no-fabrication rule; the domain specifics
live here>

## RESERVED-CELL CONVENTION
<declaration only: if the project cross-references gate rows against its own registers (ref=...) or
uses a blocks= external-decision field, document it here. Core ignores fields past the fifth.>

## TEAM_DIR
<if the project does not use the default `.team`, record the TEAM_DIR override here>
