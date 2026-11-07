"""Quick tests of handover.py's own logic: no ansibro, no tools, no files outside a temp folder.

    python3 -m unittest discover -s tests -p 'test_*.py'
"""

import contextlib
import io
import os
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "skills", "dejavu", "scripts"))
import handover as h  # noqa: E402


class Words(unittest.TestCase):
    def test_words(self):
        self.assertEqual(h.words(2), "two")
        self.assertEqual(h.words(21), "twenty-one")
        self.assertEqual(h.words(111), "one hundred and eleven")
        self.assertEqual(h.words(2026), "two thousand twenty-six")

    def test_dates(self):
        self.assertEqual(h.date_long("2026-11-04"), "Wednesday, 4 November 2026")
        self.assertIsNone(h.date_long(None))
        self.assertEqual(h.jinja_env().filters["adddays"]("2026-11-04", 30), "2026-12-04")

    def test_numbers(self):
        self.assertEqual(h.jinja_env().filters["num"](1234567), "1,234,567")


class Text(unittest.TestCase):
    def test_md_escape(self):
        self.assertEqual(h.md_escape("a *b* #c <d> $e"), r"a \*b\* \#c \<d\> \$e")
        self.assertEqual(h.md_escape(None), "")

    def test_slug(self):
        self.assertEqual(h.slugify("Northwind Logistics Ltd!"), "northwind-logistics-ltd")
        self.assertEqual(h.slugify("***"), "client")

    def test_q_is_valid_yaml(self):
        q = h.jinja_env().filters["q"]
        import yaml
        for text in ('He said "hi": yes', "a: b # c", "- list", None):
            self.assertEqual(yaml.safe_load(f"k: {q(text)}")["k"], "" if text is None else text)


class Ansibro13(unittest.TestCase):
    """What changed in ansibro 1.3 (main) that dejavu must know."""

    def test_cache_alert_names_the_cache_app(self):
        with tempfile.TemporaryDirectory() as d:
            os.makedirs(os.path.join(d, "roles", "observability", "files"))
            with open(os.path.join(d, "roles", "observability", "files", "alerts.yml"), "w") as f:
                f.write("groups:\n- name: databases\n  rules:\n  - alert: CacheNoPrimary\n"
                        "    expr: count by (job) (redis_instance_info) > 1\n    labels: {severity: critical}\n"
                        "    annotations:\n      summary: >-\n        No {{ $labels.job }} server is the primary."
                        " Check: sudo docker exec {{ $labels.job }}-sentinel {{ $labels.job }}-cli\n"
                        "  - alert: DiskFull\n    expr: x\n    labels: {severity: warning}\n"
                        "    annotations: {summary: \"{{ $labels.instance }} is full\"}\n")
            ab = h.Ansibro(d, "config.yml")
            f = {"orchestrator": "swarm", "backup": {"enabled": False}, "wireguard": False}
            gv = {"monitoring_app": "victoria", "cache_app": "valkey"}
            alerts = {a["name"]: a["summary"] for a in h.read_alerts(ab, {"valkey": "swarm"}, gv, f)}
        self.assertEqual(alerts["CacheNoPrimary"],
                         "No valkey server is the primary. Check: sudo docker exec valkey-sentinel valkey-cli")
        self.assertEqual(alerts["DiskFull"], "<instance> is full")  # other labels stay placeholders

    def test_kong_admin_key_is_optional_and_swarm_note(self):
        data = h.load_yaml(os.path.join(h.ASSETS, "apps.yml"))
        self.assertEqual(data["secrets"]["kong_admin_key"]["when"], "optional")  # ansibro 1.2 has none
        f = {"app_names": [], "gv": {}, "admin_sso": "", "backup": {"enabled": False}, "wireguard": False}
        self.assertTrue(h.matches("swarm", {**f, "orchestrator": "swarm"}))
        self.assertFalse(h.matches("swarm", {**f, "orchestrator": "k3s"}))
        self.assertIn("swarm", [n.get("when") for n in data["apps"]["kong"]["notes"]])


class Facts(unittest.TestCase):
    def test_repository_keeps_no_password(self):
        r = h.redact_repository("rest:https://user:s3cretpass@backup.example.com:8000/apps")
        self.assertEqual(r["kind"], "rest")
        self.assertEqual(r["host"], "backup.example.com")
        self.assertNotIn("s3cretpass", str(r))
        self.assertNotIn("user", r["where"])
        self.assertEqual(h.redact_repository("/mnt/backup")["kind"], "local")
        self.assertEqual(h.redact_repository("s3:https://s3.example.com/bucket")["host"], "s3.example.com")

    def test_webhook_kind(self):
        self.assertEqual(h.webhook_kind("https://hooks.slack.com/services/x"), "slack")
        self.assertEqual(h.webhook_kind("https://discord.com/api/webhooks/x"), "discord")
        self.assertEqual(h.webhook_kind("https://example.com/hook"), "webhook")

    def test_handover_json_mismatch(self):
        inv = {"_meta": {"hostvars": {"srv": {}, "db": {}}}, "all": {"vars": {"apps": {"postgres": "db"}}}}
        hj = {**dict.fromkeys(h.Ansibro.GV_NAMES), "nodes": [{"name": "db"}, {"name": "srv"}],
              "apps": {"postgres": {}}}
        self.assertIsNone(h.handover_json_mismatch(hj, inv))
        self.assertEqual(h.handover_json_mismatch({**hj, "apps": {}}, inv), "other apps than config")
        self.assertEqual(h.handover_json_mismatch({**hj, "nodes": [{"name": "srv"}]}, inv), "other servers than config")
        self.assertEqual(h.handover_json_mismatch({"_invalid": True}, inv), "not valid JSON")
        broken = dict(hj)
        del broken["admin_sso"]
        self.assertEqual(h.handover_json_mismatch(broken, inv), "missing admin_sso")
        # A wrong form is a reason, never a crash.
        for bad in ({"nodes": None}, {"nodes": ["srv", "db"]}, {"nodes": [{"name": "db"}, {}]}, {"apps": [{"x": 1}]}):
            self.assertEqual(h.handover_json_mismatch({**hj, **bad}, inv), "nodes or apps in an unknown form")
        # The same names, other settings.
        inv2 = {"_meta": {"hostvars": {"srv": {"node_ip": "10.0.0.1"}, "db": {"node_ip": "10.0.0.2"}}},
                "all": {"vars": {"apps": {"postgres": "swarm"}, "app_nodes": {"postgres": ["db"]}, "tls": "acme"}}}
        ok = {**hj, "tls": "acme", "nodes": [{"name": "db", "ip": "10.0.0.2"}, {"name": "srv", "ip": "10.0.0.1"}],
              "apps": {"postgres": {"nodes": ["db"]}}}
        self.assertIsNone(h.handover_json_mismatch(ok, inv2))
        self.assertEqual(h.handover_json_mismatch({**ok, "tls": "selfsigned"}, inv2), "other tls than config")
        self.assertEqual(h.handover_json_mismatch({**ok, "nodes": [{"name": "db", "ip": "10.0.0.9"}, {"name": "srv"}]},
                                                  inv2), "server db: other ip than config")
        self.assertEqual(h.handover_json_mismatch({**ok, "apps": {"postgres": {"nodes": ["db", "srv"]}}}, inv2),
                         "postgres: other servers than config")

    def test_version_range(self):
        self.assertTrue(h.in_range("1.2.0", ">=1.2.0 <2"))
        self.assertTrue(h.in_range("1.9.3", ">=1.2.0 <2"))
        self.assertFalse(h.in_range("1.1.9", ">=1.2.0 <2"))
        self.assertFalse(h.in_range("2.0.0", ">=1.2.0 <2"))

    def test_allow_lists(self):
        self.assertTrue(h.contains_ip([], "198.51.100.7"))  # empty: open to anyone
        self.assertTrue(h.contains_ip(["198.51.100.0/24"], "198.51.100.7"))
        self.assertFalse(h.contains_ip(["198.51.100.0/24"], "203.0.113.5"))
        self.assertFalse(h.contains_ip(["198.51.100.0/24"], "not-an-ip"))

    def test_apps_yml_is_complete(self):
        """Every app has its texts; every entry names a known secret."""
        data = h.load_yaml(os.path.join(h.ASSETS, "apps.yml"))
        for name, app in data["apps"].items():
            self.assertIsInstance(app["about"], str, name)
            for note in app["notes"]:
                self.assertEqual(set(note) - {"when"}, {"text"}, name)
                self.assertIsInstance(note["text"], str, name)
            for w in app["web"]:
                self.assertIn(w["guard"], ("admin", "admin-ip", "public"), name)
                self.assertIn(w["login"], ("own", "layer", "none"), name)
        for name, s in data["secrets"].items():
            self.assertIn(s["change"], ("file", "both", "app", "internal"), name)
            self.assertIn(s["audience"], ("client", "recovery", "internal"), name)
        for e in data["entries"]:
            self.assertIn(e["secret"], data["secrets"])
            self.assertIn(e["group"], data["groups"])
        for c in data["components"].values():
            self.assertIsInstance(c["about"], str)
        for title in data["groups"].values():
            self.assertIsInstance(title, str)


class LeakGate(unittest.TestCase):
    def scan(self, text, needles=None):
        with tempfile.TemporaryDirectory() as tmp:
            p = os.path.join(tmp, "doc.md")
            with open(p, "w", encoding="utf-8") as f:
                f.write(text)
            return [(no, name) for _p, no, name in h.scan([p], needles or {})]

    def test_values_are_found_by_name(self):
        hits = self.scan("line one\nthe value is Zq81xTTx0 here\n", {"postgres": "Zq81xTTx0"})
        self.assertEqual(hits, [(2, "postgres")])

    def test_patterns(self):
        for text in ("-----BEGIN OPENSSH PRIVATE KEY-----", "https://user:pw@host/x", "client-key-data: abc",
                     "https://hooks.slack.com/services/T/B/x", "https://discord.com/api/webhooks/1/x",
                     "https://api.telegram.org/bot123:abc"):
            self.assertTrue(self.scan(text), text)
        self.assertFalse(self.scan("https://example.com/path and user@example.com"))

    def test_report_never_has_the_value(self):
        hits = self.scan("Zq81xTTx0", {"postgres": "Zq81xTTx0"})
        self.assertNotIn("Zq81xTTx0", str(hits))


class Answers(unittest.TestCase):
    def answers(self, text):
        with tempfile.TemporaryDirectory() as tmp:
            with open(os.path.join(tmp, "handover.yml"), "w", encoding="utf-8") as f:
                f.write(text)
            self.said = io.StringIO()
            with contextlib.redirect_stdout(self.said):
                return h.load_answers(tmp)

    def test_unknown_key_is_an_error(self):
        with self.assertRaises(h.Stop) as e:
            self.answers("clinet: {name: x}\n")
        self.assertEqual(e.exception.code, 2)

    def test_answers_of_dejavu_1_1_still_work(self):
        """The old lang: is ignored, and the old bast: section is read as certificate:."""
        a = self.answers("lang: [id, en]\nbast: {number: HC-1, mengetahui: [{name: Ann}], meterai: {enabled: true}}\n")
        self.assertNotIn("lang", a)
        self.assertNotIn("bast", a)
        self.assertEqual(a["certificate"]["number"], "HC-1")
        self.assertEqual(a["certificate"]["acknowledged_by"], [{"name": "Ann"}])
        self.assertNotIn("meterai", a["certificate"])
        self.assertNotIn("mengetahui", a["certificate"])
        self.assertIn("warning [lang]", self.said.getvalue())
        self.assertIn("warning [answers-renamed]", self.said.getvalue())
        self.answers("lang: en\ncertificate: {number: HC-1}\n")  # already English, already renamed: nothing to say
        self.assertEqual(self.said.getvalue(), "")

    def test_required(self):
        missing = h.missing_required(self.answers("client: {name: X}\n"))
        self.assertIn("certificate.number", missing)
        self.assertNotIn("client.name", missing)

    def test_bad_yaml_is_an_answers_error(self):
        for text in ("client: [\n", "- just\n- a list\n", "people:\n  - alice\n", "people: alice\n"):
            with self.assertRaises(h.Stop) as e:
                self.answers(text)
            self.assertEqual(e.exception.code, 2, text)

    def test_example_is_valid(self):
        with open(os.path.join(h.ASSETS, "handover.example.yml"), encoding="utf-8") as f:
            a = self.answers(f.read().replace("  # SERVERS", "  server1: {public_ip: null}"))
        self.assertEqual(a["certificate"]["first_party"], "vendor")
        self.assertEqual(self.said.getvalue(), "")


class Doctor(unittest.TestCase):
    """doctor --fix: what it installs by itself, and that it never runs sudo. Every command is faked."""

    def setUp(self):
        self.ran = []
        self.saved = (h.run, h.shutil.which, h.sys.platform, h.find_keepassxc, h.find_tool, h.find_mise,
                      h.Ansibro.check_folder, h.Ansibro.version, h.Ansibro.state_mode,
                      h.MISE_PLACES, h.BREW_PLACES, h.AGE_PLACES, h.KEEPASSXC_APP)
        self.kp = None  # keepassxc-cli path once "installed"

        def run(cmd, **kw):
            self.ran.append(list(cmd))
            if cmd[:3] == ["/opt/homebrew/bin/brew", "install", "--cask"]:
                self.kp = "/Applications/KeePassXC.app/Contents/MacOS/keepassxc-cli"
            return h.subprocess.CompletedProcess(cmd, 0, "", "")

        h.run = run
        h.find_keepassxc = lambda: self.kp
        h.find_tool = lambda name: ["/usr/local/bin/" + name]
        h.find_mise = lambda: None
        h.Ansibro.check_folder = lambda self: None
        h.Ansibro.version = lambda self: {"version": "1.2.0", "describe": None, "dirty": False}
        h.Ansibro.state_mode = lambda self: "plain"
        self.tmp = tempfile.TemporaryDirectory()
        self.ab = h.Ansibro(self.tmp.name, "config.yml")
        # Never this machine's real Homebrew, mise or KeePassXC.
        nowhere = os.path.join(self.tmp.name, "nowhere")
        h.MISE_PLACES, h.BREW_PLACES, h.AGE_PLACES = (nowhere,), (), ()
        h.KEEPASSXC_APP = os.path.join(self.tmp.name, "KeePassXC.app")

    def tearDown(self):
        (h.run, h.shutil.which, h.sys.platform, h.find_keepassxc, h.find_tool, h.find_mise,
         h.Ansibro.check_folder, h.Ansibro.version, h.Ansibro.state_mode,
         h.MISE_PLACES, h.BREW_PLACES, h.AGE_PLACES, h.KEEPASSXC_APP) = self.saved
        self.tmp.cleanup()

    def doctor(self, platform, which, fix=True):
        h.sys.platform = platform
        h.shutil.which = lambda name: which.get(name)
        args = h.argparse.Namespace(fix=fix)
        with self.assertRaises(h.Stop) as stop:
            h.cmd_doctor(self.ab, args, {})
        return stop.exception.code

    def test_mac_with_brew_installs_keepassxc(self):
        self.assertEqual(self.doctor("darwin", {"brew": "/opt/homebrew/bin/brew"}), 0)
        self.assertIn(["/opt/homebrew/bin/brew", "install", "--cask", "keepassxc"], self.ran)

    def test_without_fix_nothing_is_installed(self):
        self.assertEqual(self.doctor("darwin", {"brew": "/opt/homebrew/bin/brew"}, fix=False), 3)
        self.assertEqual(self.ran, [])

    def test_linux_never_runs_sudo(self):
        self.assertEqual(self.doctor("linux", {"sudo": "/usr/bin/sudo", "apt-get": "/usr/bin/apt-get"}), 3)
        self.assertFalse([c for c in self.ran if "sudo" in c[0] or "apt" in c[0] or "dnf" in c[0]], self.ran)

    def test_mac_without_brew_asks_the_user(self):
        self.assertEqual(self.doctor("darwin", {}), 3)
        self.assertEqual(self.ran, [])

    def test_missing_mise_is_installed_in_home(self):
        h.find_tool = lambda name: None
        self.kp = "/usr/bin/keepassxc-cli"
        self.doctor("linux", {"curl": "/usr/bin/curl"})
        self.assertEqual(self.ran[0][0], "/usr/bin/curl")
        self.assertIn("https://mise.run", self.ran[0])
        self.assertEqual(self.ran[1][0], "sh")  # mise's own installer, no sudo

    def fake_tool(self, path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            f.write("#!/bin/sh\n")
        os.chmod(path, 0o755)
        return path

    def test_homebrew_mise_off_path_is_used_not_installed_again(self):
        # brework's mise is in Homebrew's folder, which this shell's PATH lacks.
        brew_mise = self.fake_tool(os.path.join(self.tmp.name, "opt", "homebrew", "bin", "mise"))
        h.MISE_PLACES = (brew_mise, "/usr/local/bin/mise-not-here", "~/.local/bin/mise-not-here")
        h.find_mise = self.saved[5]
        h.find_tool = self.saved[4]
        h.shutil.which = lambda name: None
        self.assertEqual(h.find_mise(), brew_mise)
        self.assertEqual(h.find_tool("pandoc")[:2], [brew_mise, "exec"])
        self.kp = "/usr/bin/keepassxc-cli"
        self.assertEqual(self.doctor("darwin", {}), 0)
        self.assertFalse([c for c in self.ran if "https://mise.run" in c], "a second mise was installed")
        self.assertIn([brew_mise, "install", f"pandoc@{h.TOOLS['pandoc']}"], self.ran)
        # Only `mise install tool@version`: never `mise use`, never global config.
        self.assertFalse([c for c in self.ran if c[0] == brew_mise and c[1] != "install"], self.ran)

    def test_keepassxc_app_present_is_not_installed_again(self):
        os.makedirs(h.KEEPASSXC_APP)  # installed, but its keepassxc-cli is too old (find_keepassxc says None)
        self.assertEqual(self.doctor("darwin", {"brew": "/opt/homebrew/bin/brew"}), 3)
        self.assertFalse([c for c in self.ran if "keepassxc" in c], self.ran)

    def test_homebrew_brew_off_path_is_found(self):
        brew = self.fake_tool(os.path.join(self.tmp.name, "opt", "homebrew", "bin", "brew"))
        h.BREW_PLACES = (brew,)
        h.shutil.which = lambda name: None
        self.assertEqual(h.find_brew(), brew)

    def test_tools_through_mise_are_downloaded_ahead(self):
        h.find_tool = lambda name: ["/home/u/.local/bin/mise", "exec", f"{name}@{h.TOOLS[name]}", "--", name]
        self.kp = "/usr/bin/keepassxc-cli"
        self.assertEqual(self.doctor("linux", {}), 0)
        for name, ver in h.TOOLS.items():
            self.assertIn(["/home/u/.local/bin/mise", "install", f"{name}@{ver}"], self.ran)


class State(unittest.TestCase):
    """state.age with a fake age, and the files dejavu keeps in state/handover/."""

    def setUp(self):
        self.saved = (h.find_age, os.environ.get("ANSIBRO_KEY"))
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = self.tmp.name
        os.environ["ANSIBRO_KEY"] = os.path.join(self.dir, "age.key")
        with open(os.environ["ANSIBRO_KEY"], "w", encoding="utf-8") as f:
            f.write("AGE-SECRET-KEY-TEST\n")

    def tearDown(self):
        h.find_age, key = self.saved
        if key is None:
            os.environ.pop("ANSIBRO_KEY", None)
        else:
            os.environ["ANSIBRO_KEY"] = key
        self.tmp.cleanup()

    def fake_age(self, script):
        age = os.path.join(self.dir, "age")
        with open(age, "w", encoding="utf-8") as f:
            f.write("#!/bin/sh\n" + script + "\n")
        os.chmod(age, 0o755)
        h.find_age = lambda: age
        with open(os.path.join(self.dir, "state.age"), "wb") as f:
            f.write(b"not really encrypted")

    def test_wrong_age_key_is_failed_age(self):
        self.fake_age('echo "age: error: no identity matched any of the recipients" >&2; exit 1')
        with self.assertRaises(h.Stop) as e:
            h.Ansibro(self.dir, "config.yml").secret_names()
        self.assertEqual(e.exception.code, 1)

    def test_not_a_tar_is_failed_age(self):
        self.fake_age("echo garbage")
        with self.assertRaises(h.Stop) as e:
            h.Ansibro(self.dir, "config.yml").secret_names()
        self.assertEqual(e.exception.code, 1)

    def test_handover_file_mode_is_tightened(self):
        d = os.path.join(self.dir, "state", "handover")
        os.makedirs(d)
        path = os.path.join(d, "x.passphrase")
        with open(path, "w", encoding="utf-8") as f:
            f.write("old\n")
        os.chmod(path, 0o644)
        h.Ansibro(self.dir, "config.yml").write_handover_file("x.passphrase", "new")
        self.assertEqual(os.stat(path).st_mode & 0o777, 0o600)


class ServerFacts(unittest.TestCase):
    """check's server details from a faked ansible: a failed run and a bad answer are never a crash."""

    def setUp(self):
        self.saved = (h.run, h.Ansibro.ansible)
        h.Ansibro.ansible = lambda self, why: "ansible"
        self.ab = h.Ansibro(tempfile.gettempdir(), "config.yml")

    def tearDown(self):
        h.run, h.Ansibro.ansible = self.saved

    def facts(self, code, out, err=""):
        h.run = lambda cmd, **kw: h.subprocess.CompletedProcess(cmd, code, out, err)
        return h.server_facts(self.ab)

    def test_ansible_failure_gives_no_servers(self):
        self.assertEqual(self.facts(1, "", "ERROR! the inventory could not be parsed"), {})

    def test_bad_json_is_not_reached(self):
        good = '{"ansible_facts": {"ansible_processor_vcpus": 2, "ansible_memtotal_mb": 2048}}'
        got = self.facts(2, f"server1 | SUCCESS => {good}\nserver2 | SUCCESS => {{not json\n")
        self.assertEqual(got["server1"]["vcpu"], 2)
        self.assertEqual(got["server2"], {"reached": False})

    def test_plural(self):
        self.assertEqual(h.plural(1, "server"), "1 server")
        self.assertEqual(h.plural(3, "server"), "3 servers")


if __name__ == "__main__":
    unittest.main()
