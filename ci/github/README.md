# Server-side gating (GitHub Actions)

The local pre-push hook can only bite the clone it is installed in. A commit that reaches the
main line by any other path is never seen by it (field review 0008, 3A.1). These two files put
the same check on the server, so the rule is the same everywhere.

## Install (two steps)

1. Copy `gate-check.yml` to `.github/workflows/gate-check.yml` in your repository. Set
   `GATE_BASELINE` to the last commit before you enforce range gating (history before it is
   never checked) and `KIT_REF` to the kit tag you have adopted. Never point `KIT_REF` at a
   branch: the server must run a version you have read.
2. In your deploy workflow, add a job that runs before anything reaches a server:

   ```yaml
   gates:
     runs-on: ubuntu-latest
     permissions:
       actions: read
     steps:
       - uses: actions/checkout@v4
         with:
           repository: TheDigitalEmu/reliable-agent-team
           ref: v1.1.0
           path: kit
       - env:
           GH_TOKEN: ${{ github.token }}
         run: sh kit/scripts/require-gate-run "${{ github.sha }}"
   ```

   and make the deploy job `needs: [gates]`. `require-gate-run` waits for the Gate check run of
   that exact commit and fails closed on anything but success.

## What the server checks

Every commit in `base..tip` (first-parent), where base is the newest earlier green tip that is
an ancestor of this push, else `GATE_BASELINE`. Each code commit must have, in `.team/GATES.md`
as committed at the tip, the PASS rows its change class requires, bound to its full SHA, by an
author who is not the work author (from `.team/TASKS.md` at the tip), with no sticky non-PASS
row, and whose role resolves in `.team/roles` when that ledger exists. A `.team`-only commit is
exempt: it is the ledger commit. A red run lists the offending SHAs; the next push re-checks
them because the base is the last GREEN tip.

## The push convention this needs

Code commits, then one `.team`-only ledger commit on top, then push (`scripts/gated-push` does
the check and the push in one process). The ledger of record is the committed one; a ledger
held in the working tree is invisible to the server and now also to the local hook.
