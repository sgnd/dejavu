#!/usr/bin/env python3
"""Does dejavu's apps.yml still match ansibro? Fails when ansibro adds or renames something.

    python3 tests/drift.py <ansibro folder>

Checks: every app in catalog.yml is in apps.yml; every password file ansibro writes is in
apps.yml's secrets; every image key in apps.yml is in versions.yml; every web page that
Uptime Kuma watches is a page in apps.yml.
"""

import os
import re
import sys

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
APPS = os.path.join(HERE, "..", "skills", "dejavu", "assets", "apps.yml")
# Written by tasks (not by a password lookup), so the search below cannot see them.
WRITTEN_BY_TASKS = {"authelia_admin", "openbao_unseal_key", "openbao_root_token"}


def load(path):
    with open(path, encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def main(ansibro):
    data = load(APPS)
    problems = []
    catalog = load(os.path.join(ansibro, "catalog.yml"))
    for app in sorted(set(catalog) - set(data["apps"])):
        problems.append(f"catalog.yml has the app {app}, apps.yml does not")
    for app in sorted(set(data["apps"]) - set(catalog)):
        problems.append(f"apps.yml has the app {app}, which ansibro no longer has")

    secrets = set(WRITTEN_BY_TASKS)
    for root, _dirs, files in os.walk(ansibro):
        if "/." in root or root.endswith(("/.git", "/.venv")):
            continue
        for f in files:
            if f.endswith((".yml", ".yaml", ".j2")):
                with open(os.path.join(root, f), encoding="utf-8", errors="replace") as fh:
                    secrets |= set(re.findall(r"secrets_dir\s*~\s*'/([a-z0-9_]+)'", fh.read()))
    for name in sorted(secrets - set(data["secrets"])):
        problems.append(f"ansibro writes state/secrets/{name}, apps.yml does not know it")

    images = load(os.path.join(ansibro, "versions.yml")).get("images", {})
    for app, a in data["apps"].items():
        for key in a["images"]:
            if key not in images:
                problems.append(f"apps.yml: {app} uses image {key}, which versions.yml does not have")

    pages = load(os.path.join(ansibro, "roles", "uptimekuma", "defaults", "main.yml")).get("uptimekuma_pages", {})
    for app, page in pages.items():
        hosts = {w["host"] for w in data["apps"].get(app, {}).get("web", [])}
        if page["host"] not in hosts:
            problems.append(f"Uptime Kuma watches {page['host']} for {app}, apps.yml does not list that page")

    for p in problems:
        print(f"drift: {p}")
    print(f"=== drift: {len(problems)} problems against {ansibro}")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(os.path.abspath(sys.argv[1])))
