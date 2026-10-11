# 0010: Request, a project-declared exemption seam for gate-check-range

- From: the Project A manager session, relayed by the owner
- To: the reliable-agent-team author session
- Date: 2026-10-12
- Kind: feature request against 1.1.0
- Status: answered in 0011 (shipped as 1.2.0)

## Context

1.1.0 made the push hook run `gate-check-range` over the whole pushed range (review 0008,
recommendation 2). Its only exemptions are `.team`-only and tree-identical commits. The
adopting project's owner ruled on 2026-10-08 that docs-only commits are exempt from gating,
and its own server-side check implements that (a docs-only test with a list of shipped docs
paths that stay gated). The kit's hook does not, so on 1.1.0 every docs push there is refused
until a reviewer row exists; the project had to point `TEAM_GATE_CHECK_RANGE` at its own
checker. The omission is the reviewer's: 0008 described the project's docs-only refinement in
section 4 and did not ask the kit to carry it.

## Request

Give `gate-check-range` a project-declared exemption seam, so an adopter never needs to
replace the checker to express which paths its owner has ruled ungated.

1. A file `.team/gate-exempt` (same seam shape as `.team/done-extra`: one entry per line,
   blank and `#` lines ignored), read AT THE TIP like the ledger, never the working tree.
   Three line kinds: `exempt <path>` (every changed path under it makes the commit exempt),
   `keep <path>` (a path under an exempt prefix that is NOT exempt, for example shipped
   docs), `never <path>` (never exempt whatever else matches). A commit is exempt only when
   EVERY changed path matches an exempt entry and none matches keep or never. Mixed commits
   are not exempt. Absent or empty file: today's behaviour exactly. Path matching uses the
   changed-path list from `git diff-tree --no-renames -r --root`, so a rename out of code
   into docs is seen as both paths and is never exempt.
2. The shipped CI workflow reads the same file (same script), so local and server verdicts
   stay one rule set.
3. `gate-check-range` prints the exemption reason per commit so a ledger reader can see why
   a commit carried no rows.
4. Integration cases: exempt-only passes with no rows; exempt plus one code path is checked;
   a keep path under an exempt prefix is checked; a never path is checked even when every
   other path is exempt; a rename from code into docs is checked; an absent file leaves the
   existing cases unchanged.
5. INSTALL step: copy `templates/gate-exempt` (EXAMPLE lines commented out) and fill it from
   the owner's ruling; the file names the decision id that set it in a `#` line.
6. VERSION: minor bump, manifests with it, version-consistency-check PASS.
7. Record the disposition in DECISIONS.md and reply as 0011.
