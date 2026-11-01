#!/bin/sh
# Tests dejavu for real: it installs and removes packages.
# Run it as root in a throwaway Linux container or server, or on a throwaway Mac (like GitHub's),
# never on your own computer:
#   docker run --rm -v "$PWD:/src:ro" debian:13-slim sh /src/tests/test.sh
#
# It tests as root, and as a user without sudo (when this system has `su`).

set -u

SRC="$(cd "$(dirname "$0")/.." && pwd)"
# `upgrade` downloads dejavu. Download it from this folder instead of GitHub (curl reads file://).
export DEJAVU_RAW_URL="file://$SRC"
PATH="$HOME/.local/bin:$PATH"

passed=0
failed=0

# Usage: expect EXIT_CODE COMMAND... (the output is kept in $out)
expect() {
  want=$1
  shift
  out="$("$@" 2>&1)"
  got=$?
  if [ "$got" = "$want" ]; then
    passed=$((passed + 1))
    echo "PASS (exit $got) $*"
  else
    failed=$((failed + 1))
    echo "FAIL (exit $got, want $want) $*"
    echo "$out" | sed 's/^/    /'
  fi
}

# Usage: has TEXT (in the output of the last expect)
has() {
  if printf '%s\n' "$out" | grep -qF -- "$1"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    echo "FAIL output has no '$1':"
    echo "$out" | sed 's/^/    /'
  fi
}

if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091 # a file of this machine
  . /etc/os-release
else
  ID=macos PRETTY_NAME="macOS $(sw_vers -productVersion)"
fi
echo "=== $PRETTY_NAME ($(uname -m))"

# --- Wrong usage ---
expect 2 sh "$SRC/dejavu" install 'rg;ls'
expect 2 sh "$SRC/dejavu" install -y
expect 2 sh "$SRC/dejavu" install system:-oAPT::Get::Assume-Yes=true # an option after the source
expect 2 sh "$SRC/dejavu" install npm:--registry=http://example.com
expect 2 sh "$SRC/dejavu" frobnicate
expect 0 sh "$SRC/dejavu" help

# --- Setup: on a slim image this also installs curl and tar, then mise ---
expect 0 sh "$SRC/dejavu" setup
expect 0 sh "$SRC/dejavu" setup # again: changes nothing
[ "$(grep -c 'added by dejavu' "$HOME/.profile")" = 1 ] || { failed=$((failed + 1)) && echo "FAIL: the PATH line is in ~/.profile more than once"; }

# --- Install ---
expect 0 dejavu install ripgrep jq
expect 0 dejavu install ripgrep # again
# A new login shell finds the commands by name.
expect 0 sh -lc 'rg --version && jq --version'
expect 1 dejavu install no-such-tool-zz9
has "failed:"
expect 1 dejavu install ripgrep@99.99.99
expect 0 dejavu install system:tree
expect 0 sh -lc 'tree --version'
# A plain name that comes from npm gets node first (before anything else installs node).
expect 0 dejavu install prettier
expect 0 sh -lc 'prettier --version'
expect 0 dejavu install npm:cowsay
expect 0 sh -lc 'cowsay hi'
expect 0 dejavu install pypi:httpie # installs uv first
expect 0 sh -lc 'http --version'

# Two at once: the second waits for the first.
dejavu install fd >/tmp/a.out 2>&1 &
dejavu install bat >/tmp/b.out 2>&1 &
wait
expect 0 sh -lc 'fd --version && bat --version'
# A lock left by a stopped dejavu whose number is now ours (like in a new container): no waiting.
# shellcheck disable=SC2016 # expands in the new shell
expect 0 sh -c 'mkdir -p "$HOME/.local/state/dejavu/lock" && echo $$ >"$HOME/.local/state/dejavu/lock/pid" && exec dejavu install jq'

# A server comes from the system package manager, as a service.
case "$ID" in
  debian | ubuntu | alpine)
    expect 0 dejavu install redis
    if [ "$ID" = alpine ]; then has "redis (with apk)"; else has "redis (with apt-get)"; fi
    expect 0 dejavu remove redis
    ;;
esac

# --- Other commands ---
expect 0 dejavu list
has npm:cowsay
expect 0 dejavu search grep
expect 0 dejavu doctor
has "admin rights: yes"
# Busybox wget cannot read file:// (the test's download address): use curl.
command -v curl >/dev/null 2>&1 || expect 0 dejavu install system:curl
expect 0 dejavu upgrade

# --- Your list, and moving to another computer ---
LIST="$HOME/.config/dejavu/packages.txt"
expect 0 dejavu list
has "jq  # "
has "system:tree  # "
expect 0 dejavu install JQ # again, in capitals: still one line
[ "$(grep -c '^jq ' "$LIST")" = 1 ] || { failed=$((failed + 1)) && echo "FAIL: jq is in the list more than once"; }
# A scoped npm name has an @ that is not a version.
expect 0 dejavu install npm:@biomejs/biome
has "Commands: biome"
expect 0 dejavu remove npm:@biomejs/biome
! grep -q biome "$LIST" || { failed=$((failed + 1)) && echo "FAIL: biome is still in the list"; }
# Move: keep a copy of the list, lose a tool, then restore from the copy (a relative path, Windows line ends).
cr="$(printf '\r')"
sed "s/\$/$cr/" "$LIST" >/tmp/old-list.txt
expect 0 dejavu remove jq
expect 0 sh -c 'cd /tmp && dejavu restore old-list.txt'
expect 0 sh -lc 'jq --version'
printf 'jq\nnot;a;name\n' >/tmp/bad-list.txt
expect 2 dejavu restore /tmp/bad-list.txt
has "line 2"
# A line for a package that is not installed here goes away with remove.
echo "no-such-tool-zz9" >>"$LIST"
expect 1 dejavu remove no-such-tool-zz9
! grep -q no-such-tool-zz9 "$LIST" || { failed=$((failed + 1)) && echo "FAIL: no-such-tool-zz9 is still in the list"; }

# --- Remove ---
expect 0 dejavu remove jq
expect 0 dejavu remove system:tree
case "$ID" in
  macos) ;; # brew refuses itself: nothing to test
  alpine)
    # apk del says ok but keeps a package that apk itself needs: dejavu must say it failed.
    expect 1 dejavu remove system:libcrypto3
    has "kept it"
    expect 0 apk info -e libcrypto3
    ;;
  *)
    # Other packages need coreutils: dejavu must refuse, and coreutils must stay.
    expect 1 dejavu remove system:coreutils
    expect 0 ls /
    ;;
esac

# --- A user without sudo ---
if [ "$ID" != macos ] && command -v su >/dev/null 2>&1; then
  useradd -m bob 2>/dev/null || adduser -D bob 2>/dev/null
  as_bob() { su bob -s /bin/sh -c "PATH=\$HOME/.local/bin:\$PATH DEJAVU_RAW_URL=$DEJAVU_RAW_URL $*"; }
  expect 0 as_bob "sh $SRC/dejavu setup"
  expect 0 as_bob "dejavu install jq"
  expect 3 as_bob "dejavu install system:htop"
  has "needs the user:"
  # Several: one command at the end, so the user types the password once.
  expect 3 as_bob "dejavu install system:htop system:tree"
  has "all at once"

  # sudo with a password: dejavu cannot type it, so the user must run the command.
  # sudo without a password: dejavu installs system packages itself.
  if [ "$ID" != alpine ] && dejavu install system:sudo >/dev/null 2>&1; then
    useradd -m carol && useradd -m dave
    echo 'carol ALL=(ALL) ALL' >/etc/sudoers.d/carol
    echo 'dave ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/dave
    expect 3 su carol -s /bin/sh -c "sh $SRC/dejavu install system:htop"
    has "sudo "
    expect 0 su dave -s /bin/sh -c "sh $SRC/dejavu install system:file" # in every base repo (htop is not, on Rocky)
    expect 0 su dave -s /bin/sh -c "sh $SRC/dejavu doctor"
    has "admin rights: yes (sudo without a password)"
  fi
fi

# `sudo dejavu` would put root's files in the user's home folder: dejavu refuses.
[ "$(id -u)" != 0 ] || expect 2 env SUDO_USER=carol dejavu install jq

echo "=== $PRETTY_NAME: $passed passed, $failed failed"
[ "$failed" = 0 ]
