#!/bin/sh
# Tests dejavu: every test system in tests/fixtures is rendered, searched for leaks, and gets
# its credentials file and PDFs. No real secret is used: every value is a fake "CANARY-..." made here.
#
#   sh tests/test.sh            on a machine that has the tools (see CONTRIBUTING.md)
#   sh tests/test.sh --install  inside a throwaway container or CI only: installs the tools first
#
# Settings:
#   CASES="a b"   only these test systems (default: all)
#   ANSIBRO=DIR   an ansibro checkout (default: /ansibro, else ../ansibro next to this repo)
#   UPDATE=1      write the golden files again (then review the diff)
#   NO_PDF=1      skip the PDFs (faster)

set -eu
SRC="$(cd "$(dirname "$0")/.." && pwd)"
SKILL="$SRC/skills/dejavu"
H="$SKILL/scripts/handover.py"
ANSIBRO="${ANSIBRO:-}"
[ -n "$ANSIBRO" ] || { [ -d /ansibro ] && ANSIBRO=/ansibro; } || ANSIBRO="$SRC/../ansibro"
[ -f "$ANSIBRO/inventory.py" ] || { echo "error: no ansibro checkout at $ANSIBRO (set ANSIBRO=DIR)" >&2; exit 2; }
ANSIBRO="$(cd "$ANSIBRO" && pwd)"

if [ "${1:-}" = --install ]; then
  if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    kp=keepassxc-minimal
    apt-cache show keepassxc-minimal >/dev/null 2>&1 || kp=keepassxc
    apt-get install -y -qq --no-install-recommends python3 python3-yaml python3-jinja2 python3-cryptography \
      "$kp" age poppler-utils git curl ca-certificates openssh-client >/dev/null
  fi
  if [ -z "${NO_PDF:-}" ] && ! command -v mise >/dev/null 2>&1; then
    curl -fsSL https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh >/dev/null
  fi
fi

# A Python with PyYAML, Jinja2 and cryptography: ansibro's venv when it has one.
PY="${PY:-}"
[ -n "$PY" ] || { [ -x "$ANSIBRO/.venv/bin/python" ] && PY="$ANSIBRO/.venv/bin/python"; } || PY=python3
export DEJAVU_TEST=1 HANDOVER_TODAY=2026-11-04 SOURCE_DATE_EPOCH=1793750400

passed=0
failed=0
pass() { passed=$((passed + 1)); }
fail() { failed=$((failed + 1)); echo "FAIL $*"; }
# Usage: expect CODE COMMAND... (output in $out)
expect() {
  want=$1
  shift
  if out="$("$@" 2>&1)"; then got=0; else got=$?; fi
  if [ "$got" = "$want" ]; then pass; else fail "(exit $got, want $want) $*"; echo "$out" | tail -n 15 | sed 's/^/    /'; fi
}
has() { if printf '%s\n' "$out" | grep -qF -- "$1"; then pass; else fail "output has no '$1'"; fi; }

KP="$(command -v keepassxc-cli || true)"
[ -n "$KP" ] || [ ! -x /Applications/KeePassXC.app/Contents/MacOS/keepassxc-cli ] || KP=/Applications/KeePassXC.app/Contents/MacOS/keepassxc-cli
[ -n "$KP" ] || { echo "error: keepassxc-cli is missing (run the tests in a container: see CONTRIBUTING.md)" >&2; exit 2; }
PDF=1
[ -z "${NO_PDF:-}" ] || PDF=""
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home" # never the real home: no mise or KeePassXC settings change
mkdir -p "$HOME"
[ -z "${MISE_DATA_DIR:-}" ] || export MISE_DATA_DIR

# Make a test system: a copy of ansibro with the case's config and fake secrets.
# Usage: system CASE -> $sys (the ansibro folder) and $outdir (the output folder)
system() {
  case_dir="$SRC/tests/fixtures/$1"
  sys="$TMP/$1/ansibro"
  outdir="$TMP/$1/out"
  rm -rf "${TMP:?}/$1"
  mkdir -p "$sys" "$outdir"
  (cd "$ANSIBRO" && tar --exclude ./.git --exclude ./.venv --exclude ./state --exclude ./state.age \
    --exclude './config*.yml' -cf - .) | (cd "$sys" && tar -xf -)
  cp "$case_dir/config.yml" "$sys/"
  for crt in "$case_dir"/*.crt; do [ ! -f "$crt" ] || cp "$crt" "$sys/"; done
  mkdir -p "$sys/state/secrets"
  chmod 700 "$sys/state"
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    printf 'CANARY-%s-%s\n' "$name" "$(od -An -N9 -tx1 /dev/urandom | tr -d ' \n')" >"$sys/state/secrets/$name"
  done <"$case_dir/secrets.txt"
  # summary.md has every password: dejavu must never open it, only read its date.
  echo "CANARY-summary-never-opened" >"$sys/state/summary.md"
  touch -t 202611031200 "$sys/state/summary.md"
  chmod 000 "$sys/state/summary.md"
  cp "$case_dir/handover.yml" "$outdir/"
  # Results of ansibro's acceptance test, when the case has them (the servers cannot be reached here).
  [ ! -d "$case_dir/check" ] || cp -R "$case_dir/check" "$outdir/check"
}

# Usage: build CASE [ARGS] -> runs handover.py build for that case
build() {
  c=$1
  shift
  set -- "$H" build --ansibro "$TMP/$c/ansibro" --out "$TMP/$c/out" \
    --inventory-json "$SRC/tests/fixtures/$c/inventory.json" --groupvars-json "$SRC/tests/fixtures/$c/groupvars.json" "$@"
  [ -n "$PDF" ] || set -- "$@" --no-pdf
  "$PY" "$@"
}

# No secret value anywhere in the output: neither a canary, nor a config secret.
no_leak() {
  if grep -rl CANARY "$outdir" --exclude='*.kdbx' --exclude='*.pdf' --exclude=handover.yml >"$TMP/leaks" 2>/dev/null; then
    fail "$1: a secret value is in $(tr '\n' ' ' <"$TMP/leaks")"
  else
    pass
  fi
  if [ -n "$PDF" ] && command -v pdftotext >/dev/null 2>&1; then
    find "$outdir/dist" -name '*.pdf' >"$TMP/pdfs"
    while IFS= read -r p; do
      if pdftotext "$p" - 2>/dev/null | grep -q CANARY; then fail "$1: a secret value is in $p"; else pass; fi
    done <"$TMP/pdfs"
  fi
}

# Compare with tests/golden/<case>/ (UPDATE=1 writes them).
golden() {
  g="$SRC/tests/golden/$1"
  mkdir -p "$TMP/g"
  rm -rf "$TMP/g/$1"
  mkdir -p "$TMP/g/$1"
  cp "$outdir/facts.json" "$TMP/g/$1/"
  (cd "$outdir/dist" && find . -name '*.md' -o -name '*.txt' | while read -r f; do
    mkdir -p "$TMP/g/$1/$(dirname "$f")" && cp "$f" "$TMP/g/$1/$f"; done)
  (cd "$outdir/build" && find . -name '*.d2' | while read -r f; do
    mkdir -p "$TMP/g/$1/$(dirname "$f")" && cp "$f" "$TMP/g/$1/$f"; done)
  # File hashes in the BAST change with every PDF build: compare without them.
  # shellcheck disable=SC2016 # backticks are Markdown here
  # The credentials file is new with every build (KeePass uses a random salt), and PDF sizes
  # depend on the tool versions: their hashes and sizes are not compared.
  find "$TMP/g/$1" -name '*.md' -exec sed -i.bak -E 's/[0-9a-f]{16,}(…)?/<sha256>/g;
    /\.(kdbx|pdf)/ s/[0-9]{1,3}([.,][0-9]{3})+|[0-9]{3,}/<size>/g' {} \;
  find "$TMP/g/$1" \( -name '*.bak' -o -name SHA256SUMS \) -exec rm -f {} \;
  if [ -n "${UPDATE:-}" ]; then
    [ ! -f "$g/kdbx-entries.txt" ] || cp "$g/kdbx-entries.txt" "$TMP/g/$1/"
    rm -rf "$g" && mkdir -p "$(dirname "$g")" && cp -R "$TMP/g/$1" "$g"
    echo "updated tests/golden/$1"
  elif diff -r -x kdbx-entries.txt "$g" "$TMP/g/$1" >"$TMP/diff" 2>&1; then
    pass
  else
    fail "$1: output differs from tests/golden/$1 (run with UPDATE=1 and review the diff)"
    head -n 40 "$TMP/diff" | sed 's/^/    /'
  fi
}

echo "=== dejavu tests ($(uname -s), python $("$PY" -c 'import sys; print(sys.version.split()[0])'), keepassxc-cli: ${KP:-none}, PDF: ${PDF:-no})"

# --- Unit tests, and apps.yml against this ansibro ---
expect 0 "$PY" -m unittest discover -s "$SRC/tests" -p 'test_*.py'
expect 0 "$PY" "$SRC/tests/drift.py" "$ANSIBRO"

# --- Every test system ---
for c in ${CASES:-swarm-1-server swarm-ha k3s-ha stepca}; do
  system "$c"
  # Exit 3: built, and the user must now hand over the passphrase (0 when there is no credentials file).
  expect 3 build "$c"
  has "handover pack ready"
  no_leak "$c"
  golden "$c"
  # Sample PDFs for the release (fake data).
  if [ -n "${ARTIFACTS:-}" ] && [ "$c" = swarm-ha ] && [ -n "$PDF" ]; then
    for p in "$outdir"/dist/*/*.pdf; do cp "$p" "$ARTIFACTS/sample-$(basename "$p")"; done
  fi
  # Every file is in SHA256SUMS, and every hash is right.
  if (cd "$outdir/dist" && { sha256sum -c SHA256SUMS 2>/dev/null || shasum -a 256 -c SHA256SUMS; }) >/dev/null 2>&1; then pass; else fail "$c: SHA256SUMS does not match"; fi
  if [ -n "$KP" ]; then
    kdbx="$(find "$outdir/dist" -name '*.kdbx' | head -n 1)"
    phrase="$(cat "$TMP/$c/ansibro/state/handover/"*.passphrase 2>/dev/null || true)"
    if [ -f "$kdbx" ] && printf '%s\n' "$phrase" | "$KP" ls -R -f -q "$kdbx" >"$TMP/entries" 2>/dev/null; then
      pass
      if [ -n "${UPDATE:-}" ]; then
        cp "$TMP/entries" "$SRC/tests/golden/$c/kdbx-entries.txt"
      elif diff "$SRC/tests/golden/$c/kdbx-entries.txt" "$TMP/entries" >/dev/null; then
        pass
      else
        fail "$c: kdbx entries differ"
      fi
    else
      fail "$c: the credentials file does not open with its passphrase"
    fi
    # The passphrase file is private.
    p="$(ls "$TMP/$c/ansibro/state/handover/"*.passphrase 2>/dev/null || echo none)"
    case "$(ls -l "$p" 2>/dev/null)" in -rw-------*) pass ;; *) fail "$c: the passphrase file is not mode 600" ;; esac
    # A second build keeps the same credentials file.
    before="$(sha256sum "$kdbx" 2>/dev/null || shasum -a 256 "$kdbx")"
    expect 3 build "$c"
    after="$(sha256sum "$kdbx" 2>/dev/null || shasum -a 256 "$kdbx")"
    if [ "$before" = "$after" ]; then pass; else fail "$c: a second build made a new credentials file"; fi
  fi
done

# A password in the credentials file is the real one (garage: GK + the key file).
if [ -n "$KP" ] && [ -d "$TMP/swarm-ha" ]; then
  c=swarm-ha
  kdbx="$(find "$TMP/$c/out/dist" -name '*.kdbx' | head -n 1)"
  phrase="$(cat "$TMP/$c/ansibro/state/handover/"*.passphrase)"
  want="$(cat "$TMP/$c/ansibro/state/secrets/postgres")"
  got="$(printf '%s\n' "$phrase" | "$KP" show -q -s -a Password "$kdbx" "02 Database dan cache/PostgreSQL" 2>/dev/null || true)"
  if [ "$got" = "$want" ]; then pass; else fail "the PostgreSQL password in the credentials file is wrong"; fi
  want="GK$(cat "$TMP/$c/ansibro/state/secrets/garage_access_key")"
  got="$(printf '%s\n' "$phrase" | "$KP" show -q -a UserName "$kdbx" "03 Penyimpanan S3/Garage S3" 2>/dev/null || true)"
  if [ "$got" = "$want" ]; then pass; else fail "the Garage access key in the credentials file is wrong"; fi
fi

# --- What must stop the build ---
system minimal
expect 3 build minimal                 # required answers are empty
has "bast.number"
expect 3 build minimal --draft         # a draft works, and asks to deliver the credentials file
golden minimal
# A secret pasted into handover.yml: exit 5, the secret's name is shown, its value is not.
secret="$(cat "$TMP/minimal/ansibro/state/secrets/postgres")"
printf 'known_issues: ["%s"]\n' "$secret" >>"$TMP/minimal/out/handover.yml"
expect 5 build minimal --draft
has "contains postgres"
if printf '%s\n' "$out" | grep -qF -- "$secret"; then fail "the leak report shows the secret value"; else pass; fi
# The output folder inside a git repository: refused.
mkdir -p "$TMP/repo/out" && git -C "$TMP/repo" init -q
cp "$SRC/tests/fixtures/minimal/handover.yml" "$TMP/repo/out/"
expect 1 "$PY" "$H" build --ansibro "$TMP/minimal/ansibro" --out "$TMP/repo/out" --draft \
  --inventory-json "$SRC/tests/fixtures/minimal/inventory.json" --groupvars-json "$SRC/tests/fixtures/minimal/groupvars.json"
has "inside a git repository"
# Both state/ and state.age: refused, neither touched.
system minimal
touch "$TMP/minimal/ansibro/state.age"
expect 1 build minimal --draft
has "both state/ and state.age"
# A hand-edited document is kept.
system swarm-1-server
expect 3 build swarm-1-server
echo "edited" >>"$(find "$outdir/dist" -name '*dokumentasi-teknis.md')"
expect 1 build swarm-1-server
has "edited by hand"
# The passphrase is never shown to a program (only to a person at a terminal).
expect 1 "$PY" "$H" passphrase --ansibro "$TMP/swarm-1-server/ansibro" --out "$TMP/swarm-1-server/out"
has "only in a real terminal"
# Test-only flags are refused outside the tests.
expect 2 env DEJAVU_TEST= "$PY" "$H" facts --ansibro "$TMP/swarm-1-server/ansibro" --out "$TMP/x" --inventory-json /dev/null

echo "=== dejavu tests: $passed passed, $failed failed"
[ "$failed" = 0 ]
