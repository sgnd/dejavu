# Changelog

Every version is a [GitHub release](https://github.com/sgnd/dejavu/releases). `install.sh` installs the newest one.

## Unreleased

- With ansibro 1.3 and newer, dejavu reads ansibro's own settings (Traefik servers, admin login, database, cache, monitoring) from `state/handover.json`, also inside `state.age`. Older ansibro works as before, through one ansible call.
- When `state/handover.json` no longer matches `config.yml` (other servers or apps), `facts` warns `handover-json-outdated`: the config changed after the last install.
- A clear message when ansible is needed but not installed.
- `doctor --fix` installs the missing tools where no admin rights are needed: mise into `~/.local/bin`, and pandoc, Typst and d2 through mise (downloaded ahead, so the first build needs no network). On macOS with Homebrew it also installs KeePassXC, and age when `state.age` is used. Anything that needs `sudo` stays with the user. Running it again changes nothing.
- dejavu shares one Mac with brework, ansibro and komando: it uses a mise that is already there (also Homebrew's in `/opt/homebrew/bin` or `/usr/local/bin` when it is not on PATH) instead of installing a second one, never reinstalls a KeePassXC.app that is there, finds Homebrew's brew and age off PATH, and only runs `mise exec` / `mise install tool@version`: it never edits `~/.zshrc`, `~/.bashrc` or mise's global config.

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
