---
name: dejavu
description: Install, remove, upgrade or find CLI tools, languages and system packages on Linux or macOS with one command (dejavu), without questions or admin rights where possible. Use it whenever a task needs a program that is missing (command not found), or the user asks to install, remove or update software. Use it instead of apt, brew, dnf, npm -g, pip install or curl | sh.
---

# Install software with dejavu

dejavu is one command on top of the package managers that already exist: [mise](https://mise.jdx.dev) for CLI tools and languages (no admin rights needed), and the system package manager (apt-get, dnf, yum, pacman, zypper, apk or Homebrew) for the rest. It never asks questions, so it cannot hang waiting for an answer.

Many users never use a terminal. Explain what you do in plain words, and never ask them to fix things you can fix yourself.

## 1. Make sure dejavu is there

```bash
command -v dejavu || ls ~/.local/bin/dejavu
```

If it is missing, set it up (no admin rights needed):

```bash
curl -fsSL https://raw.githubusercontent.com/sgnd/dejavu/main/dejavu | sh -s -- setup
```

Without curl, use `wget -qO- URL | sh -s -- setup`. Your shell may not find new commands until it restarts, so call it by its full path: `~/.local/bin/dejavu`.

On a machine you don't know yet, run `dejavu doctor` once. It shows the system, whether you have admin rights (most often you don't), the package manager and the internet connection.

## 2. Install

```bash
dejavu install ripgrep jq          # several at once
dejavu install node@lts python@3.13   # languages: pin a version the project needs
dejavu install system:build-essential # a system package (often needs admin rights)
```

- **Give it time.** Most tools take seconds, big ones (ffmpeg, a language) several minutes. Run it with a long timeout (10 minutes) or in the background. Never stop it halfway: a stopped system install can break the package manager.
- **Find the name first** when you are not sure: `dejavu search WORD`. Then use a name from the list exactly as it is shown. Never guess package names for `npm:`, `pypi:`, `cargo:` or `github:`. Attackers publish packages under names that AI agents make up. Use a name from the search, the tool's official docs, or the user.
- **Which kind of name:**
  - A plain name (`ripgrep`, `gh`, `node`) uses mise when its registry knows the tool, else the system package manager.
  - `npm:NAME`, `pypi:NAME`, `github:OWNER/REPO`, `cargo:NAME`, `go:MODULE` install from that source through mise.
  - dejavu adds the helper a tool needs (node, uv, rust or go), also for plain names that come from such a source (like `prettier`, from npm).
  - `system:NAME` always uses the system package manager. Use it for servers and services (`system:nginx`, `system:postgresql`), libraries and build tools (`system:libpq-dev`, `system:build-essential`), and anything other users or system services must also find.

## 3. Read the result

Every package gets one line, and the exit code sums them up:

| Line | Exit code | What to do |
| --- | --- | --- |
| `ok: ...` | 0 | Done. The line lists the new commands. |
| `failed: ...` | 1 | Read the lines under it: the end of the error, a `hint:` and the log file. Fix the cause, then run the same command again. |
| (usage error) | 2 | Wrong command or name. Run `dejavu help`. |
| `needs the user: ...` | 3 | Only the user can do this, usually type their password for `sudo`. Show them the exact command from the line, and say why. Don't try to get around it. |

When a tool needs the user, another tool may do the same job without admin rights (for example a formatter that is one program, instead of one that needs node). Search for one and offer it, but let the user choose.

After an install, your shell may not find the new command by name yet (`command not found`). The `ok:` line says so. Use the full path it shows (`~/.local/share/mise/shims/NAME`) or run `export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"` in the same command. Don't install the tool again.

## 4. Other commands

```bash
dejavu list               # tools installed with mise
dejavu upgrade            # every mise tool, mise and dejavu (not system packages)
dejavu upgrade jq         # one tool; system:NAME for a system package
dejavu remove jq          # ask the user first
dejavu doctor             # the machine: OS, admin rights, package manager, internet, PATH
```

Run `dejavu doctor` first when something looks wrong, or before a big install on an unknown machine.

## Rules

- Use dejavu, not `sudo apt-get`, `brew`, `npm -g`, `pip install` or `curl | sh` installers. It already picks the right one for this machine.
- Never run dejavu with `sudo`. It asks for admin rights itself, and stops with "needs the user" when only a password helps.
- Ask the user before you remove anything, and before you install system packages on a server that runs services.
- Run the same command again after you fix a failure. dejavu skips what is already there.
- Two dejavu commands at once wait for each other. That is normal.
- Tell the user what you installed. mise tools are listed in `~/.config/mise/config.toml`, which is their file.
- A language version (`python@3.12`, `node@lts`) becomes the default for this user, in every folder. Tell them.
