#!/usr/bin/env bash
# Claude Code hook: record this pane's agent state for the tmux status bar.
# Self-contained — no plugin, daemon, or extra tmux hooks required.
#
# Usage (from ~/.claude/settings.json hooks):
#   agent-state.sh working   # UserPromptSubmit / PreToolUse -> Claude is busy
#   agent-state.sh waiting    # Notification  -> Claude needs input
#   agent-state.sh done       # Stop          -> Claude finished its turn
#
# Writes one word to ~/.cache/claude-agent-status/<session>_<pane>.state.
# Stale files (pane gone) are pruned by the reader. Safe no-op outside tmux.

STATE_DIR="$HOME/.cache/claude-agent-status"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

[ -z "${TMUX:-}" ] && exit 0
command -v tmux >/dev/null 2>&1 || exit 0
[ -z "${TMUX_PANE:-}" ] && exit 0

session=$(tmux display-message -p '#{session_name}' 2>/dev/null) || exit 0
[ -n "$session" ] || exit 0

case "${1:-}" in
  working) state=working ;;
  waiting) state=waiting ;;
  done|*)  state=done ;;
esac

# sanitize pane id (%3 -> 3) so the filename is clean
pane=${TMUX_PANE#%}
printf '%s\n' "$state" > "$STATE_DIR/${session}_${pane}.state" 2>/dev/null || true
exit 0
