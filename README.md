# dejavu

[![Test](https://github.com/sgnd/dejavu/actions/workflows/test.yml/badge.svg)](https://github.com/sgnd/dejavu/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Hand a server system over to your client, with every document they need, in one go.

You built a system for a client with [ansibro](https://github.com/sgnd/ansibro). Now you hand it over. Ask your [AI agent](#words-used-here):

> Buatkan dokumen serah terima untuk sistem ansibro ini.
>
> Make the handover documents for this ansibro system.

and you get:

- **The BAST** (Berita Acara Serah Terima; in English, the Handover and Acceptance Certificate), ready to print and sign. It has an acceptance checklist, the list of accounts, and the list of delivered files with their fingerprints (SHA-256).
- **The technical documentation**: what was built, every server and app, how to change each password, backup and restore, monitoring and alerts, what to do when something breaks, and who to call.
- **A laptop guide** for each kind of laptop the client's staff use (Windows, Mac, Linux): how to open the admin pages, log in with SSH, and reach the databases.
- **One locked file with every password** (a KeePassXC file). The documents themselves never contain a password.

In Indonesian, English, or both. As PDF, to send and sign, and as Markdown, to keep.

See an example: the sample PDFs on the [latest release](https://github.com/sgnd/dejavu/releases/latest) (made from a test system with fake data).

## How it works

dejavu is a [skill](#words-used-here): instructions and a small program that your AI agent uses. It does not invent anything:

- **The facts come from ansibro itself**: its settings, its own code and its own list of apps. So the server names, addresses, apps, versions and the backup plan in the documents are the ones that were installed.
- **What ansibro cannot know, the agent asks you**: the client's name, who signs, the BAST number, how the passwords travel. Your answers go into one file, `handover.yml`.
- **The passwords never reach a document or the agent.** dejavu puts them straight into the locked file. Before anything is saved, it searches every document for every password; if it finds one, it stops.

It uses tools that already exist: [pandoc](https://pandoc.org) and [Typst](https://typst.app) make the PDFs, [d2](https://d2lang.com) draws the diagrams, and [KeePassXC](https://keepassxc.org) makes the locked file.

## Requirements

- The computer that installed the system with ansibro (macOS or Linux), and the ansibro folder on it. That folder holds the passwords, in `state/`.
- ansibro 1.2 or 1.3. It is tested with the 1.2 release and with ansibro main (the coming 1.3); with a newer ansibro dejavu warns `ansibro-untested-version`, and the documents are still made.
- An AI agent: Claude Code, Codex, Gemini CLI or another one that reads skills.
- [KeePassXC](https://keepassxc.org/download/) and [mise](https://mise.jdx.dev). When they are missing, the agent asks, then installs what needs no admin rights: mise in your home folder (it downloads pandoc, Typst and d2), and on a Mac with Homebrew also KeePassXC. On Linux, it gives you the command for KeePassXC (it needs your password).
- With encrypted state (`state.age`), also [age](https://github.com/FiloSottile/age). On a Mac with Homebrew the agent installs it too.

## Install

Paste this into a [terminal](#words-used-here):

```bash
curl -fsSL https://github.com/sgnd/dejavu/releases/latest/download/install.sh | sh
```

It downloads the newest release, checks it, and adds the skill to every AI agent on your computer. Run it again to update. You can also ask your agent to run the install command above.

### Update and remove

- **Update:** run the install command again. It replaces the skill with the newest release.
- **Remove:** delete the `skills/dejavu` folder of each agent that has it: `~/.claude/skills/dejavu`, `~/.codex/skills/dejavu`, `~/.gemini/skills/dejavu`, `~/.config/agents/skills/dejavu` and `~/.agents/skills/dejavu` (under `$CLAUDE_CONFIG_DIR` or `$CODEX_HOME` when you set them).
- Removing the skill leaves the ansibro folder alone. Keep `state/handover/` there: it holds the passphrase of the credentials files you delivered (and the client's SSH key with `ssh_handover: generated`). Without it, the next handover gets a new passphrase.

## Use

1. Open your AI agent in the ansibro folder, and ask for the handover documents (see the top of this page).
2. The agent checks your computer, then asks you some questions: the language, the client, who signs, the BAST number, which laptops the client's staff use, and how you will hand over the passwords. Answer what you know; "I don't know yet" is fine.
3. It shows you what it found, for example "the admin pages are open to anyone" or "there is no backup". For each one you decide: fix it now, or write it down as a known issue.
4. It can run ansibro's own test of every app first. It asks before it does: the test connects to your servers, but changes nothing.
5. It makes a draft. Read it, correct what is wrong (tell the agent), and it makes the final version.

Everything ends up in one folder, `~/Handover/<domain>-config/dist/` by default.

When something stops, every message has an id, and [the troubleshooting guide](skills/dejavu/references/troubleshooting.md) says what it means and what to do.

## Hand it over

1. **Send the PDFs** by email or a shared folder.
2. **Give the locked file** (`.kdbx`) on another way: for example on a USB stick, in person.
3. **Say its passphrase** (7 words) by phone or in person to the person named in the BAST, never in the same message as the file. You read it in your own terminal; the agent tells you the command. The agent never sees it.
4. **Print the BAST**, go through its acceptance checklist (Annex 1) together with the client, and sign.
5. The client changes every password within the agreed days. The technical documentation says how for each one.

## Safety

- No password, key or token is ever in a document, a diagram or `handover.yml`. Every build searches all of them, and stops and deletes its files when it finds one.
- Passwords go only into the locked file. They never appear on screen or in the agent's conversation.
- The output folder must be outside any git repository, so the locked file is never committed by mistake.
- When ansibro keeps its passwords encrypted (`state.age`), dejavu reads them into memory, and keeps the passphrase there too. Only `check` opens `state/` on disk while ansibro's test runs, and closes it again.

See [SECURITY.md](SECURITY.md) to report a problem.

## Words used here

- **AI agent**: an AI assistant that can run commands on your computer for you, like Claude Code, Codex or Gemini CLI.
- **Skill**: a folder of instructions that teaches an AI agent a task. The agent reads it when the task comes up.
- **ansibro**: the tool that set up the servers and apps. dejavu reads what it did.
- **BAST**: Berita Acara Serah Terima, the signed record that a job was handed over and received.
- **Terminal**: the window where you type commands. On a Mac: the Terminal app. On Windows: PowerShell. On Linux: Terminal or a similar app.
- **SSH**: a safe way to log in to a server from your laptop, with a key file instead of a password.
- **KeePassXC**: a free program that keeps passwords in one locked file (`.kdbx`). It runs on Windows, Mac and Linux.
- **Passphrase**: the words that open the locked file.
- **SHA-256**: a fingerprint of a file. When the fingerprint matches the one in the BAST, the file is exactly the one that was handed over.

## Details

For developers and the curious. How the code is built, and how to test it: [CONTRIBUTING.md](CONTRIBUTING.md). The full instructions for agents: [`skills/dejavu/SKILL.md`](skills/dejavu/SKILL.md).

| File | What it is |
| --- | --- |
| `skills/dejavu/SKILL.md` | What the agent does, step by step, and what it must never do. |
| `skills/dejavu/scripts/handover.py` | The program: reads the facts, writes the documents, makes the locked file and the PDFs. |
| `skills/dejavu/assets/` | The document templates (Indonesian and English), the page layout, and `apps.yml`: what dejavu knows about each ansibro app. |
| `skills/dejavu/references/` | The interview questions, and every message with its fix. |
| `install.sh` | The installer. |
| `tests/` | The tests: five test systems with fake passwords. |

## Before 1.0: a package manager

Versions 0.1.0 to 0.3.1 of dejavu were a different tool: a package manager for AI agents. It is retired. Version 0.3.1 keeps working, and its [release](https://github.com/sgnd/dejavu/releases/tag/v0.3.1) and code stay available. To remove it:

- The tools it installed stay. Manage them with `mise` (`mise ls`, `mise upgrade`) or your system's package manager.
- Delete `~/.local/bin/dejavu`. Running `install.sh` above replaces its old skill with the new one.
- In `~/.profile`, `~/.bashrc`, `~/.zprofile` and `~/.zshrc`, the lines ending in `# added by dejavu` put mise's tools in your PATH. Keep them if you still use those tools.
- Optionally delete `~/.config/dejavu` (the old list of installed tools).

## License

[MIT](LICENSE). Changes: [CHANGELOG.md](CHANGELOG.md).
