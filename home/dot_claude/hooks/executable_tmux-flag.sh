#!/usr/bin/env bash
# Claude Code hook: flag the tmux window that is waiting for input.
#
# Usage (from ~/.claude/settings.json hooks):
#   tmux-flag.sh waiting   # Notification  -> mark window (● shows in status bar)
#   tmux-flag.sh ready     # Stop          -> clear flag
#   tmux-flag.sh busy      # UserPromptSubmit / PreToolUse -> clear flag (working)
#
# The window-status format in ~/.tmux.conf.local reads @claude_waiting and
# prepends a ● to the tab when it is set to 1.
#
# Safe no-op when not running inside tmux.

[ -z "$TMUX" ] && exit 0
command -v tmux >/dev/null 2>&1 || exit 0
[ -z "$TMUX_PANE" ] && exit 0

case "${1:-}" in
  waiting) val=1 ;;
  *)       val=0 ;;   # ready / busy / anything else clears the flag
esac

tmux set-option -w -t "$TMUX_PANE" @claude_waiting "$val" 2>/dev/null || true
exit 0
