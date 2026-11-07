# dejavu 1.1.0 (draft release notes)

Draft, not a release. It is derived from the `## Unreleased` section of CHANGELOG.md and the
commits since v1.0.0. To release: set `metadata.version` in `skills/dejavu/SKILL.md` to `1.1.0`,
rename `## Unreleased` in CHANGELOG.md to exactly `## 1.1.0` (release.yml copies that section
into the GitHub release), merge, then push the tag `v1.1.0`.

1.1.0 is a minor release: new features and fixes. The `handover.yml` settings are the same as in
1.0.0. Output text changed in a few places: `doctor` prints `ok: dejavu <version>` first,
summaries count in the singular for one ("1 server"), and there is a new warning id,
`server-facts`.

## ansibro 1.3

- With an ansibro newer than 1.2, dejavu reads ansibro's own settings (Traefik servers, admin
  login, database, cache, monitoring) from `state/handover.json`, also inside `state.age`. Older
  ansibro works as before, through one ansible call.
- `state/handover.json` is checked against `config.yml` (servers, addresses, roles, app placement,
  domain, TLS). When it does not match, or is in an unknown form, `facts` warns
  `handover-json-outdated` and reads the settings through ansible instead.
- The Kong admin key (`state/secrets/kong_admin_key`, Swarm) is in the credentials file and the
  documents; the technical documentation says how Kong's admin API is guarded; the cache alert
  names the cache app (Redis or Valkey).
- `metadata.ansibro` is now `>=1.2.0 <1.4`. With an ansibro outside that range, `facts` warns
  `ansibro-untested-version` and still makes the documents.

## Installing the tools

- `doctor --fix` installs the missing tools where no admin rights are needed: mise into
  `~/.local/bin`, and pandoc, Typst and d2 through mise. On macOS with Homebrew it also installs
  KeePassXC, and age when `state.age` is used. Anything that needs `sudo` stays with the user.
- It uses a mise that is already there (also Homebrew's) instead of installing a second one, and
  never edits `~/.zshrc`, `~/.bashrc` or mise's global config.
- `doctor` prints the dejavu version first; `handover.py --version` prints it; `--help` lists the
  commands, the message prefixes and the exit codes.

## Fixes

- `check` no longer reports a crashed acceptance test as passed: it is recorded as a FAIL.
- `check` warns `server-facts` when ansible could not read the servers' details, and counts only
  the servers it reached. A garbled answer from one server no longer stops it.
- A wrong age key for `state.age` stops with `failed [age]` and age's own message, instead of a
  Python traceback.
- A `handover.yml` that is not valid YAML, or a `people:` entry that is not a mapping, stops with
  `failed [answers]` (exit 2) instead of a traceback.
- Encrypted state is closed exactly once after Ctrl-C, a failed close in `check` is reported, and
  `state.age` is decrypted once per run.
- The credentials file is made again when a password or an attached file changed, not only when
  the list of passwords changed.
- `ssh_handover: generated`: the client's key is made once and kept in `state/handover/`, its
  public key is written next to the documents, and `build` says to put it on the servers.
- The passphrase and SSH key files in `state/handover/` are set to mode 600 on every write.
- `scan` and `passphrase` work without `facts.json`. A clear message when ansible is needed but
  not installed.

## Documentation

- The message prefixes are written as dejavu prints them: `warning [id]:`, `needs the user [id]:`,
  `failed [id]:`. The troubleshooting tables have no broken rows and cover `python` and
  `server-facts`.
- SECURITY.md now states the two places where secret material leaves memory while the
  credentials file is built: an S3 access key ID (not its secret key) is on keepassxc-cli's
  command line as the entry's username, and attached files are written for a moment to a private
  temp folder. It also says how `doctor --fix` gets mise (the official `https://mise.run`
  installer over HTTPS, without a checksum of its own, only after the user agreed).
- The README links the troubleshooting guide and says how to update and remove the skill.

## Tests and CI

- CI also tests against ansibro main (every check except the golden files, also every Monday).
- `NO_PDF=1` skips the golden comparison, so a run without PDFs can pass. CI runs
  `apt-get update` before installing packages.

## Install or update

```sh
curl -fsSL https://github.com/sgnd/dejavu/releases/latest/download/install.sh | sh
```

## Known limits of this release

- The `state/handover.json` path is tested in CI against ansibro main only; ansibro 1.3.0 is not
  released yet. The golden files are made with ansibro 1.2.0.
- The GitHub Actions are pinned by version tags, not commit SHAs. The release has a SHA-256
  checksum from the same release, but no build provenance attestation.
