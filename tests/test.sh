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
#   NO_PDF=1      skip the PDFs (faster); also skips the golden comparison, since the goldens list the PDFs
#   NO_GOLDEN=1   do not compare with tests/golden (they are made with the ansibro release in
#                 test.yml's ANSIBRO_REF; CI sets this for its run against ansibro main)

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
  # Without PDFs the certificate's annex lacks the PDF rows, so it can never match (and must not be written).
  [ -n "$PDF" ] || return 0
  [ -z "${NO_GOLDEN:-}" ] || return 0
  g="$SRC/tests/golden/$1"
  mkdir -p "$TMP/g"
  rm -rf "$TMP/g/$1"
  mkdir -p "$TMP/g/$1"
  cp "$outdir/facts.json" "$TMP/g/$1/"
  (cd "$outdir/dist" && find . -name '*.md' -o -name '*.txt' | while read -r f; do
    mkdir -p "$TMP/g/$1/$(dirname "$f")" && cp "$f" "$TMP/g/$1/$f"; done)
  (cd "$outdir/build" && find . -name '*.d2' | while read -r f; do
    mkdir -p "$TMP/g/$1/$(dirname "$f")" && cp "$f" "$TMP/g/$1/$f"; done)
  # File hashes in the certificate change with every PDF build: compare without them.
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
    for p in "$outdir"/dist/*.pdf; do cp "$p" "$ARTIFACTS/sample-$(basename "$p")"; done
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
  got="$(printf '%s\n' "$phrase" | "$KP" show -q -s -a Password "$kdbx" "02 Databases and cache/PostgreSQL" 2>/dev/null || true)"
  if [ "$got" = "$want" ]; then pass; else fail "the PostgreSQL password in the credentials file is wrong"; fi
  want="GK$(cat "$TMP/$c/ansibro/state/secrets/garage_access_key")"
  got="$(printf '%s\n' "$phrase" | "$KP" show -q -a UserName "$kdbx" "03 S3 storage/Garage S3" 2>/dev/null || true)"
  if [ "$got" = "$want" ]; then pass; else fail "the Garage access key in the credentials file is wrong"; fi
fi

# --- What must stop the build ---
system minimal
expect 3 build minimal                 # required answers are empty
has "certificate.number"
expect 3 build minimal --draft         # a draft works, and asks to deliver the credentials file
golden minimal
# A secret pasted into handover.yml: exit 5, the secret's name is shown, its value is not.
secret="$(cat "$TMP/minimal/ansibro/state/secrets/postgres")"
printf 'known_issues: ["%s"]\n' "$secret" >>"$TMP/minimal/out/handover.yml"
expect 5 build minimal --draft
has "contains postgres"
if printf '%s\n' "$out" | grep -qF -- "$secret"; then fail "the leak report shows the secret value"; else pass; fi
# A secret with characters that Markdown, Typst and YAML escape (_ + # ! " \), written in handover.yml
# with YAML escapes: still found. remove-leak takes it out without showing it; the next build works.
system minimal
printf '%s\n' 'CANARY_+#!"\x9-special' >"$sys/state/secrets/postgres"
printf '%s\n' 'summary_note: "Note CANARY_+#!\"\\x9-special"' >>"$outdir/handover.yml"
expect 5 build minimal --draft
has "contains postgres"
if printf '%s\n' "$out" | grep -qF -- 'CANARY_+#!'; then fail "the leak report shows the secret value"; else pass; fi
expect 0 "$PY" "$H" remove-leak --ansibro "$sys" --out "$outdir"
has "took out postgres"
if printf '%s\n' "$out" | grep -qF -- 'CANARY_+#!'; then fail "remove-leak shows the secret value"; else pass; fi
if grep -qF CANARY "$outdir/handover.yml"; then fail "remove-leak left the secret in handover.yml"; else pass; fi
expect 3 build minimal --draft
no_leak "minimal (special characters)"
# Several configs share one state/: the final build stops before another system's passwords go into
# the credentials file, until the user confirms; a draft has no credentials file.
system swarm-1-server
cp "$sys/config.yml" "$sys/config.staging.yml"
expect 3 build swarm-1-server
has "needs the user [shared-state]"
expect 0 build swarm-1-server --draft
has "warning [shared-state]"
if [ -n "$(find "$outdir/dist" -name '*.kdbx')" ]; then fail "a shared state/ went into a credentials file"; else pass; fi
expect 3 build swarm-1-server --accept-shared-state
has "handover pack ready"
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
# The output of dejavu 1.1 (a folder per language, the Indonesian credentials file name) is removed.
system swarm-1-server
expect 3 build swarm-1-server
mkdir -p "$outdir/dist/id" "$outdir/build/en"
echo old >"$outdir/dist/id/old.md"
echo old >"$outdir/dist/northwind-kredensial.kdbx"
expect 3 build swarm-1-server
has "removed the output of an older dejavu"
if [ -e "$outdir/dist/id" ] || [ -e "$outdir/build/en" ] || [ -e "$outdir/dist/northwind-kredensial.kdbx" ]; then
  fail "the output of an older dejavu is still there"
else
  pass
fi
# A hand-edited document is kept.
system swarm-1-server
expect 3 build swarm-1-server
echo "edited" >>"$(find "$outdir/dist" -name '*technical-documentation.md')"
expect 1 build swarm-1-server
has "edited by hand"
# The passphrase is never shown to a program (only to a person at a terminal).
expect 1 "$PY" "$H" passphrase --ansibro "$TMP/swarm-1-server/ansibro" --out "$TMP/swarm-1-server/out"
has "only in a real terminal"
# Test-only flags are refused outside the tests.
expect 2 env DEJAVU_TEST= "$PY" "$H" facts --ansibro "$TMP/swarm-1-server/ansibro" --out "$TMP/x" --inventory-json /dev/null

# --- ansibro newer than 1.2: state/handover.json replaces the ansible call, with the same facts ---
# Usage: same_facts CASE -> facts.json equals the golden one, apart from where the values came from
same_facts() {
  if "$PY" - "$SRC/tests/golden/$1/facts.json" "$TMP/$1/out/facts.json" <<'PYEOF'
import json, os, sys
want, got = (json.load(open(p)) for p in sys.argv[1:])
src = got["sources"].pop("traefik_nodes, admin_sso, database, cache, monitoring app")
want["sources"].pop("traefik_nodes, admin_sso, database, cache, monitoring app")
if os.environ.get("NO_GOLDEN"):  # another ansibro than the golden files: its alerts may differ
    for f in (want, got):
        f.pop("alerts", None)
        f.pop("ansibro", None)
if src != "state/handover.json" or want != got:
    print("    source:", src)
    sys.exit(1)
PYEOF
  then pass; else fail "$1: facts from state/handover.json differ"; fi
}
# Usage: handover_json CASE [APPS-EXTRA] -> writes state/handover.json the way ansibro does
handover_json() {
  "$PY" - "$SRC/tests/fixtures/$1" "$TMP/$1/ansibro/state/handover.json" "${2:-}" <<'PYEOF'
import json, os, sys
case, dest, extra = sys.argv[1:]
inv = json.load(open(os.path.join(case, "inventory.json")))
gv = json.load(open(os.path.join(case, "groupvars.json")))
gv.pop("swarm_leader", None)
apps = dict.fromkeys(inv["all"]["vars"]["apps"], {})
if extra:
    apps[extra] = {}
nodes = [{"name": n} for n in inv["_meta"]["hostvars"]]
json.dump({"ansibro_version": "1.3.0", "nodes": nodes, "apps": apps, "secret_files": [], **gv}, open(dest, "w"))
PYEOF
}
facts_only() {
  "$PY" "$H" facts --ansibro "$TMP/$1/ansibro" --out "$TMP/$1/out" --inventory-json "$SRC/tests/fixtures/$1/inventory.json"
}
for c in swarm-ha k3s-ha; do
  system "$c"
  handover_json "$c"
  expect 0 facts_only "$c"
  same_facts "$c"
done
# Encrypted state: handover.json is read from state.age, in memory.
if command -v age-keygen >/dev/null 2>&1; then
  system swarm-ha
  handover_json swarm-ha
  chmod 600 "$TMP/swarm-ha/ansibro/state/summary.md"
  age-keygen -o "$TMP/age.key" 2>/dev/null
  (cd "$TMP/swarm-ha/ansibro" && tar -cf - state | age -r "$(age-keygen -y "$TMP/age.key")" >state.age && rm -rf state)
  expect 0 env ANSIBRO_KEY="$TMP/age.key" "$PY" "$H" facts --ansibro "$TMP/swarm-ha/ansibro" --out "$TMP/swarm-ha/out" \
    --inventory-json "$SRC/tests/fixtures/swarm-ha/inventory.json"
  has "facts.json"
  if grep -qF '"state/handover.json"' "$TMP/swarm-ha/out/facts.json"; then pass; else fail "state.age: handover.json not used"; fi
fi
# The config changed after the install (an app added): handover.json is not used, and dejavu says so.
# (Where ansible is installed, dejavu falls back to it instead: only checked where it is not.)
system minimal
handover_json minimal uptimekuma
if ! command -v ansible >/dev/null 2>&1 && [ ! -x "$(dirname "$("$PY" -c 'import sys; print(sys.executable)')")/ansible" ]; then
  expect 1 facts_only minimal
  has "ansible is not installed"
fi

# --- doctor --fix: installs what needs no admin rights, never sudo, and is safe to run twice ---
# Usage: path_without NAME... -> a PATH folder with every command of this machine except NAME...
path_without() {
  d="$TMP/path-$1"
  rm -rf "$d" && mkdir -p "$d"
  for dir in /usr/local/bin /opt/homebrew/bin /usr/bin /bin; do
    [ -d "$dir" ] || continue
    for f in "$dir"/*; do
      n="${f##*/}"
      for skip in "$@"; do [ "$n" != "$skip" ] || continue 2; done
      [ -e "$d/$n" ] || ln -s "$f" "$d/$n"
    done
  done
  # A sudo that only leaves a mark: dejavu must never call it. (rm first: never write through the
  # link to the real sudo.)
  rm -f "$d/sudo"
  printf '#!/bin/sh\ntouch "%s/sudo-was-called"\nexit 1\n' "$TMP" >"$d/sudo"
  chmod +x "$d/sudo"
  echo "$d"
}
system minimal
# keepassxc-cli missing on Linux: --fix asks the user (it needs sudo), and runs nothing as root.
if [ "$(uname)" = Linux ]; then
  nokp="$(path_without keepassxc-cli keepassxc)"
  expect 3 env PATH="$nokp" "$PY" "$H" doctor --fix --ansibro "$TMP/minimal/ansibro"
  has "needs the user [keepassxc]"
  has "sudo apt-get install"
  if [ -e "$TMP/sudo-was-called" ]; then fail "doctor --fix called sudo"; else pass; fi
fi
# (These need the network, like the PDF tests.)
if [ -n "$PDF" ]; then
  nomise="$(path_without mise pandoc typst d2)"
  # The PDF tools are already downloaded in $HOME: share them, so only mise itself is downloaded.
  share="${MISE_DATA_DIR:-$HOME/.local/share/mise}"
  # Usage: fixdoc HOME [ARGS] -> doctor without mise on PATH, with that home folder
  fixdoc() {
    h="$1"
    shift
    mkdir -p "$h"
    env PATH="$nomise" HOME="$h" MISE_DATA_DIR="$share" "$PY" "$H" doctor --ansibro "$TMP/minimal/ansibro" "$@"
  }
  # 1. A mise that is already there but not on PATH (brework's in /opt/homebrew/bin, the container's in
  #    /usr/local/bin) is used: no second mise.
  for m in /opt/homebrew/bin/mise /usr/local/bin/mise; do
    [ -x "$m" ] || continue
    expect 0 fixdoc "$TMP/home-has-mise" --fix
    has "pandoc: mise"
    if printf '%s\n' "$out" | grep -qF "installing mise"; then fail "a second mise was installed next to $m"; else pass; fi
    if [ -e "$TMP/home-has-mise/.local/bin/mise" ]; then fail "mise was installed into ~/.local/bin next to $m"; else pass; fi
    break
  done
  # 2. No mise anywhere: doctor says --fix helps; --fix puts mise in ~/.local/bin and downloads the
  #    PDF tools; a second run installs nothing again.
  export DEJAVU_TEST_NO_SYSTEM_MISE=1
  expect 3 fixdoc "$TMP/home-no-mise"
  has "doctor --fix"
  expect 0 fixdoc "$TMP/home-no-mise" --fix
  has "mise installed: $TMP/home-no-mise/.local/bin/mise"
  has "pandoc: mise"
  if [ -x "$TMP/home-no-mise/.local/bin/mise" ]; then pass; else fail "mise is not in ~/.local/bin"; fi
  expect 0 fixdoc "$TMP/home-no-mise" --fix
  if printf '%s\n' "$out" | grep -qF "installing"; then fail "the second doctor --fix installed again"; else pass; fi
  unset DEJAVU_TEST_NO_SYSTEM_MISE
  if [ -e "$TMP/sudo-was-called" ]; then fail "doctor --fix called sudo"; else pass; fi
fi

echo "=== dejavu tests: $passed passed, $failed failed"
[ "$failed" = 0 ]
