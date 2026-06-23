#!/usr/bin/env bash
# Print the currently-playing Spotify track ("Song - Artist") for the tmux
# status bar via #(...). Plain text -> inherits the surrounding status-bar
# background. Prints nothing when not on macOS, Spotify isn't running, or
# nothing is playing, so the status section just collapses.

# Spotify scripting via AppleScript is macOS-only.
[ "$(uname -s)" = "Darwin" ] || exit 0
command -v osascript >/dev/null 2>&1 || exit 0

# Bail out quietly if Spotify isn't running (avoids launching it).
osascript -e 'application "Spotify" is running' 2>/dev/null | grep -q true || exit 0

# Only show something while a track is actually playing.
state=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)
[ "$state" = "playing" ] || exit 0

track=$(osascript -e 'tell application "Spotify" to name of current track & " - " & artist of current track' 2>/dev/null)
[ -n "$track" ] || exit 0

printf '🎵 %s' "$track"
exit 0