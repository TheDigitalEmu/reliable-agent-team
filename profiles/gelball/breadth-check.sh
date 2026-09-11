#!/bin/sh
# breadth-check.sh : count distinct sources across a content set, warn below a
#                    threshold, so single-source over-reliance is caught.
#
# READ-ONLY BY DESIGN: this script reads files and counts distinct URL hosts. It
# does NOT fetch any of the URLs it discovers, and it must not: fetching content
# hosts found in the scanned files would be an SSRF surface over data you do not
# control. Keep it a pure counter. If you add fetching, validate every host first
# and treat this as a code-execution / SSRF surface under review.
#
# ============================ PROFILE script (Gelball) ============================
# This file is a Gelball PROFILE script. The UNIVERSAL logic is:
#   "count distinct source hosts across a content set; fail below a minimum breadth."
# The EXAMPLE (Gelball-specific) bits are: the default content directory (content/),
# the default file globs (*.md, *.mdx, *.json), and the default threshold (3). A real
# project sets these to its own content layout. Nothing about the counting is Gelball
# specific; only the defaults are.
# =================================================================================
#
# ROADBLOCK REMOVED (see ../ROADBLOCK-REGISTER.md, "Content and sourcing roadblocks"):
#   - "Sourcing nothing, then over-relying on one or two sources" (F3): this greps source
#     URLs out of the content, reduces them to distinct HOSTS, and warns when the distinct
#     count is below the threshold. Single-source dominance becomes a visible number.
#
# This is a CHECK. It does not judge source QUALITY, only breadth (distinct hosts). It is
# a floor, not a ceiling: passing it means "not obviously single-sourced," not "well
# sourced." Pair it with a reviewer prompt that inspects the actual sources.
#
# ---------------------------------------------------------------------------
# WHAT COUNTS AS A SOURCE
#   Any http(s) URL found in the content set. The host (registrable-ish domain) is
#   extracted and lower-cased; www. is stripped. Distinct hosts are counted. So ten links
#   to one site count as ONE source; that is the whole point.
# ---------------------------------------------------------------------------
#
# USAGE
#   breadth-check.sh [--path <file-or-dir>] [--min <n>] [--list]
#   breadth-check.sh -h | --help
#
#   --path   file or directory to scan (default: content/). Directories scan recursively.
#   --min    minimum distinct hosts required (default: 3).
#   --list   also print the distinct hosts and how many links each has.
#
# EXIT CODES
#   0  distinct source count >= min.
#   1  below min (single-source / thin-breadth risk). Prints the count and the shortfall.
#   2  usage / environment error (path missing, no URLs found at all).
#
# HOW TO TEST
#   FAIL: printf 'see https://a.com/x and https://www.a.com/y\n' > /tmp/c.md
#         ./breadth-check.sh --path /tmp/c.md --min 3   # 1 distinct host -> exit 1
#   PASS: printf 'https://a.com https://b.org https://c.net\n' > /tmp/c.md
#         ./breadth-check.sh --path /tmp/c.md --min 3   # 3 distinct -> exit 0

set -eu

PROG="$(basename "$0")"
usage() { sed -n '2,53p' "$0" | sed 's/^# \{0,1\}//'; }
die()  { code="$1"; shift; printf '%s: %s\n' "$PROG" "$*" >&2; exit "$code"; }

# EXAMPLE INSTANCE defaults (a real project overrides these).
CONTENT_PATH="content"
MIN=3
LIST=0

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --path)    CONTENT_PATH="${2:-}"; shift 2 ;;
    --min)     MIN="${2:-}"; shift 2 ;;
    --list)    LIST=1; shift ;;
    *) die 2 "unknown argument: $1 (try --help)" ;;
  esac
done

[ -e "$CONTENT_PATH" ] || die 2 "content path does not exist: $CONTENT_PATH"

# Gather candidate files. EXAMPLE INSTANCE globs; universal logic is the extraction below.
gather() {
  if [ -d "$CONTENT_PATH" ]; then
    find "$CONTENT_PATH" -type f \
      \( -name '*.md' -o -name '*.mdx' -o -name '*.json' -o -name '*.txt' -o -name '*.html' \) 2>/dev/null
  else
    printf '%s\n' "$CONTENT_PATH"
  fi
}

FILES="$(gather)"
[ -n "$FILES" ] || die 2 "no scannable content files under: $CONTENT_PATH"

# Universal extraction: pull http(s) URLs, reduce to host, strip www., lower-case, sort.
# grep -oE finds each URL occurrence; sed peels the host out of the URL.
HOSTS="$(
  printf '%s\n' "$FILES" | while IFS= read -r f; do
    [ -f "$f" ] || continue
    grep -oE 'https?://[^][:space:]"<>)(]+' "$f" 2>/dev/null || true
  done \
  | sed -E 's#^https?://##; s#/.*$##; s#:.*$##; s#^www\.##' \
  | tr '[:upper:]' '[:lower:]' \
  | grep -v '^$' \
  | sort
)"

if [ -z "$HOSTS" ]; then
  die 2 "no http(s) source URLs found in the content set (breadth is zero; add sourced links)"
fi

DISTINCT="$(printf '%s\n' "$HOSTS" | sort -u | grep -c .)"
TOTAL="$(printf '%s\n' "$HOSTS" | grep -c .)"

printf 'breadth-check (EXAMPLE INSTANCE): %s link(s) across %s distinct source host(s); min=%s\n' \
  "$TOTAL" "$DISTINCT" "$MIN"

if [ "$LIST" -eq 1 ]; then
  printf '  distinct sources (host : link-count):\n'
  printf '%s\n' "$HOSTS" | sort | uniq -c | sort -rn | while read -r n host; do
    printf '    %-40s %s\n' "$host" "$n"
  done
fi

if [ "$DISTINCT" -lt "$MIN" ]; then
  printf 'breadth-check: WARN/FAIL: only %s distinct source(s), below the floor of %s.\n' "$DISTINCT" "$MIN" >&2
  printf 'breadth-check: roadblock: single-source over-reliance (F3). Add independent sources.\n' >&2
  exit 1
fi

printf 'breadth-check: OK: %s distinct sources meets the floor of %s.\n' "$DISTINCT" "$MIN"
exit 0
