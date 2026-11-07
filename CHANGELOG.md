# Changelog

Every version is a [GitHub release](https://github.com/sgnd/dejavu/releases). `install.sh` installs the newest one.

## Unreleased

- English only: dejavu is made for clients anywhere. The Indonesian documents are gone, and so are the terms and practices of one country: the BAST is now the **handover certificate** (Handover and Acceptance Certificate), without the stamp-duty (meterai) box, and dates and numbers are written the English way.
- `handover.yml`: the section `bast:` is now `certificate:`, `mengetahui:` is now `acknowledged_by:`, and `lang:` and `meterai:` are gone. A `handover.yml` from 1.1 still works: dejavu reads the old names and warns `answers-renamed` or `lang`.
- The documents are in `dist/` itself, no longer in `dist/en/` or `dist/id/`. The first build removes those old folders (after the check for hand edits), and an old `<slug>-kredensial.kdbx`. The credentials file is always `<slug>-credentials.kdbx`, with English group names.
- `apps.yml` holds one English text per app, note and group.
- The test systems and the sample PDFs use English fake names and addresses.

## 1.1.0

- Releases record how `dejavu-skill.tar.gz` and `install.sh` were built (GitHub build provenance). Check a download with `gh attestation verify dejavu-skill.tar.gz --repo sgnd/dejavu`. The GitHub Actions in CI are pinned to commits.
- With an ansibro newer than 1.2, dejavu reads ansibro's own settings (Traefik servers, admin login, database, cache, monitoring) from `state/handover.json`, also inside `state.age`. Older ansibro works as before, through one ansible call.
- When `state/handover.json` no longer matches `config.yml` (other servers or apps), `facts` warns `handover-json-outdated`: the config changed after the last install.
- A clear message when ansible is needed but not installed (also in `check`).
- `state/handover.json` is also checked against the servers' addresses, roles, the app placement, the domain and TLS; a file in an unknown form falls back to ansible instead of stopping.
- The credentials file is made again when a password or an attached file changed, not only when the list of passwords changed.
- `check` no longer reports a crashed acceptance test as passed: it is recorded as a FAIL.
- `ssh_handover: generated`: the client's key is made once and kept in `state/handover/`, its public key is written next to the documents (`<slug>_ed25519.pub`), and `build` says to put it on the servers.
- Encrypted state: closed exactly once after Ctrl-C, a failed close in `check` is reported, and `state.age` is decrypted once per run instead of for every step.
- `scan` and `passphrase` work without `facts.json`.
- `doctor --fix` installs the missing tools where no admin rights are needed: mise into `~/.local/bin`, and pandoc, Typst and d2 through mise (downloaded ahead, so the first build needs no network). On macOS with Homebrew it also installs KeePassXC, and age when `state.age` is used. Anything that needs `sudo` stays with the user. Running it again changes nothing.
- dejavu shares one Mac with brework, ansibro and komando: it uses a mise that is already there (also Homebrew's in `/opt/homebrew/bin` or `/usr/local/bin` when it is not on PATH) instead of installing a second one, never reinstalls a KeePassXC.app that is there, finds Homebrew's brew and age off PATH, and only runs `mise exec` / `mise install tool@version`: it never edits `~/.zshrc`, `~/.bashrc` or mise's global config.
- Ready for ansibro 1.3: the Kong admin key (`state/secrets/kong_admin_key`, Swarm) is in the credentials file and the documents, the technical documentation says how Kong's admin API is guarded, and the cache alert names the cache app (Redis or Valkey). `metadata.ansibro` covers 1.2 and 1.3 (`>=1.2.0 <1.4`).
- CI also tests against ansibro main (every check except the golden files, also every Monday), so a change in ansibro that dejavu misses shows up before ansibro releases it.
- A wrong age key for `state.age` now stops with `failed [age]` and age's own message, instead of a Python traceback.
- A `handover.yml` that is not valid YAML, or a `people:` entry that is not `name:/os:/persona:`, now stops with `failed [answers]` (exit 2) instead of a traceback.
- `check` warns `server-facts` when ansible could not read the servers' details, and counts only the servers it reached. A garbled answer from one server no longer stops it.
- `doctor` prints the dejavu version first, `handover.py --version` prints it, and `--help` lists the commands and exit codes.
- The passphrase and SSH key files in `state/handover/` are set to mode 600 on every write, also when they already existed with a wider mode.
- Docs: the message prefixes are written as dejavu prints them (`warning [id]:`, not `warning: [id]`); the troubleshooting tables lost their broken rows and gained `python` and `server-facts`; SECURITY.md says that S3 access key IDs are on keepassxc-cli's command line, that attachments touch a private temp folder for a moment, and how `doctor --fix` gets mise; the README links the troubleshooting guide and says how to update and remove the skill.
- Tests: `NO_PDF=1` skips the golden comparison (the goldens list the PDFs), so it can pass. CI runs `apt-get update` before installing.

## 1.0.0

dejavu is now an agent skill that hands a server system built with ansibro over to a client.

- One request to an AI agent makes the complete handover pack: the BAST (Berita Acara Serah Terima / Handover and Acceptance Certificate) with its annexes, the technical documentation, and a laptop access guide for each OS the client's staff use (Windows, macOS, Linux). In Indonesian, English or both, as Markdown and PDF/A.
- Every password goes into one encrypted KeePassXC file. The documents never contain a password: every build searches them, and stops when it finds one.
- The facts come from ansibro itself (its inventory, its own rules, its alert rules). The agent asks only what ansibro cannot know.
- Install it with `install.sh` from the latest release.

The package manager (0.1.0 to 0.3.1) is retired. 0.3.1 keeps working and stays available. See the README to remove it.

## 0.3.1

- Quick tests (`tests/unit.sh`): names, the list, versions and hints, in seconds, without installing anything. CONTRIBUTING.md explains how `dejavu` is built.

## 0.3.0

- Setup and `dejavu upgrade` download the newest release, never `main`. A release only comes out after every test passed. (Forks: set `DEJAVU_DOWNLOAD_URL`, which replaces `DEJAVU_RAW_URL`.)

## 0.2.0

- Agent skills: `dejavu install skill:OWNER/REPO@NAME` installs a skill from [skills.sh](https://skills.sh) for your AI agents, with the skills CLI. `search skill:WORD`, `upgrade`, `remove`, your list and `restore` work for skills too.
- A name cannot be a file or a URL (`/tmp/x.deb`, `system:https://.../x.rpm`, `x.apk`). The package manager would install it as root, without its repositories.
- `dejavu remove NAME` only removes what is on your list. A tool that you or another setup (like brework) installed stays. `dejavu remove system:NAME` still removes a system package.
- A name cannot be an option after its source either (`system:-o...`), so it never changes how the package manager runs.
- `remove` on Alpine says when `apk` keeps a package that others need, instead of "ok".
- `redis`, `postgres`, `mysql` and other servers come from the system package manager first, as a service.
- A lock left by a stopped dejavu in a container no longer makes the next one wait 30 minutes.
- Downloads give up on a server that does not answer.

## 0.1.0

The first version.

- `dejavu install`, `remove`, `upgrade`, `search`, `list`, `restore`, `doctor` and `setup`.
- Your list (`~/.config/dejavu/packages.txt`): every install, with its version. `dejavu restore FILE` installs it all on a new computer.
- CLI tools and languages come from mise. Everything else comes from the system package manager: apt-get, dnf, yum, pacman, zypper, apk or Homebrew.
- Works on Linux and macOS, as root or as a normal user, in plain `sh`.
- An agent skill (`skills/dejavu/SKILL.md`) for Claude Code, Codex and Gemini CLI.
