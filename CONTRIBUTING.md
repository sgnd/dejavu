# Contributing

Thanks for helping. dejavu stays small and simple on purpose: one script that connects package managers that already exist. It never becomes a package manager itself.

## Report a bug

Open an issue with the [Bug report](https://github.com/sgnd/dejavu/issues/new?template=bug-report.yml) form. For a security problem, see [SECURITY.md](SECURITY.md) instead.

## Before you add something

A change fits when all of these are true:

- It helps an AI agent install CLI software on Linux or macOS. (No Windows, no GUI apps.)
- An existing tool can't already do it. dejavu uses mise and the system package manager. It does not copy what they do.
- It keeps `dejavu` one file that runs in plain `sh`, with no extra tools.

## Send a pull request

1. Change `dejavu`. If the change is something an agent must know, update `skills/dejavu/SKILL.md` and the README too.
2. Run the checks:

   ```bash
   shellcheck -s sh dejavu tests/test.sh
   docker run --rm -v "$PWD:/src:ro" debian:13-slim sh /src/tests/test.sh   # the last line must say: 0 failed
   ```

   `tests/test.sh` installs and removes real packages. Run it only in a container, never on your own computer.

3. Open the pull request. [GitHub](.github/workflows/test.yml) runs the same test on Debian, Ubuntu, Fedora, Rocky Linux, Alpine, openSUSE, Arch and macOS. It also runs every Monday, because mise and the package managers change without us.

## Release a version

Every version is a GitHub release, and users only ever get releases. `main` can be ahead of them.

1. Set `VERSION=` in `dejavu`, and add a `## X.Y.Z` section to `CHANGELOG.md` with what changed.
2. Commit, then push the tag:

   ```bash
   git tag vX.Y.Z && git push origin main vX.Y.Z
   ```

3. [Release](.github/workflows/release.yml) runs every test again, checks that the version and the changelog match the tag, and publishes the release with `dejavu` and `SKILL.md`. If a test fails, nothing is published: fix it, delete the tag (`git push origin :vX.Y.Z`) and tag again.

## Writing

Keep the words simple and the lines short, like the rest of the repo. Many readers have never used a terminal. Explain a new word in [Words used here](README.md#words-used-here).

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
