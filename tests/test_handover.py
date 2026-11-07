"""Quick tests of handover.py's own logic: no ansibro, no tools, no files outside a temp folder.

    python3 -m unittest discover -s tests -p 'test_*.py'
"""

import os
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "skills", "dejavu", "scripts"))
import handover as h  # noqa: E402


class Words(unittest.TestCase):
    def test_terbilang(self):
        for n, want in ((1, "satu"), (11, "sebelas"), (12, "dua belas"), (20, "dua puluh"), (21, "dua puluh satu"),
                        (100, "seratus"), (111, "seratus sebelas"), (1000, "seribu"),
                        (2026, "dua ribu dua puluh enam"), (9999, "sembilan ribu sembilan ratus sembilan puluh sembilan")):
            self.assertEqual(h.terbilang(n), want)

    def test_words_en(self):
        self.assertEqual(h.words_en(2), "two")
        self.assertEqual(h.words_en(21), "twenty-one")
        self.assertEqual(h.words_en(2026), "two thousand twenty-six")

    def test_dates(self):
        self.assertEqual(h.date_long("2026-11-04", "id"), "4 November 2026")
        self.assertEqual(h.date_long("2026-11-04", "en"), "Wednesday, 4 November 2026")
        self.assertEqual(h.date_words("2026-11-04", "id"),
                         "Rabu, tanggal empat bulan November tahun dua ribu dua puluh enam")
        self.assertEqual([h.jinja_env("id").filters["roman"](f"2026-{m:02d}-01") for m in (1, 4, 9, 12)],
                         ["I", "IV", "IX", "XII"])

    def test_numbers(self):
        self.assertEqual(h.number(1234567, "id"), "1.234.567")
        self.assertEqual(h.number(1234567, "en"), "1,234,567")


class Text(unittest.TestCase):
    def test_md_escape(self):
        self.assertEqual(h.md_escape("a *b* #c <d> $e"), r"a \*b\* \#c \<d\> \$e")
        self.assertEqual(h.md_escape(None), "")

    def test_slug(self):
        self.assertEqual(h.slugify("PT Maju Bersama!"), "pt-maju-bersama")
        self.assertEqual(h.slugify("***"), "client")

    def test_q_is_valid_yaml(self):
        q = h.jinja_env("en").filters["q"]
        import yaml
        for text in ('He said "hi": yes', "a: b # c", "- list", None):
            self.assertEqual(yaml.safe_load(f"k: {q(text)}")["k"], "" if text is None else text)


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
        """Every app and secret text has both languages; every entry names a known secret."""
        data = h.load_yaml(os.path.join(h.ASSETS, "apps.yml"))
        for name, app in data["apps"].items():
            self.assertEqual(set(app["about"]), {"id", "en"}, name)
            for note in app["notes"]:
                self.assertEqual(set(note) - {"when"}, {"id", "en"}, name)
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
            self.assertEqual(set(c["about"]), {"id", "en"})


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
            return h.load_answers(tmp)

    def test_unknown_key_is_an_error(self):
        with self.assertRaises(h.Stop) as e:
            self.answers("lang: id\nclinet: {name: x}\n")
        self.assertEqual(e.exception.code, 2)

    def test_lang(self):
        self.assertEqual(self.answers("lang: en\n")["lang"], ["en"])
        self.assertEqual(self.answers("lang: [id, en]\n")["lang"], ["id", "en"])
        with self.assertRaises(h.Stop):
            self.answers("lang: fr\n")

    def test_required(self):
        missing = h.missing_required(self.answers("lang: id\nclient: {name: X}\n"))
        self.assertIn("bast.number", missing)
        self.assertNotIn("client.name", missing)

    def test_example_is_valid(self):
        with open(os.path.join(h.ASSETS, "handover.example.yml"), encoding="utf-8") as f:
            a = self.answers(f.read().replace("  # SERVERS", "  server1: {public_ip: null}"))
        self.assertEqual(a["lang"], ["id"])


if __name__ == "__main__":
    unittest.main()
