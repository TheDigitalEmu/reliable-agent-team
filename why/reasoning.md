# Why the mechanisms are shaped this way

This kit is the ENFORCEMENT layer: a longer-form argument sits behind each of these rules, but the
machinery is what makes the argument unforgettable. This file carries the one-paragraph WHY per theme so the
reasoning travels with the kit. Humans read this file; the hooks and scripts do not need it.

Every roadblock and its mechanism is in `../ROADBLOCK-REGISTER.md`. Below is the one-paragraph WHY per
theme. Each is self-contained; read the register for the mechanism, this for the shape.

## Verification (the dominant theme)
Why "done" is a script's exit code and not an agent's judgment: an agent reports with a confidence
uncorrelated to correctness. It says "the page is done" in the same even tone whether it loaded the
page or remembered building it. You cannot read truth off the delivery, so the only reliable signal is
the artifact the claim can or cannot produce (a 200, a merged commit, a query result, a rendered
page). That is why the done-check greps git, the gate ledger, and the live URL rather than asking, and
why a UI task with no captured artifact cannot pass. "Built" is not "done", "pushed" is not "merged",
"passed once" is not "still passing", because each is a place the project rounded up and shipped
something broken.

## The gate model (independent lenses, producer never signs off)
Why three separate agents and not one careful reviewer: the defect lives in what the author's vantage
point cannot see, and one agent wearing all three hats does the one it finds easiest and waves the
other two through. The mega-menu round is the proof: reviewer PASSED reading the code, security PASSED
attacking the surface, both correct within their lens, and qa (running the actual menu) still found two
keyboard bugs invisible to reading and visible only to running. Independence is not a nicety on top of
the check; for an agent team it IS the check, because there is no reputation to lose that would enforce
a self-check softly. Hence producer-never-signs-off as an absolute rule the gate-check enforces
mechanically, and hence a PASS bound to a commit so adding to a gated tip re-requires the gate.

## Change-class
Why gate cost matches blast radius: not everything needs all three lenses, and forcing them wastes
cycles that then get skipped. Auth/data/input can leak or be abused, so it needs all three. Inert
content has no attack surface and no runtime behaviour, so reviewer alone suffices. Presentational UI
has runtime behaviour but no data path, so reviewer plus qa. Encoding this as a field the hand-off
carries and the gate-check reads means the RIGHT gates run, mechanically, rather than on the manager
remembering the rule.

## Coordination (worktrees + claim ledger)
Why physical isolation and not a "please coordinate" instruction: two sessions shared one checkout,
one branch-switched it mid-run, and another session's untracked work was wiped with NO git record and
no error. The damage was silent, so attention cannot catch it: a careful session can destroy another's
work without any signal it did so. One worktree per session makes the wipe physically impossible; the
claim ledger, read on wake and written before any touch, stops two sessions doing conflicting logical
work on the same files. Commit-and-push is the merge discipline because committed work is on the
remote, recoverable, and visible, and the wiped files were untracked. This is the headline scar of the
whole experience, learned by destroying the team's own work first.

## Content and sourcing
Why no-fabrication, cleared-asset-use, breadth, and inspect-and-reject are executable defaults: a
developer inventing facts is how wrong data reaches production, so facts are sourced by a separate role
with a URL and a checked-date each. Withholding assets the owner already cleared wastes cleared work,
so "use and list" is the default, not "ask again". Over-relying on one or two convenient sources
"reads as favouritism to anyone who knows the scene", so breadth is required and single-source
dominance is a red flag. The instinct to bank is the agent that inspected image candidates and
rejected four as AI-generated, documenting why: more work to ship less, which is exactly the standard.

## Communication and memory
Why the standing-authorization record and the required failure ledger: re-asking permission for an
action the owner already ordered ("build it and email me when ready", then stopping to ask "should I
deploy?") wastes the owner's attention and trains them that they cannot walk away, defeating the
department. Recording what a standing order covers lets the manager check the record instead of
re-asking. And the retrospective is required from day one because most rules exist only because
something broke; a team with no failure ledger re-earns every scar. The self-test fails without the
ledger so the enforcement, not memory, keeps it present.

## Unsupervised Mode (uMode)
Why a named mode and not just "trust the manager more": the failure the owner-contract already names,
that stopping to re-ask trains the owner they cannot walk away, has a sharper form. An autonomous
manager that surfaces a judgment call the owner could not answer better than best practice defeats the
entire premise of walking away, even while feeling diligent. uMode makes the manager a problem solver
under an explicit grant: intercept every question, answer it by best practice, solve every problem,
and park only the genuine irreversible stops into one end-of-stretch report rather than pinging live.
It is gated behind an explicit per-stretch grant, and auto-disables at exhaustion, because handing over
the right to make every call without you is exactly the kind of authorization that must be deliberate
and bounded, not standing. The grant ask forbids babble because an owner deciding whether to walk away
needs the plain shape of what they are authorizing, not a wall of mechanics.

## The honest limit (see the register's Limits section)
This kit hardens against the failures THIS project hit (n equals 1). It is blind to modes the project
never encountered. Known gaps not yet removed: cost/token blowout, correlated error (two gates sharing
a blind spot), a gate passing a genuine defect, and prompt-injection. Reliability is a rate driven down
by enforcement plus honest measurement across many projects, not a state any document confers. Every
PROCEDURE row in the register is a debt to convert into a CHECK or a BLOCK.
