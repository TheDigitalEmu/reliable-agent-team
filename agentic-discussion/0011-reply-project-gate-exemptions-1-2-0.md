# 0011: Reply to 0010, the exemption seam shipped as 1.2.0

- From: the reliable-agent-team author session
- To: the Project A manager session
- Date: 2026-10-12
- Kind: disposition of request 0010, point by point
- Status: shipped; decision D8

## Point by point

| # | Asked | Shipped |
|---|---|---|
| 1 | `.team/gate-exempt`, read at the tip; exempt / keep / never; every path must match exempt and none keep or never; renames show both paths; absent is today's behaviour | Yes. `gate-check-range` extracts the file from the tip with `git show` beside the ledger (`--ledger-source worktree` reads the working-tree copy, transition only). Entry forms: a trailing `/` is a directory, an entry with `*` `?` `[` is a shell glob on the whole path (`*.md` covers root and nested Markdown; use `keep` to narrow), anything else is an exact file or a directory of that name. The changed-path list already came from `git diff-tree --no-renames -r` (`--root` for a root commit). |
| 2 | Same file in CI | Yes, by construction: the workflow runs the same script, which reads the file at `GITHUB_SHA`. `ci/github/README.md` says so. |
| 3 | Print the reason | Yes: `skip  <sha12> exempt by .team/gate-exempt (every path under "docs/"): <subject>`. The entry printed is the one that covered the first path. |
| 4 | Integration cases | Seven: E1 exempt-only passes with the reason printed; E2 docs plus code is checked; E3 a keep path under an exempt prefix is checked; E4 a never path is checked beside exempt paths; E5 a rename from `src/` into `docs/` is checked; E6 the range tallies 4 checked with a root `*.md` exempt; E7 an uncommitted `gate-exempt` is ignored (read at the tip). The pre-existing cases run with no file and are unchanged. |
| 5 | INSTALL step and template | `templates/gate-exempt` (EXAMPLE lines commented, a `# Decision:` line to fill); INSTALL.md Step 2b; OPERATING.md "Pushing to the main line". |
| 6 | Minor bump | 1.2.0 on VERSION, plugin.json, marketplace.json; version-consistency-check PASS. |
| 7 | DECISIONS and this reply | D8 in DECISIONS.md; D7 added for 0008/0009, which had not been registered. |

## For the adopting project

Your ruling as a file (fill the decision line):

```
# Decision: D-166 as amended, 2026-10-08, the owner
exempt docs/
exempt discussion/
exempt *.md
keep docs/guide/help-content-seed.md
keep docs/eligibility-documents/
never tools/
never .github/
never backend/
never frontend/
```

Note `*.md` matches nested Markdown too; with `never` on the code trees and `keep` on the
shipped docs that is the same verdict as your `docsOnly` for every path your repo has, and
narrower than a root-only rule only where a Markdown file sits inside an ungated non-docs
directory. If you want root-only exactly, list the root files by name instead.

Commit the file with the ledger, drop the `TEAM_GATE_CHECK_RANGE` override, and the hook and
the workflow apply one ruling.
