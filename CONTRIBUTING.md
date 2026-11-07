# Contributing

Thanks for helping. dejavu stays small and simple on purpose: it writes the handover documents for a system that [ansibro](https://github.com/sgnd/ansibro) built, from ansibro's own facts, with tools that already exist (pandoc, Typst, d2, KeePassXC). It never becomes a documentation tool for everything.

## Report a bug

Open an issue with the [Bug report](https://github.com/sgnd/dejavu/issues/new?template=bug-report.yml) form. Never paste a password, the `.kdbx` file, `state/` or a real `facts.json` of a client. For a security problem, see [SECURITY.md](SECURITY.md) instead.

## Before you add something

A change fits when all of these are true:

- It helps hand an ansibro system over to a client: the handover certificate, the technical documentation, the laptop guides or the credentials file.
- The fact comes from ansibro (its files, its code, or `apps.yml` when ansibro has no machine-readable form). dejavu never guesses a fact.
- No secret value can reach a document. The leak check must still pass.
- It keeps one script, plain templates, and no new tools.

## How it is built

```text
handover.py build
  facts      ansibro's inventory.py --list, state/handover.json (ansibro newer than 1.2; else one ansible
             debug call for the group_vars rules, no SSH),
             alerts.yml, CHANGELOG.md, state/secrets names  +  assets/apps.yml   -> facts.json
  render     assets/*.md.j2 with facts.json + handover.yml (the answers)          -> dist/*.md
  scan       every secret value and pattern searched in every text file           (stops with exit 5)
  vault      keepassxc-cli, values on its stdin only                              -> dist/*.kdbx
  pdf        d2 -> SVG, pandoc (assets/handover.typst) -> Typst -> PDF/A          -> dist/*.pdf
  certificate rendered last, with the SHA-256 of every other file                 -> SHA256SUMS
```

| File | Its job |
| --- | --- |
| `skills/dejavu/scripts/handover.py` | The only program. Sections: output, ansibro (facts and state/), facts, answers, words and dates, rendering, the leak gate, tools, the credentials file, commands. |
| `skills/dejavu/assets/apps.yml` | What ansibro has in no machine-readable form: what each app is for, its pages and who can open them, ports, data, backup, and every password file with how to change it. |
| `skills/dejavu/assets/*.md.j2` | One template per document: the handover certificate, the technical documentation (with `laptop.md.j2` as its chapter 5), the laptop guide and the README. All documents are in English. |
| `skills/dejavu/assets/handover.typst` | The page layout (pandoc template for Typst): cover, letterhead, header and footer, tables, signatures. No words in any language. |
| `tests/fixtures/<case>/` | Test systems: a `config.yml`, the names of its password files, the answers, and what ansibro said about it (`inventory.json`, `groupvars.json`, made by `tests/record.py`). |
| `tests/golden/<case>/` | The expected documents. A change in a template shows up as a diff here. |

**Rules that prevent most bugs:**

- A fact ansibro has is read from ansibro, never written in dejavu. When ansibro has it only in prose, it goes into `apps.yml`, and `tests/drift.py` checks it against ansibro.
- Templates get the facts and the answers, never a secret value. Text typed by the user goes through the `md` filter; front-matter values through `q`.
- The documents are in English only, for clients anywhere. Use plain international English, and no terms or practices of one country.

## Check your change

The tests need keepassxc-cli, mise and an ansibro checkout. The easiest way is a throwaway container (the repo and ansibro mounted read-only):

```bash
git clone --branch v1.2.0 https://github.com/sgnd/ansibro.git .test-ansibro
docker run --rm -v "$PWD:/src:ro" -v "$PWD/.test-ansibro:/ansibro:ro" debian:13-slim sh /src/tests/test.sh --install
```

The last line must say `0 failed`. The quick tests alone need only Python with PyYAML and Jinja2:

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
```

When you changed a template on purpose, write the expected documents again and review the diff:

```bash
docker run --rm -e UPDATE=1 -v "$PWD:/src" -v "$PWD/.test-ansibro:/ansibro:ro" debian:13-slim sh /src/tests/test.sh --install
git diff tests/golden
```

When ansibro changes (a new release): record the test systems again with its Python, run `tests/drift.py`, and update `apps.yml` and the `ansibro` range in SKILL.md:

```bash
.test-ansibro/.venv/bin/python tests/record.py .test-ansibro
python3 tests/drift.py .test-ansibro
```

[GitHub](.github/workflows/test.yml) runs the tests on Debian 13 and Ubuntu 24.04 (Intel/AMD and ARM) and on macOS, for every pull request and every Monday.

## Send a pull request

1. Change the code, the templates or `apps.yml`. When an agent must know about it, update `SKILL.md` and its references too.
2. Run the checks above.
3. Open the pull request. `main` only changes through pull requests, and the tests must pass.

## Release a version

Every version is a GitHub release, and users only ever get releases. `main` can be ahead of them.

1. Set `metadata.version` in `skills/dejavu/SKILL.md`, and add a `## X.Y.Z` section to `CHANGELOG.md`.
2. Open a pull request with that change, and merge it when the tests pass.
3. Tag the merged `main`, and push the tag:

   ```bash
   git switch main && git pull && git tag vX.Y.Z && git push origin vX.Y.Z
   ```

4. [Release](.github/workflows/release.yml) runs every test again, checks that the version and the changelog match the tag, and publishes `dejavu-skill.tar.gz`, `SHA256SUMS`, `install.sh` and sample PDFs. If a test fails, nothing is published: fix it, delete the tag (`git push origin :vX.Y.Z`) and tag again.

Before a release, once by hand: build the pack for a real test cluster with an agent, open the PDFs and the `.kdbx` on Windows and macOS, follow one laptop guide word for word, and print the handover certificate once.

## Writing

Keep the words simple and the sentences short. Many readers of the documents have never used a terminal. Explain a new word the first time, and in the glossary.

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
