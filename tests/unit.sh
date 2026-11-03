#!/bin/sh
# shellcheck disable=SC2218,SC2329 # dejavu's functions come from loading it, which shellcheck cannot see
# Quick tests: the parts of dejavu that only work with text, like names and your list.
# They install nothing, need no internet and take seconds. Safe on your own computer:
#   sh tests/unit.sh
# tests/test.sh is the full test: it installs real packages, in a container.

SRC="$(cd "$(dirname "$0")/.." && pwd)"
# Load dejavu's functions without running it.
# shellcheck source=/dev/null # dejavu, loaded as a library
DEJAVU_LIB=1 . "$SRC/dejavu"
set +e # a test that fails must not stop the others

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
LIST="$TMP/packages.txt"
passed=0
failed=0

# Usage: same WANT GOT WHAT
same() {
  if [ "$1" = "$2" ]; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    printf 'FAIL %s\n    want: %s\n    got:  %s\n' "$3" "$1" "$2"
  fi
}

# --- Names ---
for n in ripgrep node@lts python@3.13 npm:prettier npm:@biomejs/biome@1.9 github:BurntSushi/ripgrep \
  go:github.com/x/y system:build-essential skill:vercel-labs/skills/find-skills g++ libstdc++6 a~b; do
  (check_name "$n") >/dev/null 2>&1
  same 0 $? "check_name accepts $n"
done
# shellcheck disable=SC2016,SC2088 # these names must stay as written
for n in "" -y system:-oAPT::Get::Assume-Yes=true npm:--registry=x 'rg;ls' 'a b' '$(id)' \
  /tmp/x.deb ./x '~/x' system:/tmp/x.rpm system:https://example.com/x.rpm x.apk https://example.com; do
  (check_name "$n") >/dev/null 2>&1
  same 2 $? "check_name rejects '$n'"
done
out="$( (check_name 'a;b' 'line 7 of list.txt') 2>&1)"
case "$out" in *"line 7 of list.txt"*) same ok ok "check_name says where" ;; *) same "line 7" "$out" "check_name says where" ;; esac

same node "$(base node@lts)" "base node@lts"
same ripgrep "$(base ripgrep)" "base ripgrep"
same npm:@scope/pkg "$(base npm:@scope/pkg@1.2)" "base of a scoped npm name"
same npm:@scope/pkg "$(base npm:@scope/pkg)" "base of a scoped npm name without a version"

same ffmpeg "$(lower FFmpeg)" "lower FFmpeg"
same github:Owner/Repo "$(lower github:Owner/Repo)" "lower keeps the case of a source"
same skill:owner/repo/name "$(lower skill:owner/repo@name)" "lower reads skills.sh names"
same skill:owner/repo/name "$(lower skill:owner/repo/name@1)" "lower drops a skill version"

# --- Your list ---
printf '\357\273\277# a note\r\njq  # 1.8.1, mise\r\n\r\nripgrep fd # two on a line\r\nnpm:@biomejs/biome  # 2.0, mise' >"$TMP/in.txt"
same "jq ripgrep fd npm:@biomejs/biome" "$(list_names "$TMP/in.txt" in.txt | tr '\n' ' ' | sed 's/ $//')" \
  "list_names: Windows line ends, a BOM, notes, two names on a line, no last newline"
printf 'jq\nnot;a;name\n' >"$TMP/bad.txt"
out="$( (list_names "$TMP/bad.txt" bad.txt) 2>&1)"
same 2 "$( (list_names "$TMP/bad.txt" bad.txt) >/dev/null 2>&1; echo $?)" "list_names stops at a bad name"
case "$out" in *"line 2 of bad.txt"*) same ok ok "list_names says the line" ;; *) same "line 2" "$out" "list_names says the line" ;; esac

printf '# header\njq  # 1.8.1, mise\nnpm:@biomejs/biome@2.0  # 2.0, mise\n' >"$LIST"
same "# header
jq  # 1.8.1, mise" "$(list_without npm:@biomejs/biome)" "list_without removes a line"
list_without npm:@biomejs/biome >/dev/null
same npm:@biomejs/biome@2.0 "$FOUND" "list_without finds the name with its version"
list_without fd >/dev/null
same "" "$FOUND" "list_without finds nothing for a missing name"
forget jq
same "# header
npm:@biomejs/biome@2.0  # 2.0, mise" "$(cat "$LIST")" "forget removes it from the file"

# Versions, as each package manager prints them. Pretend jq is installed, and not with mise.
# These replace dejavu's own functions.
in_mise() { return 1; }
find_pm() { PM=fake && return 0; }
pm_cmd() { CMD=fake_version; }
fake_version() { printf '%s\n' "$printed"; }
for row in "jq 1.8.1|1.8.1" "jq-1.8.1-r0 aarch64 {jq} (MIT) [installed]|1.8.1-r0" "1.8.1-2|1.8.1-2"; do
  printed="${row%|*}"
  version_of system:jq
  same "${row#*|}" "$VER" "version_of reads '$printed'"
done

# --- Package managers: every one knows every action ---
# Load dejavu again: the version tests above replaced some of its functions.
DEJAVU_LIB=1 . "$SRC/dejavu"
set +e
LIST="$TMP/packages.txt"
for PM in apt-get dnf yum pacman zypper apk brew; do
  for a in install remove upgrade search version; do
    pm_cmd "$a"
    [ -n "$CMD" ] || same "a command" "" "pm_cmd $PM $a"
    passed=$((passed + 1))
  done
done

# --- Hints for errors ---
for row in "API rate limit exceeded|GitHub limits" "Could not resolve host: github.com|No internet" \
  "No space left on device|disk is full" "E: Unable to locate package nope|not found" \
  "error while loading shared libraries: libatomic.so.1: cannot open|libatomic.so.1"; do
  printf '%s\n' "${row%|*}" >"$TMP/fail"
  case "$(hint)" in *"${row#*|}"*) same ok ok "hint for '${row%|*}'" ;; *) same "${row#*|}" "$(hint)" "hint for '${row%|*}'" ;; esac
done

echo "=== quick tests: $passed passed, $failed failed"
[ "$failed" = 0 ]
