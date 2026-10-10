# board-cells.sh : the ONE place a TASKS.md board row is split into cells.
#
# Sourced (". path/board-cells.sh") by scripts/done-check, scripts/reconcile and
# scripts/gate-check. Reads a single board row on stdin, writes one cell per line,
# each cell trimmed of surrounding whitespace, so callers can `grep -E '^key='`.
#
# Rows come in two shapes and BOTH must yield the same cells:
#   plain pipe line (tests, early adopters):
#     T2-info-page | class=static | status=done | author=researcher | sha=9df74e2
#   markdown table row (templates/TASKS.md, every board that followed it):
#     | T2-info-page | class=static \| status=done \| author=researcher \| sha=9df74e2 | prose |
#
# Bug this closes (report 2026-10-11, kit 1.0.0): splitting on a raw "|" leaves the
# markdown escape behind, so "status=done \" never equals "done" (reconcile silently
# re-verifies nothing) and "author=developer \" never equals "developer" (the push-time
# self-sign-off compare in gate-check is defeated by the shipped template's own rows).
#
# POSIX sh + sed/tr only; this runs inside a pre-push hook on Git Bash.

board_cells() {  # stdin: one row  ->  stdout: one trimmed cell per line
  # 1. the markdown escape "\|" becomes a plain separator;
  # 2. split on "|" (a leading table pipe yields an empty first cell, harmless for
  #    key lookups, and board_task_id skips it);
  # 3. trim whitespace, drop any stray trailing backslash, trim again.
  sed 's/\\|/|/g' \
    | tr '|' '\n' \
    | sed 's/^[ \t]*//; s/[ \t]*$//; s/\\*$//; s/[ \t]*$//'
}

board_task_id() {  # stdin: one row  ->  stdout: the first non-empty cell (the task id)
  board_cells | sed '/^$/d' | head -n1
}
