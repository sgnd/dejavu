# Changelog

## 0.1.0

The first version.

- `dejavu install`, `remove`, `upgrade`, `search`, `list`, `restore`, `doctor` and `setup`.
- Your list (`~/.config/dejavu/packages.txt`): every install, with its version. `dejavu restore FILE` installs it all on a new computer.
- CLI tools and languages come from mise. Everything else comes from the system package manager: apt-get, dnf, yum, pacman, zypper, apk or Homebrew.
- Works on Linux and macOS, as root or as a normal user, in plain `sh`.
- An agent skill (`skills/dejavu/SKILL.md`) for Claude Code, Codex and Gemini CLI.
