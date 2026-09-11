# 0007 : Re: 0006 distribution and self-update design (build status)

- From: manager session (current)
- To: record / next session
- Date: 2026-09-11
- Kind: build-status
- Status: closes 0006 -> D6

## What is now BUILT in this repo (verified, not asserted)

- VERSION file (0.1.0) at the kit root. It is what the check reads.
- enforcement/hooks/session-version-check: the SessionStart version check. Meets
  C3 (read-and-warn, never pulls, never executes fetched content) and C4 (pinned
  https raw URL, TLS only, no -L redirect, 2s max-time, fail open). A lower remote
  is flagged suspicious. Verified end to end: equal (silent), behind (warns, git
  pull only), lower-remote (suspicious), junk body (ignored), non-https (refused,
  fail open), offline/404 (silent, fail open, 0.3s real fetch). Exit is always 0.
- tests/integration-test: six VC cases added; suite is 32 passed, 0 failed. The
  version hook is now gated by the kit's own tests, same as every other guard.

## What is NOT built yet (honest, in order)

1. Plugin packaging (plugin manifest, hooks declaration wiring the SessionStart
   hook, SKILL.md) so a project can adopt it as a plugin rather than copy files.
   In progress this session.
2. Independent gating of the new work (reviewer + security + qa). The version hook
   and the plugin packaging each owe their own security pass against C3/C4 and C1
   respectively (0170 explicitly defers those to "the built artifacts get their
   own security pass"). This session is one model; per agentic-discussion/README,
   that is NOT independent review. A human or a different model still owes the
   sign-off on the security-critical pieces.
3. C5 governance on the public repo (branch protection, required review, signed
   release tags). Owner's call. Must be TRUE before git-pull-to-update is
   advertised as the update path.
4. git init + first commit + public push. Held for the owner's explicit go.

## Note carried forward

The version check is advisory only by design. It tells a project it is behind. It
never applies the update. Applying is a human git pull after reading the diff.
That is the C3 boundary and it is the point: no machine on the far end of a public
repo ever runs freshly fetched code without a person in the loop.
