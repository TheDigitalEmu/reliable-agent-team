# Versioning policy

The `VERSION` token is the signal every adopting project checks. Bumping it tells
the wild to pull. This file is the rule for when that happens. It is the policy the
maintainer follows by hand; there is no automation enforcing it yet.

## What the version gates

CORE only. Core is every tracked file EXCEPT `profiles/` and the meta docs the
generic check exempts (HANDOVER.md, WHY-KAREN.md). Profiles are an adopting
project's own data; a core version bump never concerns them and an update never
overwrites a filled profile.

## The two-part shape

- CORE: the generic machinery (hooks, scripts, gate logic, the version check, the
  rulebook and other law-bearing templates).
- PROFILES: per-project specifics. Changes inside `profiles/` never bump the core
  version.

## Functional vs non-functional

A FUNCTIONAL change alters what the machinery does or what an adopter runs, reads
as an instruction, or relies on. A NON-FUNCTIONAL change leaves behavior identical.

Rough test: if you stripped comments and blank lines from every script and hook,
would the result differ? If no, the change is non-functional, UNLESS it falls
under the misleading-content rule below.

### Non-functional (do NOT bump on their own; they ride the next real bump)

- Comments or header text in a script or hook.
- Pure formatting, whitespace, local-variable renames.
- Markdown prose that is not an instruction and does not mislead (see the rule
  below): design narrative, history, reasoning.
- Adding or editing a TEST. A test proves behavior, it does not change it. A test
  result may TRIGGER a re-evaluation that leads to a core or profile change, but
  the test addition itself is not a version change.
- A new profile, or any edit inside `profiles/`.
- The `VERSION` bump-note comment lines.
- `.gitignore`, `.gitattributes`, license, keyword edits in `plugin.json`.
- Reordering with no parse impact.

### Functional (DO bump)

- Any change to a hook, script, or gate logic that changes behavior.
- The version check itself.
- A change to a machine-read contract: a ledger column, a printed string another
  script greps, the `.team/done-extra` or `DONE_EXTRA_CHECKS` semantics.
- A rule line in the rulebook or another law-bearing template that changes what an
  agent is required to do.
- An install-step change an adopter must act on.

### The misleading-content rule (the one exception that overrides "non-functional")

If a change CORRECTS instructions or output that would otherwise mislead an
adopter (a wrong path, a stale "do this" line, an error message that misdiagnoses
a real failure), it BUMPS as a patch, even though "only docs changed". A wild app
that never pulls until the next bump would otherwise keep following the wrong
instruction. Correcting a misleading instruction is a low-severity functional fix,
not cosmetic.

Everything else non-functional is comfortable riding the next real bump: a wild
app pulling for a genuine change also receives every non-functional change then
sitting on main, and none of those needed to arrive sooner.

## Levels (semantic-version style)

- patch (0.0.X): a fix that does not change how adopters use the kit, plus any
  misleading-content correction.
- minor (0.X.0): a new capability or an added rule, backward compatible.
- major (X.0.0): a breaking change (a ledger format, a script interface, an
  install step) an adopter must act on.

## How to bump

Edit the first line of `VERSION`, commit, push to main. main is the release line.
Only the first non-comment line of `VERSION` is read; the `#` lines are ignored.
