---
name: install
description: Lay the reliable-agent-team enforcement kit into a project: guards, gates, worktrees, ledgers, and the session version check. Use when the user wants to set up, adopt, or install the reliable-agent-team into a repo. To UPDATE the kit itself instead, use the reliable-agent-team update skill.
argument-hint: "[target directory, defaults to the project root]"
allowed-tools: Bash Read Write Edit Glob Grep
---

# Install the reliable-agent-team kit into a project

You are laying the enforcement kit into an adopting project. The kit source lives at
`${CLAUDE_PLUGIN_ROOT}`. Follow the ordered procedure in `${CLAUDE_PLUGIN_ROOT}/INSTALL.md`; that
file is authoritative. Do not improvise past it.

If the user asked to UPDATE the kit itself (not install it into a project), this is the wrong skill:
use the reliable-agent-team update skill, which fetches and applies the latest version for them.

## Do this

0. FIRST, make yourself aware of the installed kit's version and whether it is stale. Run
   `sh ${CLAUDE_PLUGIN_ROOT}/enforcement/ensure-rat`. It prints that reliable-agent-team is installed
   and at what version, and if the public repo is ahead, that an update is available. It is
   read-and-warn only: it never pulls. If it reports the kit is behind, tell the user and offer to
   update it (the update skill does this for them, no git command typed). Prefer updating BEFORE
   laying the kit in, so you install the current version, not a stale one.
1. Read `${CLAUDE_PLUGIN_ROOT}/INSTALL.md` in full first. It defines the order, and the order is the
   point: the coordination substrate goes in BEFORE any parallel work.
2. Copy the templates and ledgers into the project's `.team/` exactly as Step 1 describes (keep the
   ledger headers and column order; the hooks and scripts parse them).
3. Select or author a profile (Step 1b). Core carries no stack knowledge; the project's stack,
   correctness bar, and gate commands live in a profile that a human resolves into `.team/`.
   REVIEW BEFORE YOU PASTE: every `.team/done-extra` line runs with the user's full shell privileges.
   Copy only commands the user has read and trusts. Never paste a line that fetches remote content and
   pipes it into a shell.
4. Install the two universal hooks (Step 2) with `${CLAUDE_PLUGIN_ROOT}/enforcement/install-hooks`.
   Then ensure the security dependency is present: run
   `sh ${CLAUDE_PLUGIN_ROOT}/enforcement/ensure-owasp`. It installs the
   owasp-advisor skill if absent and leaves an existing copy untouched (warning
   if it is behind). The RAT security gate is a hollow checkbox without it, so if
   this exits non-zero, stop and resolve it before relying on the gate.
5. Create the first worktree INSIDE the repo (Step 3). Never in the parent folder.
6. Run `${CLAUDE_PLUGIN_ROOT}/scripts/self-test` and refuse to start real work until it exits 0
   (Step 4).
7. Run `${CLAUDE_PLUGIN_ROOT}/tests/integration-test` to prove the guards actually block (Step 5).
8. Wire the drive loop (Step 6) and, if the user wants stale-copy warnings, the session version check
   (Step 7).

## Hard rules (do not skip)

- Do not start real work before `self-test` exits 0. A red self-test means the surface is not prepared.
- Do not weaken any guard to make a step pass. A guard that does not block is worse than none.
- The version check is read-and-warn only. It never pulls and never runs fetched content. Applying an
  update is done through the update skill, which shows the diff and fast-forwards; it is never a silent
  pull.
- Anything compliance or safety-critical still needs a human sign-off. An agent thread is not
  independent review.

## Report honestly

When done, tell the user exactly which steps passed, which were skipped and why, and paste the
`self-test` and `integration-test` results. Do not report the install as complete unless both exit 0.
"Files copied" is not "installed and verified".
