# Contributing

Thanks for helping. dejavu stays small and simple on purpose: one script that connects package managers that already exist. It never becomes a package manager itself.

## Report a bug

Open an issue with the [Bug report](https://github.com/sgnd/dejavu/issues/new?template=bug-report.yml) form. For a security problem, see [SECURITY.md](SECURITY.md) instead.

## Before you add something

A change fits when all of these are true:

- It helps an AI agent install CLI software on Linux or macOS. (No Windows, no GUI apps.)
- An existing tool can't already do it. dejavu uses mise and the system package manager. It does not copy what they do.
- It keeps `dejavu` one file that runs in plain `sh`, with no extra tools.

## How `dejavu` is built

`dejavu` is one file on purpose: users download one file, `setup` copies it, `upgrade` replaces it. It has seven parts, in this order: Paths; Start, lock and log; The system package manager; mise; Agent skills; Your list; Commands.

What happens on `dejavu install NAME`:

```text
main ── check_name (every name, before anything runs)
     ── start (OS, lock, log, TMP)
     ── install_and_record ── install_one ── system   (system:NAME, servers, names mise does not know)
                           │              ├─ skill    (skill:OWNER/REPO/NAME)
                           │              └─ mise_install (everything else; system if mise fails)
                           │              then report: prints ok / failed / needs the user
                           └─ record (writes the name and version into your list)
     ── finish (summary, exit code 0, 1 or 3)
```

`remove`, `upgrade` and `restore` take the same road, through `remove_one`, `upgrade_one` and `restore`.

**Shared variables.** POSIX `sh` has no local variables, so every variable is shared by all functions. Know these:

| Variable | Set by | Means |
| --- | --- | --- |
| `MSG` | every action function | The text for the result line. `report` prints it. |
| return code | every action function | 0 ok, 1 failed, 3 needs the user. `report` turns it into the line. |
| `LAST` | `report` | The last result, for `main`. |
| `spec` | `install_one`, `remove_one`, `upgrade_one` | The name, lowercased, as it goes on the list. |
| `CMD`, `USER_CMD` | `pm_cmd`, `pm` | The package manager command, and the one to give the user. |
| `PM`, `MISE`, `OS` | `find_pm`, `ensure_mise`, `start` | Which package manager, where mise is, linux or macos. |
| `VER`, `VIA` | `version_of` | An installed package's version, and how it was installed. |
| `FOUND` | `list_without` | The name as written on the list, or empty. |
| `$TMP/step`, `$TMP/fail` | `run` | The last command's output, and the last failure's (shown under `failed:`). |

The rule that prevents most bugs: **a function you call can change any variable.** `mise_install` even calls itself, to install a helper like node first. Copy a value you still need into its own variable before the call (see `why` in `mise_install`).

**Where a change goes:**

- A new package manager: one line per action in `pm_cmd`, and its name in `find_pm`. Nothing else.
- A new error explained in plain words: one `elif` in `hint`.
- A new kind of name (like `skill:`): one case in `install_one`, `remove_one`, `upgrade_one` and `version_of`.

**When one file is too much.** At about 2,000 lines, or when dejavu needs real data structures (resolving versions itself, a cache, a richer list format), plain `sh` stops being simple. Then talk about it in an issue first: split the file and join it in the release, or move to another language.

## Send a pull request

1. Change `dejavu`. If the change is something an agent must know, update `skills/dejavu/SKILL.md` and the README too.
2. Run the checks:

   ```bash
   shellcheck -s sh dejavu tests/test.sh tests/unit.sh
   sh tests/unit.sh   # seconds, safe on your own computer
   docker run --rm -v "$PWD:/src:ro" debian:13-slim sh /src/tests/test.sh   # the last line must say: 0 failed
   ```

   `tests/unit.sh` tests the parts that only work with text (names, your list, versions, hints). Add a test there when you change one of them.
   `tests/test.sh` installs and removes real packages. Run it only in a container, never on your own computer.

3. Open the pull request. [GitHub](.github/workflows/test.yml) runs the same test on Debian, Ubuntu, Fedora, Rocky Linux, Alpine, openSUSE, Arch and macOS. It also runs every Monday, because mise and the package managers change without us.

## Release a version

Every version is a GitHub release, and users only ever get releases. `main` can be ahead of them.

1. Set `VERSION=` in `dejavu`, and add a `## X.Y.Z` section to `CHANGELOG.md` with what changed.
2. Open a pull request with that change, and merge it when the tests pass. `main` only changes through pull requests.
3. Tag the merged `main`, and push the tag:

   ```bash
   git switch main && git pull && git tag vX.Y.Z && git push origin vX.Y.Z
   ```

4. [Release](.github/workflows/release.yml) runs every test again, checks that the version and the changelog match the tag, and publishes the release with `dejavu` and `SKILL.md`. If a test fails, nothing is published: fix it, delete the tag (`git push origin :vX.Y.Z`) and tag again.

## Writing

Keep the words simple and the lines short, like the rest of the repo. Many readers have never used a terminal. Explain a new word in [Words used here](README.md#words-used-here).

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
