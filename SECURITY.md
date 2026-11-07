# Security

dejavu reads the passwords of a whole server system and puts them in a file for a client, and AI agents run it. So security problems matter here.

## Report a problem

Please don't open a public issue for a security problem. Report it privately instead:

1. Open the [Security tab](https://github.com/sgnd/dejavu/security) of this repo.
2. Click **Report a vulnerability**.

You get an answer within a week. Once it is fixed, a new release says what changed. Never attach a real `.kdbx` file, `state/`, a `handover.yml` or generated documents of a real client.

## What counts

- A way for a password, key or token to reach a document, a diagram, `facts.json`, the screen, a log, a command line, or the AI agent's conversation.
- A way for the leak check to miss a secret value.
- A way to make dejavu write into ansibro's `state/` other than its own passphrase file, or leave `state.age` open.
- A way for the credentials file to hold a wrong value, or to be readable without its passphrase.
- Instructions in `SKILL.md` that would lead an agent to read or send a secret.

A security problem in ansibro, KeePassXC, pandoc, Typst or d2 belongs to that project. Report it there.

## How dejavu keeps the passwords safe

- Secret values are read into memory only, to build the credentials file and to search the output for leaks. They go to `keepassxc-cli` on its standard input, never on a command line. Two exceptions, both while the credentials file is built:
  - An S3 access key ID (RustFS, Garage) is the entry's username, and `keepassxc-cli` takes the username only as a command-line argument. So for a moment other users of the same computer can see it in the process list. The secret key that goes with it stays on standard input.
  - An attached file (the installer archive with `state/`, the client's SSH private key) is written for a moment to a new private temp folder (mode 0700, the file 0600), because `keepassxc-cli attachment-import` reads a file. It is deleted right after, unless dejavu is killed in between.
- Every build searches every generated text file and `handover.yml` for every secret value (and forms derived from them) and for secret-looking patterns. On a hit it stops, deletes the files of that run, and names the secret, never its value.
- The documents are built from an allow-list of facts. A setting dejavu does not know is left out.
- With `state.age`, dejavu reads the passwords from the encrypted file straight into memory. It writes only its own passphrase file, through ansibro's `scripts/state.sh`, and closes it again.
- The passphrase is shown only in a real terminal, so it never reaches an AI agent or a log. It must travel to the client on another channel than the file.
- The output folder is refused inside a git repository, so the credentials file is never committed.
- `doctor --fix` installs mise, when it is missing, with mise's official installer from `https://mise.run` over HTTPS, without a checksum of its own. It runs only after the user agreed, and needs no admin rights.

## Supported versions

Only the newest release gets fixes. `install.sh` always installs the newest release, never `main`.
