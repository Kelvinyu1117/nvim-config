"""Offline startup/installer regressions. Run: python3 tests/startup.py (Neovim 0.12+)."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent


class StartupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        (self.repo / ".git").mkdir()
        (self.repo / "nvim").mkdir()
        shutil.copy(ROOT / "install.sh", self.repo)
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        # Avoid fetching during installer tests; use the real Neovim executable.
        git = bin_dir / "git"
        git.write_text("#!/bin/sh\nexit 0\n")
        git.chmod(0o755)
        self.env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ["PATH"])
        for kind in ("CONFIG", "DATA", "STATE", "CACHE"):
            self.env[f"XDG_{kind}_HOME"] = str(self.root / kind.lower())

    def run_install(self, init, locked=False):
        (self.repo / "nvim/init.lua").write_text(init)
        if locked:
            (self.repo / "nvim/lazy-lock.json").write_text("{}")
        return subprocess.run(
            ["sh", str(self.repo / "install.sh")], env=self.env,
            capture_output=True, text=True, timeout=20,
        )

    def test_options_load(self):
        # Load the actual options with Neovim, rather than mocking vim.opt.
        result = subprocess.run(
            ["nvim", "--headless", "-u", "NONE", "-i", "NONE", "-l", "-"],
            input=f'dofile({str(ROOT / "nvim/lua/config/options.lua")!r})',
            env=self.env, capture_output=True, text=True, timeout=20,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_install_actions(self):
        for locked, action in ((False, "sync"), (True, "restore")):
            with self.subTest(action=action):
                result = self.run_install(
                    'vim.api.nvim_create_user_command("Lazy", function(opts) '
                    'assert(opts.bang); print("ACTION:" .. opts.args) end, '
                    '{bang=true, nargs="+"})', locked=locked,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn("ACTION:" + action, result.stderr)
                self.assertIn("Done. Next steps:", result.stdout)

    def test_startup_error_stops_install(self):
        result = self.run_install('vim.opt.fillchars = { foldclose = "" }')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E1511", result.stderr)
        self.assertNotIn("Done. Next steps:", result.stdout)
        self.assertNotIn("Not an editor command", result.stderr)

    def test_missing_lazy_stops_install(self):
        result = self.run_install("")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E492", result.stderr)
        self.assertNotIn("Done. Next steps:", result.stdout)


if __name__ == "__main__":
    unittest.main()
