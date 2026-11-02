# Changelog

Every version is a [GitHub release](https://github.com/sgnd/dejavu/releases). Setup and `dejavu upgrade` download the newest one.

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
