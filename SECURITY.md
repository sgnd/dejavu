# Security

dejavu installs software on your computer, and AI agents run it. So security problems matter here.

## Report a problem

Please don't open a public issue for a security problem. Report it privately instead:

1. Open the [Security tab](https://github.com/sgnd/dejavu/security) of this repo.
2. Click **Report a vulnerability**.

You get an answer within a week. Once it is fixed, a new release says what changed.

## What counts

- A way to make `dejavu` do something it should not. For example: run other code than the package manager, change files outside what the README lists, or skip the check on package names.
- A way to make an AI agent install something other than what the user asked for, because of how dejavu or `SKILL.md` works.

A security problem in a tool that dejavu installs, in mise, or in a system package manager belongs to that project. Report it there.

## How dejavu keeps you safe

- It accepts only plain package names, never shell code, options, files or URLs.
- mise checks downloads with a checksum, and a signature, where the tool's source has one. Tools from npm, PyPI, cargo or go come from those registries as they are.
- It never asks for, stores or types your password. When a password is needed, it tells you the command to run yourself.
- It removes only what it installed (what is on your list), unless you name a system package with `system:NAME`.
- It refuses to remove a system package that other packages need.

## Supported versions

Only the newest release gets fixes. Setup and `dejavu upgrade` always download the newest release, never `main`.
