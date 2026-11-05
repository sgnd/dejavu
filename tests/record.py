#!/usr/bin/env python3
"""Record what ansibro says about each test system, so the tests run without ansible.

    <ansibro>/.venv/bin/python tests/record.py <ansibro folder>

For each tests/fixtures/<case>/ it copies ansibro into a temporary folder, adds the case's
config.yml (and certificate), runs ansibro's inventory.py and the group_vars call exactly as
handover.py does, and writes inventory.json and groupvars.json into the case folder.
Paths of the temporary folder are written as @ANSIBRO@.
"""

import json
import os
import shutil
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "skills", "dejavu", "scripts"))
import handover  # noqa: E402


def main(ansibro):
    for case in sorted(os.listdir(os.path.join(HERE, "fixtures"))):
        src = os.path.join(HERE, "fixtures", case)
        with tempfile.TemporaryDirectory() as tmp:
            work = os.path.join(tmp, "ansibro")
            shutil.copytree(ansibro, work, ignore=shutil.ignore_patterns(".git", ".venv", "state", "state.age",
                                                                         "config*.yml", "bundle", "dist"),
                            symlinks=True)
            for f in os.listdir(src):
                if f.endswith((".yml", ".crt")) and f != "handover.yml":
                    shutil.copy(os.path.join(src, f), work)
            ab = handover.Ansibro(work, "config.yml")
            inv = ab.inventory()
            gv = ab.group_vars()
            for name, value in (("inventory.json", inv), ("groupvars.json", gv)):
                text = json.dumps(value, indent=1, sort_keys=True).replace(work, "@ANSIBRO@")
                with open(os.path.join(src, name), "w", encoding="utf-8") as fh:
                    fh.write(text + "\n")
            print(f"ok: recorded {case}")


if __name__ == "__main__":
    main(os.path.abspath(sys.argv[1]))
