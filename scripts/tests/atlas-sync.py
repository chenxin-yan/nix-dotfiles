#!/usr/bin/env python3
"""Exercise the generated minipc sync wrapper without secrets or network access.

python3 scripts/tests/atlas-sync.py
"""
import os
from pathlib import Path
import re
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
result = subprocess.check_output([
    "nix", "build", "--no-link", "--print-out-paths", "--impure", "--expr",
    "let f = builtins.getFlake (toString ./.); in builtins.head "
    "f.nixosConfigurations.minipc.config.home-manager.users.cyan."
    "systemd.user.services.atlas-sync.Service.ExecStart",
], cwd=root, text=True).strip()
script = Path(result).read_text()
with tempfile.TemporaryDirectory() as tmp:
    directory = Path(tmp)
    (directory / "obsidian-auth-token").write_text("dummy-token")
    (directory / "obsidian-vault-password").write_text("dummy-password")
    ob = directory / "ob"
    ob.write_text('''#!/usr/bin/env bash
set -eu
[ "$OBSIDIAN_AUTH_TOKEN" = dummy-token ]
printf '%s\\n' "$1" >> "$TEST_DIR/calls"
case "$1" in
  sync-status) [ -e "$TEST_DIR/linked" ] || exit 3 ;;
  sync-setup)
    [ "$2" = --vault ] && [ "$3" = atlas ]
    [ "$4" = --path ] && [ "$5" = "$TEST_DIR/vault with spaces" ]
    [ "$6" = --device-name ] && [ "$7" = minipc ]
    [ "$8" = --password ] && [ "$9" = dummy-password ]
    [ "${FAIL_SETUP:-0}" = 0 ] || exit 2
    touch "$TEST_DIR/linked" ;;
  sync) [ "$2" = --path ] && [ "$3" = "$TEST_DIR/vault with spaces" ]
    [ "$4" = --continuous ] ;;
  *) exit 99 ;;
esac
''')
    ob.chmod(0o700)
    script, count = re.subn(r"/nix/store/[^/\s]+/bin/ob", str(ob), script)
    assert count == 3, "Expected status, setup and continuous sync commands"
    script = script.replace("/run/secrets/", tmp + "/")
    script, count = re.subn(r"^vault=.*$", "vault='" + tmp + "/vault with spaces'", script, flags=re.M)
    assert count == 1, "Expected one vault assignment"
    wrapper = directory / "sync"
    wrapper.write_text(script)
    env = dict(os.environ, TEST_DIR=tmp)
    calls = directory / "calls"
    for linked, fail, expected in [
        (False, False, ["sync-status", "sync-setup", "sync"]),
        (True, False, ["sync-status", "sync"]),
        (False, True, ["sync-status", "sync-setup"]),
    ]:
        if not linked:
            (directory / "linked").unlink(missing_ok=True)
        calls.write_text("")
        run = subprocess.run(["bash", str(wrapper)], env=dict(env, FAIL_SETUP=str(int(fail))))
        assert run.returncode == (2 if fail else 0), run.returncode
        assert calls.read_text().splitlines() == expected
print("PASS: initial setup, existing link, failed setup; paths with spaces")
