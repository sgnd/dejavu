#!/bin/sh
# Installs (or updates) the dejavu skill for every AI agent on this computer:
#   curl -fsSL https://github.com/sgnd/dejavu/releases/latest/download/install.sh | sh
#
# It downloads the newest release (never main), checks its SHA-256, and copies the skill
# into the skills folder of each agent it finds: Claude Code, Codex, Gemini CLI and others.
# Run it again to update. It needs no admin rights.

set -eu
URL="${DEJAVU_DOWNLOAD_URL:-https://github.com/sgnd/dejavu/releases/latest/download}"

fail() { printf 'error: %s\n' "$*" >&2; exit 1; }
fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 3 --connect-timeout 20 -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -T 20 -O "$2" "$1"
  else
    fail "curl or wget is needed to download dejavu"
  fi
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fetch "$URL/dejavu-skill.tar.gz" "$tmp/dejavu-skill.tar.gz" || fail "could not download $URL/dejavu-skill.tar.gz"
fetch "$URL/SHA256SUMS" "$tmp/SHA256SUMS" || fail "could not download $URL/SHA256SUMS"

# Never install half a download, or a file that is not the release.
want="$(grep ' dejavu-skill.tar.gz$' "$tmp/SHA256SUMS" | cut -d ' ' -f 1)"
if command -v sha256sum >/dev/null 2>&1; then
  got="$(sha256sum "$tmp/dejavu-skill.tar.gz" | cut -d ' ' -f 1)"
else
  got="$(shasum -a 256 "$tmp/dejavu-skill.tar.gz" | cut -d ' ' -f 1)"
fi
[ -n "$want" ] && [ "$want" = "$got" ] || fail "the download does not match its SHA-256. Try again later."
mkdir "$tmp/skill"
tar -xzf "$tmp/dejavu-skill.tar.gz" -C "$tmp/skill"
[ -f "$tmp/skill/dejavu/SKILL.md" ] || fail "the download has no SKILL.md. Try again later."
version="$(sed -n 's/^  version: "\(.*\)"$/\1/p' "$tmp/skill/dejavu/SKILL.md")"

installed=""
for d in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" "${CODEX_HOME:-$HOME/.codex}" "$HOME/.gemini" \
  "$HOME/.config/agents" "$HOME/.agents"; do
  [ -d "$d" ] || continue
  # Replace the whole folder: also the skill of the old dejavu package manager (0.x), which had this name.
  rm -rf "$d/skills/dejavu"
  mkdir -p "$d/skills"
  cp -R "$tmp/skill/dejavu" "$d/skills/dejavu"
  installed="$installed $d/skills/dejavu"
done

if [ -z "$installed" ]; then
  fail "no AI agent found in $HOME (Claude Code, Codex, Gemini CLI). Install one, then run this again."
fi
printf 'ok: dejavu %s for your AI agents:%s\n' "$version" "$installed"
printf 'Start a new agent session in your ansibro folder and ask: "Make the handover documents".\n'
