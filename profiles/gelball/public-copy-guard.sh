#!/bin/sh
# ============================================================================
# public-copy-guard.sh  --  PROFILE script (Gelball profile)
# ----------------------------------------------------------------------------
# READ-ONLY BY DESIGN: this script only matches strings in memory. It does no
# network I/O and writes nothing but a mktemp it removes. If you extend it to
# fetch or write, treat it as a code-execution surface and review accordingly.
# ----------------------------------------------------------------------------
# ROADBLOCK REMOVED
#   F7 (content and sourcing): "Internal notes / wrong data leak to public."
#   See ROADBLOCK-REGISTER.md, Content and sourcing roadblocks, class
#   BLOCK + CHECK, artifact enforcement/public-copy-guard (example-instance).
#   This is the BLOCK half: a guard that THROWS (non-zero) if an internal-note
#   token appears in a value about to be written to a public column.
#
# WHY THIS FILE IS AN EXAMPLE INSTANCE, NOT UNIVERSAL MACHINERY
#   The UNIVERSAL mechanism is: "reject a public write whose value contains any
#   internal-note token." The token LIST and the notion of a "public column"
#   are project-specific (Gelball: Supabase public tables, editor draft notes
#   like 'confirm', 'verify before publishing', 'reviewer note',
#   'resolves Jamie seed'). So this ships as a COPYABLE PATTERN, not wired to
#   any live database. Copy it into your seed/publish pipeline and set your own
#   token list. Keep the mechanism; swap the list.
#
# HOW TO USE (copyable pattern)
#   Source it, then call assert_public_copy_clean before each public write:
#       . ./public-copy-guard.sh
#       assert_public_copy_clean "fields.description" "$value" || exit 1
#   Or pipe values in as "column<TAB>value" lines:
#       printf 'fields.name\tGel City (confirm)\n' | scan_public_copy_stream
#
# CONFIGURE
#   TEAM_INTERNAL_TOKENS  newline- or comma-separated token list (case-
#                         insensitive substring match). Defaults to the Gelball
#                         example list below.
#
# SELF-TEST
#   . ./public-copy-guard.sh
#   # PASSING CASE: clean public copy -> exit 0
#   assert_public_copy_clean fields.name "Donnybrook Gelball Field" && echo OK
#   # FAILING CASE: an internal note leaked into a public value -> exit 1, names token
#   assert_public_copy_clean fields.name "Donnybrook (verify before publishing)" \
#     || echo "blocked as expected"
# ============================================================================

set -eu

# --- EXAMPLE INSTANCE: Gelball internal-note token list ---------------------
# These are drafting/annotation markers that must never reach a public column.
# Universal mechanism, example list. Override with TEAM_INTERNAL_TOKENS.
DEFAULT_INTERNAL_TOKENS='confirm
verify before publishing
reviewer note
resolves Jamie seed
TODO
FIXME
DRAFT
do not publish
internal only
placeholder'

_load_tokens() {
	# echoes one token per line, normalised, from env override or the default
	raw="${TEAM_INTERNAL_TOKENS:-$DEFAULT_INTERNAL_TOKENS}"
	# allow comma-separated overrides too. Trailing '\n' guarantees the final
	# token is newline-terminated so `read` does not drop it.
	printf '%s\n' "$raw" | tr ',' '\n' | while IFS= read -r t; do
		t=$(printf '%s' "$t" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
		[ -n "$t" ] && printf '%s\n' "$t"
	done
}

# assert_public_copy_clean <column> <value>
#   exit 0 if the value is clean; exit 1 (and print) if a token is present.
assert_public_copy_clean() {
	_col="${1:-<unknown-column>}"
	_val="${2:-}"
	_lc=$(printf '%s' "$_val" | tr '[:upper:]' '[:lower:]')
	# Load tokens into a temp file so the match loop runs in THIS shell (no
	# pipe subshell), which keeps the return code reliable under set -e.
	_tf=$(mktemp 2>/dev/null || echo "${TMPDIR:-/tmp}/pcg.$$")
	_load_tokens > "$_tf"
	_found=""
	while IFS= read -r tok; do
		[ -n "$tok" ] || continue
		_ltok=$(printf '%s' "$tok" | tr '[:upper:]' '[:lower:]')
		[ -n "$_ltok" ] || continue
		case "$_lc" in
			*"$_ltok"*) _found="$tok"; break ;;
		esac
	done < "$_tf"
	rm -f "$_tf"
	if [ -n "$_found" ]; then
		printf '%s\n' \
			"BLOCKED by public-copy-guard (roadblock F7: internal note leak)." \
			"Internal-note token '$_found' found in a PUBLIC value." \
			"  column: $_col" \
			"  value : $_val" \
			"Fix: remove the internal note before writing to a public column," \
			"or move it to an editor-only/internal field. Public copy must be" \
			"reader-ready, not a draft annotation." >&2
		return 1
	fi
	return 0
}

# scan_public_copy_stream : read "column<TAB>value" lines from stdin, block on
# the first offending line. Handy as a pre-ship audit over a dumped rowset.
scan_public_copy_stream() {
	_rc=0
	while IFS="$(printf '\t')" read -r _c _v; do
		[ -z "${_c:-}" ] && continue
		if ! assert_public_copy_clean "$_c" "$_v"; then
			_rc=1
		fi
	done
	return $_rc
}

# If executed directly (not sourced), run the self-test demonstration so the
# file is runnable on its own: `sh public-copy-guard.sh`.
# Detect direct execution portably: $0 ends in this filename.
case "$0" in
	*public-copy-guard.sh)
		echo "[demo] PASSING case (clean copy):"
		if assert_public_copy_clean "fields.name" "Donnybrook Gelball Field"; then
			echo "  -> allowed (exit 0), as expected."
		fi
		echo "[demo] FAILING case (internal note leaked):"
		if assert_public_copy_clean "fields.name" "Donnybrook (verify before publishing)"; then
			echo "  -> ERROR: should have blocked." >&2
			exit 1
		else
			echo "  -> blocked (exit 1), as expected."
		fi
		;;
esac
