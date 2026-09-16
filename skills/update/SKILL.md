---
name: update
description: Update the reliable-agent-team plugin itself to the latest published version. Use whenever the user says update, update the team, update reliable-agent-team, update the kit, check for an update, am I on the latest, or what version is this. Fetches the newest version, shows what changed, and applies it. The user never types a git command.
argument-hint: ""
allowed-tools: Bash Read Glob Grep
---

# Update the reliable-agent-team plugin

The user asked to update. Your job: fetch the latest published version of this plugin, show what
changed, and apply it. The user does NOT type any git command. You run the mechanics and report.

This updates the reliable-agent-team plugin ITSELF. It does not install anything into a project and
does not touch a project's own `.team/` data. If the user meant "update my project's dependencies",
that is not this; say so and stop.

## Do this, in order (do not skip to the apply)

Follow `${CLAUDE_PLUGIN_ROOT}/update-protocol.md` in full. In short:

1. Read the local version: the first non-comment line of `${CLAUDE_PLUGIN_ROOT}/VERSION`.
2. Check upstream: run `sh ${CLAUDE_PLUGIN_ROOT}/enforcement/ensure-rat`. It prints the installed
   version and, if the public repo is ahead, the available version. It never pulls.
3. If already current, say so and stop. There is nothing to do.
4. If behind, show the user: local version, available version, whether it is MAJOR / MINOR / PATCH,
   and an honest summary of what changed. Check for uncommitted local edits in the plugin dir; if any
   exist, STOP and ask what to keep (an update would overwrite them).
5. Apply on their behalf: `git -C "${CLAUDE_PLUGIN_ROOT}" pull --ff-only`. Never force, merge, rebase,
   or branch. If it is not a git checkout (plain download), tell the user to reinstall from the repo's
   install instructions rather than guessing a remote.
6. Verify: re-read VERSION (must equal upstream) and run
   `sh ${CLAUDE_PLUGIN_ROOT}/scripts/version-consistency-check` (must PASS).
7. Report old version, new version, the headline of what changed, and remind the user the new version
   registers on the next session (a plugin reload).

## Hard rules

- Read before write. Steps 1 to 4 happen before any apply, every time.
- Never overwrite local changes silently. A dirty tree stops the update.
- `--ff-only`, never force. No branch, merge, or rebase in the plugin repo.
- Verify after. An update you did not verify is a claim, not a fact.
- The user never types git. Asking in plain language is the whole interface.
