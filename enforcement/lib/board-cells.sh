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
# A cell made only of space-separated key=value tokens ("class=static status=done
# artifact=no") is split into one token per line too, so a board that keeps several
# pairs in one cell reads like one that gives each pair its own pipe (kit 1.3.1;
# before, "class" swallowed the rest of the cell). A cell with any bare word in it is
# prose and stays whole, so a sentence that mentions "sha=..." cannot set a field.
#
# POSIX sh + sed/tr/awk only; this runs inside a pre-push hook on Git Bash.

board_cells() {  # stdin: one row  ->  stdout: one trimmed cell per line
  # 1. the markdown escape "\|" becomes a plain separator;
  # 2. split on "|" (a leading table pipe yields an empty first cell, harmless for
  #    key lookups, and board_task_id skips it);
  # 3. trim whitespace, drop any stray trailing backslash, trim again;
  # 4. a cell of two or more key=value tokens and nothing else gives one token a line.
  sed 's/\\|/|/g' \
    | tr '|' '\n' \
    | sed 's/^[ \t]*//; s/[ \t]*$//; s/\\*$//; s/[ \t]*$//' \
    | awk '{
        n = split($0, t, /[ \t]+/); ok = (n >= 2)
        for (i = 1; i <= n && ok; i++) if (t[i] !~ /^[A-Za-z_][A-Za-z0-9_-]*=/) ok = 0
        if (ok) { for (i = 1; i <= n; i++) print t[i] } else print
      }'
}

# board_row <task-id> <board-file>: the first non-comment row whose FIRST cell is
# exactly the task id. A substring match took the wrong row when another row's prose
# named the id, or when one id is the start of another ("fast-track", "fast-track-screens").
board_row() {
  grep -v '^[[:space:]]*#' "$2" 2>/dev/null | grep -F -- "$1" 2>/dev/null \
    | while IFS= read -r _br_line || [ -n "$_br_line" ]; do
        if [ "$(printf '%s\n' "$_br_line" | board_task_id)" = "$1" ]; then
          printf '%s\n' "$_br_line"; break
        fi
      done
}

board_task_id() {  # stdin: one row  ->  stdout: the first non-empty cell (the task id)
  board_cells | sed '/^$/d' | head -n1
}
