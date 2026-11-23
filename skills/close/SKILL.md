---
name: close
description: Close this Claude session and keep its screen in its tmux pane, with `claude --resume <uuid>` typed below it (claude-close-keep-screen). Only the user types /close; never invoke it yourself.
disable-model-invocation: true
---

# /close

`/close` is caught by claude-close-keep-screen's UserPromptSubmit hook before it reaches the model: the hook starts `claude-close-keep-screen self`, which closes this Claude session once it is idle, keeps its screen in the tmux pane with a summary box, and types `claude --resume <uuid>` there.

If you are reading this, the hook did not run (not installed, or it failed). Then do exactly this, and nothing else:

1. Run with Bash: `claude-close-keep-screen self`
2. End your turn with its output line, unchanged. Do not start any other work: the session closes as soon as your turn ends.
