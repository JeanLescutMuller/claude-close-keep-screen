#!/usr/bin/env python3
"""Adds or removes claude-close-keep-screen's hook in the `hooks` object of Claude Code's settings.json, touching
nothing else: a UserPromptSubmit group running `claude-close-keep-screen hook` (it turns the prompt /close into
`claude-close-keep-screen self`, and lets every other prompt through).

`hooks` is shared (skill config-ownership): every tool owns only its own groups, recognised by their command.
Ours is the group whose command contains "claude-close-keep-screen hook"; set replaces it (a re-run never adds a
second one), unset removes it; every other group stays as it is. Adapted from agent-tracker's src/merge_claude_hooks.py.

Usage: merge_claude_hooks.py set|unset
Env:   CLAUDE_SETTINGS (default $CLAUDE_CONFIG_DIR/settings.json, else ~/.claude/settings.json)
Prints one of: changed, unchanged, absent.
"""
import json
import os
import sys
from pathlib import Path

MARK = "claude-close-keep-screen hook"
EVENT = "UserPromptSubmit"
# The full path: a hook must not depend on ~/.local/bin being on Claude Code's PATH. It runs on every prompt: 10 s cap.
GROUP = {"hooks": [{"type": "command", "command": "$HOME/.local/bin/claude-close-keep-screen hook", "timeout": 10}]}

# A link (account b's settings.json -> ../settings.json): write its target, never replace the link (2026-11-21).
settings_path = Path(os.environ.get("CLAUDE_SETTINGS") or
                     Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude") / "settings.json").resolve()
mode = sys.argv[1]
if mode not in ("set", "unset"):
    sys.exit("usage: merge_claude_hooks.py set|unset")

if not settings_path.exists():
    if mode == "unset":
        print("absent")
        sys.exit(0)
    d_settings = {}
else:
    d_settings = json.loads(settings_path.read_text())


def ours(d_group) -> bool:
    return isinstance(d_group, dict) and any(MARK in str(h.get("command", "")) for h in d_group.get("hooks") or []
                                             if isinstance(h, dict))


d_hooks = dict(d_settings.get("hooks") or {})
l_groups = [g for g in d_hooks.get(EVENT) or [] if not ours(g)]
if mode == "set":
    l_groups.append(GROUP)
if l_groups:
    d_hooks[EVENT] = l_groups
else:
    d_hooks.pop(EVENT, None)

d_new = dict(d_settings)
if d_hooks:
    d_new["hooks"] = d_hooks
else:
    d_new.pop("hooks", None)

if d_new == d_settings:
    print("unchanged")
else:
    # Temp file + rename: a Claude Code starting meanwhile never reads half a file.
    tmp = settings_path.with_suffix(".json.tmp")
    tmp.parent.mkdir(parents=True, exist_ok=True)
    tmp.write_text(json.dumps(d_new, indent=2) + "\n")
    tmp.replace(settings_path)
    print("changed")
