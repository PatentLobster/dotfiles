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

# Rainbow ramp across the xterm-256 color cube (red->orange->yellow->green
# ->cyan->blue->violet->magenta). Each refresh shifts the starting hue so the
# colors visibly "flow" (tmux re-runs this every status-interval).
RAINBOW=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 51 45 39 33 27 21 57 93 129 165 201 200 199 198)
NCOL=${#RAINBOW[@]}

# phase advances ~1 step per second so the rainbow animates
phase=$(( $(date +%s) % NCOL ))

# rainbow STRING -> per-character colored output, ending with a reset so it
# does not bleed into the next status section.
rainbow() {
  local s="$1" i ch idx out=""
  for (( i = 0; i < ${#s}; i++ )); do
    ch="${s:i:1}"
    idx=$(( (i + phase) % NCOL ))
    out="${out}#[fg=colour${RAINBOW[idx]}]${ch}"
  done
  printf '%s#[default]' "$out"
}

out=""
if [ "$working" -gt 0 ]; then
  out="$(rainbow "⚡ ${working} working")"
fi
if [ "$waiting" -gt 0 ]; then
  [ -n "$out" ] && out="${out}  "
  # orange, readable on the dark status bg, with a #[default] reset after
  out="${out}#[fg=colour214]⏸ ${waiting} waiting#[default]"
fi
if [ -z "$out" ]; then
  out='✓ All agents ready'           # plain
fi

printf '%s' "$out"
exit 0
