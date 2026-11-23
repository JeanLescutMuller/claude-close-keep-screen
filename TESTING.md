# Testing claude-close-keep-screen

```bash
bash ~/opt/agent-tracker/run_with_test_tmux.sh bash /home/enrices/dev/agents/claude-close-keep-screen/tests/run_tests.sh
```

Runs in a sandbox (`mktemp -d`): its own `HOME`, `CLAUDE_CONFIG_DIR` and a separate tmux server (`TMUX_TMPDIR`, `TMUX` unset); install.sh and uninstall.sh run with that `HOME`. Fake Claude sessions are `tests/fake_claude.py` processes started in the sandbox's tmux panes. It prints one line per failure and the totals; the full log is `<sandbox>/test.log` (path printed). Takes about 45 s (one test waits the 5 s SIGTERM timeout, `self` waits for idle).

| Part | Checks |
|---|---|
| install / uninstall | the link points into `~/opt/claude-close-keep-screen`, re-run is idempotent, the `/close` hook in settings.json once and the skill linked, nothing in the real HOME (its settings.json included), uninstall removes hook and skill and keeps data and logs |
| self and /close | the hook lets every other prompt through with no output; `/close` outside a Claude session is blocked with the reason; `self` from a fake session's child: returns at once, closes it, screen file and pane show the screen and the box, resume pre-typed, logged `by: self`; via the hook in a busy session: not closed while busy, closed once idle; busy past the wait: left alone, logged; no tmux pane: refused |
| refusals | unknown uuid, busy, self (env and process tree), not in tmux, kind not interactive, pid gone, pid reused, pane gone, pane not holding the pid, ambiguous prefix; none sends a signal |
| close | by uuid prefix and by `%pane`: ended by SIGTERM, screen file, screen shown in the pane, `claude --resume <uuid>` typed but not run, log row; no exit after SIGTERM leaves the pane untouched |
| idle | picks idle + last prompt older than N h only (a newer tool result is not a prompt), dry run closes nothing, uses `agent-tracker now --json`'s last prompt when installed |
