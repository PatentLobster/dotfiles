#!/usr/bin/env bash
# Print a PLAIN-text summary of Claude agent state across all tmux panes,
# for use in the tmux status bar via #(...). No colors -> inherits the
# surrounding status-bar background. Prints nothing when there are no agents.
#
# Reads state files written by agent-state.sh. Prunes files whose pane no
# longer exists so counts stay accurate without a daemon.

STATE_DIR="$HOME/.cache/claude-agent-status"
[ -d "$STATE_DIR" ] || exit 0

# set of currently-live "session_pane" keys (pane id stripped of leading %)
live=" "
if command -v tmux >/dev/null 2>&1; then
  while IFS= read -r line; do
    live="${live}${line} "
  done < <(tmux list-panes -a -F '#{session_name}_#{pane_id}' 2>/dev/null | tr -d '%')
fi

working=0 waiting=0 done=0
for f in "$STATE_DIR"/*.state; do
  [ -f "$f" ] || continue
  key=$(basename "$f" .state)
  # prune state for panes that have gone away
  if [ -n "${TMUX:-}" ] && [ "$live" != "  " ]; then
    case "$live" in
      *" $key "*) : ;;
      *) rm -f "$f" 2>/dev/null; continue ;;
    esac
  fi
  case "$(cat "$f" 2>/dev/null)" in
    working) working=$((working+1)) ;;
    waiting) waiting=$((waiting+1)) ;;
    done)    done=$((done+1)) ;;
  esac
done

total=$((working+waiting+done))
[ "$total" -eq 0 ] && exit 0

parts=""
[ "$working" -gt 0 ] && parts="${parts}⚡ ${working} working  "
[ "$waiting" -gt 0 ] && parts="${parts}⏸ ${waiting} waiting  "
if [ -z "$parts" ]; then
  printf '✓ All agents ready'
else
  # trim trailing spaces
  printf '%s' "${parts%"${parts##*[![:space:]]}"}"
fi
exit 0
