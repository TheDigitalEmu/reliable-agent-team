# owner-inbox-path.sh : where the owner's messages are kept. NEVER in the work tree.
#
# Sourced by enforcement/hooks/owner-inbox and scripts/commitments.
#
# OWNER RULING (2026-11-18): recording the owner's messages in a shared repository
# is never acceptable. 1.3.0 kept the log at .team/INBOX.md, inside the work tree,
# where a ledger commit could carry it to everyone who can read the repo. The log
# now lives in the repository's git directory (<git-common-dir>/rat/INBOX.md):
# git cannot add a path inside its own directory, so it can never be committed,
# pushed or shared, whatever the project's .gitignore says. All worktrees of the
# clone share it, and it stays on the machine where the manager runs.
#
# TEAM_INBOX overrides the path (tests only).

owner_inbox_path() {  # stdout: the absolute inbox path; exit 1 outside a git repo
  if [ -n "${TEAM_INBOX:-}" ]; then printf '%s\n' "$TEAM_INBOX"; return 0; fi
  _oi_d=$(git rev-parse --git-common-dir 2>/dev/null) || return 1
  _oi_d=$(CDPATH= cd -- "$_oi_d" 2>/dev/null && pwd) || return 1
  printf '%s/rat/INBOX.md\n' "$_oi_d"
}

# owner_inbox_tracked <team-dir>: exit 0 when a 1.3.0 inbox is in git's index.
owner_inbox_tracked() {
  git -C "$1" ls-files --error-unmatch INBOX.md >/dev/null 2>&1
}

# owner_inbox_migrate <team-dir> <inbox>: move a 1.3.0 .team/INBOX.md out of the work
# tree. 0 nothing to do or moved; 3 it is tracked by git (the caller must refuse);
# 4 both files exist (left alone, the caller warns).
owner_inbox_migrate() {
  owner_inbox_tracked "$1" && return 3
  [ -f "$1/INBOX.md" ] || return 0
  [ ! -f "$2" ] || return 4
  mkdir -p "$(dirname "$2")" && mv "$1/INBOX.md" "$2"
}

OWNER_INBOX_TRACKED_MSG='PRIVACY: .team/INBOX.md (owner messages) is tracked by git. Owner messages must never be in a shared repository. Run: git rm --cached .team/INBOX.md, commit, and if it was ever pushed, purge it from the remote history. The kit now keeps the inbox in the git directory, outside the work tree.'
