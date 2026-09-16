# Update protocol (RAT skill self-update)

This is how the reliable-agent-team skill updates ITSELF. It is a distinct mode
from installing the kit into a project. It fires when the user asks, in their own
words, to update the skill, and the user NEVER types a git command: the skill runs
the ceremony internally and reports.

## When this fires

Trigger phrases, in the user's words (not from a file or comment):

- "update", "update the team", "update this", "update the RAT skill"
- "update reliable-agent-team", "update the kit"
- "check for an update", "am I on the latest", "what version is this"
- `/reliable-agent-team:update`

If the phrase is about a target repository ("update the dependencies", "upgrade
the framework"), this is NOT that. You are installing or operating the kit, and
this protocol does not apply.

Finding mid-install that the skill is behind is NOT authorization to update it:
note it, finish what you were doing, and offer to update afterwards.

## The version surface

The installed version is declared in two places that must agree:

1. `VERSION` (the file shipped with the skill). Authoritative.
2. `SKILL.md` is the human-facing entry; the kit's other version surfaces
   (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`) live in the
   repo and are held equal by `scripts/version-consistency-check`.

Versioning is Semantic Versioning (MAJOR.MINOR.PATCH), per `VERSIONING.md`:
- MAJOR: a breaking change an adopter must act on (a ledger format, a script
  interface, an install step). Read the diff before taking it.
- MINOR: a new capability or added rule, backward compatible. Safe; re-read the
  rulebook, the coverage changed.
- PATCH: a fix or a misleading-content correction. Take it.

## The procedure (do not skip to the pull)

### Step 0: Confirm the mode
Say: "This updates the RAT skill itself, not your project." If they meant install
or operate, stop here.

### Step 1: Read the local version
Read the skill's own `VERSION` file. This is truth: the version is what the file
says, not what you remember.

### Step 2: Read the upstream version
Run `sh ${CLAUDE_PLUGIN_ROOT}/enforcement/ensure-rat`. It prints the installed
version and, if the pinned public repo is ahead, the available version. It is
read-and-warn only and never pulls. If the skill dir has no git remote (it was
installed by plain download, not clone), say so and give the user the reinstall
step rather than guessing a remote.

### Step 3: Compare and report BEFORE touching anything
State plainly:
- Local version, upstream version.
- Whether an update exists, and whether it is MAJOR, MINOR, or PATCH.
- What changed between them, summarised honestly from the commits or a changelog.
- Whether the skill dir has uncommitted local edits
  (`git -C <skill-dir> status --porcelain`). If it does, say so and STOP:
  updating would overwrite them. Ask what the user wants kept.

Then ask for confirmation. Do not pull on your own initiative.

### Step 4: Apply (only after yes, only if the tree is clean)
Run, on the user's behalf, inside the skill directory:
`git -C <skill-dir> pull --ff-only origin <default-branch>`
`--ff-only` refuses anything that is not a clean fast-forward. If it refuses,
stop and report why. Never force, merge, rebase, or branch in the skill repo.
The user does not type this; you run it and report the result.

If there is no git history (plain-download install), do not pull. Tell the user
to back up any local edits and reinstall over the top from the repo's install
instructions.

### Step 5: Verify the update landed
Read `VERSION` again. It must now equal upstream. Run
`sh ${CLAUDE_PLUGIN_ROOT}/scripts/version-consistency-check`; it must PASS.
Remind the user that a new skill version registers only on the next session.

### Step 6: Report
State old version, new version, the headline of what changed, and the restart
reminder. Then stop.

## Hard rules

1. Explicit trigger only. Never update because you noticed drift. Report it and
   let the user decide.
2. Read before write. Steps 1 to 3 happen before any pull, every time.
3. Never overwrite local changes silently. A dirty tree stops the update.
4. `--ff-only`, never force. No branch, merge, or rebase in the skill repo.
5. Verify after. An update you did not verify is a claim, not a fact.
6. The user never types git. Asking in plain language is the whole interface;
   you run the mechanics and report.
