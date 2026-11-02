# dejavu

[![Test](https://github.com/sgnd/dejavu/actions/workflows/test.yml/badge.svg)](https://github.com/sgnd/dejavu/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Let your AI agent install software for you, on Linux and macOS.

You tell your [AI agent](#words-used-here) what you need, in your own words: "I need ffmpeg". The agent runs one command:

```bash
dejavu install ffmpeg
```

and gets one clear answer back: done, failed and why, or what you must do yourself (like type your password).

## How it works

dejavu is not a new [package manager](#words-used-here). It uses the ones that already exist, and picks the right one for your computer:

- **[mise](https://mise.jdx.dev)** for [CLI tools](#words-used-here) and programming languages, like `ripgrep`, `jq`, `node` or `python`. It needs no [admin rights](#words-used-here), and works the same on every Linux and macOS. dejavu installs it for you.
- **Your system's package manager** for the rest, like web servers, databases and libraries: `apt-get` (Debian, Ubuntu), `dnf` or `yum` (Fedora, Red Hat, Rocky, Amazon Linux), `pacman` (Arch), `zypper` (openSUSE), `apk` (Alpine) or [Homebrew](https://brew.sh) (macOS).

The name: everything here already exists. You have seen it before.

## Requirements

- Linux or macOS, on a desktop or a server.
- An internet connection.

That's all. dejavu brings what else it needs.

## Start

Ask your AI agent:

> Set up dejavu from https://github.com/sgnd/dejavu

Or paste this into a [terminal](#words-used-here) yourself:

```bash
curl -fsSL https://raw.githubusercontent.com/sgnd/dejavu/main/dejavu | sh -s -- setup
```

This runs a script from the internet. It is plain text, so you (or your agent) can [read `dejavu`](dejavu) first.

Then open a new terminal, or restart your AI agent. You can run setup again at any time: it never changes anything twice.

## Use

Just ask your agent: "install the GitHub CLI", "I need something to convert videos", "remove jq". The agent knows how to use dejavu (setup taught it).

You can also type the commands yourself:

```bash
dejavu install ripgrep jq    # install one or more tools
dejavu search pdf            # find the right name
dejavu list                  # your list: everything installed, with versions
dejavu upgrade               # get the newest versions
dejavu remove jq             # remove a tool
dejavu restore FILE          # install everything from a list (see below)
dejavu install skill:anthropics/skills@pdf   # an agent skill (see below)
dejavu doctor                # check this computer when something is wrong
dejavu help                  # all commands
```

Each tool gets one line back:

- `ok:` it is installed. The line lists the new commands.
- `failed:` it did not work. Below it: the error, a hint in plain words, and where the full log is.
- `needs the user:` only you can do this, usually type your password. The line has the exact command to run in your terminal.

Big installs can be quiet for minutes. dejavu says "Still working" every 30 seconds. Let it finish: stopping halfway can break things.

**When dejavu needs your password:** some packages change the whole computer, so they need [admin rights](#words-used-here). dejavu never types your password, so it stops and gives you one command that starts with `sudo`. To run it:

1. Open a [terminal](#words-used-here) (on a Mac: the Terminal app).
2. Paste the command and press Enter.
3. Type your computer's password (the one you log in with) and press Enter. You see nothing while you type, not even dots. That is normal.
4. When it is done, tell your agent. It runs dejavu again to finish.

dejavu installs command-line tools, not apps with windows. Install a browser or an editor like VS Code from your app store or the maker's website.

## Agent skills

A [skill](#words-used-here) teaches your AI agent a new task, like filling in PDF forms. Ask your agent: "find a skill for PDFs". It searches [skills.sh](https://skills.sh), tells you what it found, and installs the one you pick:

```bash
dejavu search skill:pdf
dejavu install skill:anthropics/skills@pdf
```

The skill is ready in your agent's next session. `dejavu upgrade` keeps your skills up to date, and they are on [your list](#move-to-a-new-computer) like everything else.

A skill tells your agent what to do, so only install skills from people you trust. dejavu uses the [skills CLI](https://github.com/vercel-labs/skills) for this (it installs it, and Node.js and git, the first time). It turns off the CLI's usage statistics.

## Move to a new computer

dejavu writes down everything it installs, with the version, in one small text file: your list. `dejavu list` shows it, and where it is (`~/.config/dejavu/packages.txt`).

1. **On the old computer:** copy that file somewhere safe: a USB stick, your cloud drive, or an email to yourself. Do it now and then, so a lost or broken computer does not lose it.
2. **On the new computer:** [start dejavu](#start), then:

   ```bash
   dejavu restore packages.txt
   ```

   Or ask your agent: "Install everything from my dejavu list", and give it the file.

That's it. dejavu installs everything on the list, and makes it your list on this computer. Good to know:

- **Same tools, newest versions.** The list remembers what you asked for. `ripgrep` gets the newest version, `python@3.12` stays on 3.12. To get the exact old version, change the line, like `ripgrep` to `ripgrep@15.2.0` (the version is in the note after `#`).
- **From Mac to Linux, or back:** that works. Tools from mise have the same name everywhere. A system package (a line with `system:`) can have another name on the other system. dejavu says which ones did not install, and `dejavu search` finds the new name.
- **It stops halfway** (no internet, a laptop that went to sleep): run the same command again. It skips what is already there.
- **Some need your password:** at the end, dejavu shows one command for all of them, so you type your password once. Run `dejavu restore packages.txt` again afterwards, so they are on your new list too.
- **Your list on GitHub** (or another website): `dejavu restore https://.../packages.txt` works too. Only use a list you trust: it installs everything on it.
- **Repair this computer:** `dejavu restore` without a file installs everything on your own list that is missing.

The file is plain text. One package per line, and anything after `#` is a note:

```text
ripgrep  # 15.2.0, mise
python@3.12  # 3.12.16, mise
system:nginx  # 1.24.0-2ubuntu7, apt-get
```

You can edit it. To keep a tool off the list, use `dejavu remove`.

## Words used here

- **Terminal**: the window where you type commands. On a Mac: the Terminal app. On Linux: Terminal, Konsole or a similar app. On a server: what you see after you log in with SSH.
- **CLI tool**: a program you use by typing a command in the terminal, like `git` or `ffmpeg`. (CLI: command line interface.)
- **AI agent**: an AI assistant that can run commands on your computer for you, like Claude Code, Codex or Gemini CLI.
- **Package manager**: a program that downloads, installs, updates and removes other programs for you.
- **Admin rights**: permission to change the whole computer, not just your own files. Commands with `sudo` in front use them, and ask for your password.
- **Skill**: a folder of instructions that teaches an AI agent a task. Agents read it when the task comes up.
- **PATH**: the list of folders where the terminal looks for commands. When a new tool is not in it, you get `command not found`.

## What it changes on your computer

- `~/.local/bin`: dejavu itself, and mise (if you did not have it yet)
- `~/.local/share/mise`: the tools that mise installs
- `~/.config/dejavu/packages.txt`: your list. Everything installed with dejavu, with the version. Keep a copy: it is all you need to [move to a new computer](#move-to-a-new-computer).
- `~/.config/mise/config.toml`: the list of your mise tools. It is your file, you can edit it.
- One line at the end of your shell settings (`~/.profile`, and `~/.bashrc`, `~/.zprofile` or `~/.zshrc` if you use them), so new terminals find the tools. It ends with `# added by dejavu`. If you use fish: `~/.config/fish/conf.d/dejavu.fish`.
- Only when a tool needs them: the helpers it runs with (node, uv, rust or go, with mise), and system packages that dejavu itself needs (curl, tar, gawk, ca-certificates, git, or nodejs on Alpine).
- `skills/dejavu/SKILL.md` in the folder of each AI agent it finds (Claude Code, Codex, Gemini CLI): the instructions that teach your agent to use dejavu.
- Only when you install an agent skill: the skill in `~/.agents/skills` and your agents' `skills` folders, and the skills CLI's list of them, `~/.agents/.skill-lock.json`.
- Logs in `~/.local/state/dejavu`, deleted after a week.

`~` is your home folder. dejavu never asks for, stores or types your password. It never upgrades all your system packages at once, because that can restart services on a server.

Your Mac was set up with [brework](https://github.com/sgnd/brework)? dejavu uses brework's mise and Homebrew. `dejavu remove` only removes what dejavu installed (what is on your list), so the tools brework set up stay. To remove a system package that is not on your list, write `dejavu remove system:NAME`.

## Something went wrong

Run `dejavu doctor` first. It shows your system, your admin rights, the package manager, the internet connection and the free disk space.

| You see | What to do |
| --- | --- |
| `needs the user: ... sudo ...` | Copy the command from that line into your terminal. It asks for your password. |
| `GitHub limits downloads` | GitHub allows 60 downloads per hour without an account. Wait an hour, or log in with `gh auth login`. |
| `No internet, or a sandbox blocks it` | Check your connection. Some AI agents run commands in a "sandbox" without internet: allow this command to use the network. |
| `This skill was not found` | Find the right name with `dejavu search skill:WORD`. |
| `This name or version was not found` | Find the right name with `dejavu search WORD`. After a restore from another system, change that line in your list to the new name. |
| `Not a package name (line 7 of ...)` | That line of your list has a typo. Fix it, then run `dejavu restore` again. |
| `command not found` right after an install | Open a new terminal. The `ok:` line also shows the full path of the tool. |
| `Another dejavu is running` | Another install is busy. dejavu waits and then continues by itself. |

Still stuck? [Open an issue](https://github.com/sgnd/dejavu/issues/new?template=bug-report.yml) with the output and `dejavu doctor`.

## Remove dejavu

1. Remove the tools you no longer need: `dejavu list`, then `dejavu remove NAME`.
2. Delete dejavu and its logs: `rm -rf ~/.local/bin/dejavu ~/.local/state/dejavu`. Keep `~/.config/dejavu/packages.txt` if you may want your tools back later.
3. Delete the line that ends with `# added by dejavu` from your shell settings (and `~/.config/fish/conf.d/dejavu.fish` if you use fish), and the `skills/dejavu` folder of your AI agents.
4. To also remove mise and all its tools: `mise implode`. Only do this if dejavu installed mise. (On a brework Mac, mise belongs to brework.)

## Details

For AI agents, developers and the curious. The full guide for agents is [`skills/dejavu/SKILL.md`](skills/dejavu/SKILL.md).

### Names

| You write | dejavu uses |
| --- | --- |
| `ripgrep`, `gh`, `ffmpeg`, `node@lts`, `python@3.13` | mise, when its [registry](https://mise.jdx.dev/registry.html) knows the name. Else the system package manager. |
| `redis`, `postgres`, `mysql`, `mongodb`, `elasticsearch`, `clickhouse`, `minio`, `neo4j` | The system package manager first, so they run as a service. mise only when the system has no such package. |
| `npm:prettier`, `pypi:black`, `github:owner/repo`, `cargo:NAME`, `go:MODULE` | mise, from that source. dejavu first installs what it needs (node, uv, rust or go). |
| `system:nginx`, `system:build-essential` | Always the system package manager. For servers and services, libraries, build tools, and anything every user on the computer needs. |
| `skill:OWNER/REPO@NAME` or `skill:OWNER/REPO/NAME` | An agent skill, with the [skills CLI](https://github.com/vercel-labs/skills) (from npm, through mise). `skill:OWNER/REPO` shows the skills in that repository. |

### Exit codes

For scripts: `0` all ok, `1` something failed, `2` wrong command or name, `3` the user must do something.

### Why agents need this

| Without dejavu | With dejavu |
| --- | --- |
| The agent guesses the command (`apt`? `brew`? `npm -g`?) | One command on every Linux and macOS |
| An installer asks a question, and the agent waits forever | Nothing asks questions |
| An installer needs a password the agent cannot type | Most tools need no admin rights. Otherwise dejavu stops and gives the exact command for the user |
| "Installed", but it does not run (a build for another Linux) | On Linux, dejavu runs the new program to check, and uses the system package manager when it does not run |
| `command not found` right after the install | dejavu sets up PATH and gives the full path |
| Thousands of lines of output fill the agent's memory | One line per tool. The rest goes to a log |
| Two agents install at once and break each other | The second one waits |
| The agent makes up a package name, and attackers have published a fake package under it | `dejavu search` finds the real name. The skill tells the agent never to guess |

### On a server

- mise tools are installed for the user that runs dejavu, in their home folder. Other users and system services don't see them. For those, use `system:NAME`.
- As `root`, system packages install right away. As another user, they need `sudo` (or `doas`) without a password, or dejavu answers "needs the user".
- Don't run `sudo dejavu`: it would put files owned by root in your home folder. dejavu stops if you try.

### Why not just ...?

- **Homebrew**: needs admin rights to install on Linux, and does not run as root.
- **apt, dnf, ...**: every Linux has another one, with other names and often old versions. And they always need admin rights.
- **mise**: does not install system packages, like `nginx` or `build-essential`.
- **Nix**: powerful, but a big install and a lot to learn.

dejavu uses mise first, and the system package manager for the rest.

### Test

`tests/test.sh` installs and removes real packages, so run it only in a throwaway container:

```bash
docker run --rm -v "$PWD:/src:ro" debian:13-slim sh /src/tests/test.sh
```

[GitHub](.github/workflows/test.yml) runs it on Debian, Ubuntu, Fedora, Rocky Linux, Alpine, openSUSE, Arch and macOS, and again every Monday. See [CONTRIBUTING.md](CONTRIBUTING.md) to help.

## License

[MIT](LICENSE)
