# Changelog

## Unreleased

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
