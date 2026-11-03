#!/usr/bin/env python3
"""Writes site/update.json for «Check for updates» in the apps: version, download links, SHA-256 of the Windows exes.
Run after both builds, before publishing the release: python3 tools/update_manifest.py 0.9
Release assets (tag v<version>-beta): AURA-Switcher-mac.zip, AURA-Switcher-windows-x64.exe / -arm64.exe (+ the zips)."""
import hashlib, json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
v = sys.argv[1]
base = f"https://github.com/klbk/aura-switcher/releases/download/v{v}-beta/"
m = {"version": v, "mac": base + "AURA-Switcher-mac.zip"}
for arch in ("x64", "arm64"):
    exe = ROOT / "dist" / f"AURA-Switcher-windows-{arch}.exe"
    m[f"win-{arch}"] = {"url": base + exe.name, "sha256": hashlib.sha256(exe.read_bytes()).hexdigest()}
(ROOT / "site/update.json").write_text(json.dumps(m, indent=1) + "\n")
print(json.dumps(m, indent=1))
