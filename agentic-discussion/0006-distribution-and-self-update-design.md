# 0006 : distribution and self-update design

- From: manager session (current)
- To: record / next session
- Date: 2026-09-11
- Kind: decision-capture
- Status: OPEN -> closed by 0007, recorded as D6

## Why this thread exists

The single most important thing the owner (Emu) asked for, a public kit that
projects can pull and that tells them when they are behind, was never written
down as a decision in THIS repo. It lived only in the origin project's repo
history (SPLIT-SPEC.md, security handoff 0170) and in the outgoing session's prose
handover. The prior manager ("Karen") left it as a vague "not done" note and
punted the product shape to the owner. Leaving intent as folklore is the exact
failure this kit exists to stop. This thread pins it down where the work lives.

## The intent, in the owner's words (plain)

- The GitHub repo is PUBLIC so anyone with it can pull.
- NOBODY but the owner can edit it.
- When the kit is in use, it checks that repo for the version it is built on and
  updates where necessary.

## The hard reality that shapes the whole design

Claude Code has NO per-run or per-turn version check. The finest granularity is
ONCE PER SESSION, via a SessionStart hook. A skill cannot fire a per-turn network
call; it is a static folder scanned at startup. So "check the repo when the skill
is used" resolves to "check at session start". This is a constraint, not a
choice, and it must be stated to the owner plainly so expectation matches
reality. Do not promise per-run.

## The decided shape (settled, not re-litigated)

Delivery = a PLUGIN that carries the payload, plus a SessionStart hook that does
the per-session version check. This was already decided in security handoff 0170
(line 13: "Delivery mechanism (plugin payload plus SessionStart per-session
human-approved apply) is already decided"). The open skill-vs-plugin-vs-hook
question in SPLIT-SPEC section 4 is therefore closed: it is plugin + hook.

## The version-check mechanism

1. Ship a VERSION file (simple ordered token, e.g. 0.1.0, hand-bumped on core
   changes). It gates CORE only.
2. SessionStart hook fetches the remote VERSION from a PINNED HTTPS raw URL:
   https://raw.githubusercontent.com/TheDigitalEmu/reliable-agent-team/main/VERSION
3. Compare to the local adopted VERSION. If local is behind, print a warning to
   stderr telling the user to run git pull. It does NOT pull and executes nothing
   fetched.
4. Hard timeout (about 2s) and FAIL OPEN: slow, offline, error, junk body, or no
   fetch tool -> fall back to local and let the session proceed. A version check
   must never block a session.
5. A remote version LOWER than local is treated as SUSPICIOUS (stale mirror or
   tampering), reported as such, never as an update.
6. Profiles are the adopting project's data. An update refreshes core only and
   never overwrites a filled profile.

## Security conditions (from handoff 0170, these are BUILD REQUIREMENTS)

- C1: shipped profiles' gate commands must be inspection-only, local, read-only.
  No network egress, no writes outside the repo, no fetch-piped-to-shell.
- C2: INSTALL must carry an explicit "review before you paste" warning (done-extra
  lines run with the user's full shell privileges).
- C3: version check is read-and-warn ONLY. Never auto-pull, never fetch-then-exec.
- C4: pinned exact HTTPS raw URL, TLS only, no cross-host redirect, small max-time,
  non-200/timeout -> proceed on local.
- C5 (owner governance, still OPEN): branch protection + required review + signed
  release tags on the public repo BEFORE advertising git-pull-to-update. Without
  it, a bad push to public main propagates to every puller. This is the whole
  trust boundary of a public self-updating kit.
- C6: header note on moved guard scripts (adding fetch/write makes them a
  code-execution surface).

## Source of record (do not re-derive from memory)

- Origin project repo: reliable-agent-team/SPLIT-SPEC.md (core/profile boundary).
- Origin project repo: the security handoff 0170 (the trust model and C1 to C6).
- Origin project repo: reliable-agent-team/WHAT-IS-NOT-DONE.md (the outgoing
  confession and build brief).
