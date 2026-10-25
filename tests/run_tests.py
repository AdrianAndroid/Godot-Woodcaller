#!/usr/bin/env python3
"""Run each Godot integration test in a separate process with a real timeout."""
from pathlib import Path
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
GODOT = os.environ.get('GODOT_BIN', '/Applications/Godot.app/Contents/MacOS/Godot')
TESTS = ('player_movement_test', 'enemy_chase_test', 'summon_test', 'progression_test', 'waves_test', 'save_test', 'boss_test', 'game_end_test', 'main_menu_test', 'art_assets_test', 'audio_test', 'upgrades_test', 'stress_test')
results = ROOT / 'tests/results'
results.mkdir(exist_ok=True)
failed = []
for name in TESTS:
    try:
        run = subprocess.run([GODOT, '--headless', '--path', str(ROOT), '--script', f'tests/{name}.gd'], capture_output=True, text=True, timeout=35)
        output = run.stdout + run.stderr
        ok = run.returncode == 0 and 'RESULT: 0 failure(s)' in output and 'ERROR:' not in output and 'FAIL:' not in output
    except subprocess.TimeoutExpired as exc:
        output = f'TIMEOUT: {name}\n{exc.stdout!r}\n{exc.stderr!r}'
        ok = False
    (results / f'current-{name}.log').write_text(output)
    print(f'{"PASS" if ok else "FAIL"}: {name}', flush=True)
    if not ok:
        failed.append(name)
        print(output, flush=True)
print(f'SUITES: {len(TESTS) - len(failed)} passed, {len(failed)} failed')
sys.exit(bool(failed))
