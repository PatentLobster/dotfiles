#!/bin/bash -x
#
tmux set-option -p remain-on-exit
sudo npm install -g terminalizer
sudo apt update
sudo apt install libnss3 lsb-release xdg-utils wget ffmpeg bc
#sudo apt install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget ffmpeg bc
x="${X:-180}"
y="${Y:-30}"
export IFS=$'\n'
session_name="my_session"
base_dir="$(dirname "$(chezmoi source-path)")"
terminalizer_config="${base_dir}/scripts/vhs/config.yml"
terminalizer record -c $terminalizer_config "${base_dir}/demo"
function record() {
    tmux send-keys -t "$session_name" "terminalizer record -c $terminalizer_config demo"
    tmux send-keys -t "$session_name" C-m
    sleep 1
}

function stop_recording() {
    sleep 1
    tmux send-keys -t "$session_name" "exit"
    tmux send-keys -t "$session_name" C-m
    sleep 3
    tmux send-keys -t "$session_name" "n"
    tmux send-keys -t "$session_name" C-m
}

# Function to emulate human typing in a tmux session
function emulate_human_typing() {
   local text_to_type="$1"  # Text to type in the session

  # If no argument is provided, read from stdin
  if [ -z "$text_to_type" ]; then
	while read -n 1 char; do
      # Send the current character to the specified tmux session
      tmux send-keys -t "$session_name" "$char"

      # Sleep for a random duration between 0.1 and 0.5 seconds (adjust as needed)
      sleep "$(bc <<< "scale=1; 0.1 + 0.6 * $RANDOM / 32767")"
    done
  else
    # Loop through each character in the provided text
    for ((i = 0; i < ${#text_to_type}; i++)); do
      # Get the current character
      char="${text_to_type:i:1}"

      # Send the current character to the specified tmux session
      tmux send-keys -t "$session_name" "$char"

      # Sleep for a random duration between 0.1 and 0.5 seconds (adjust as needed)
      sleep "$(bc <<< "scale=1; 0.1 + 0.6 * $RANDOM / 32767")"
    done
  fi

  # Press Enter to simulate completing the typing
  tmux send-keys -t "$session_name" C-m
}



function emulate_typing() {
  local text_to_type="$1"  # Text to type in the session

  # Send the text to the specified tmux session
  tmux send-keys -t "$session_name" "$text_to_type" C-m
}
RUNNER_TRACKING_ID="" && tmux new  -s "$session_name" -d -x $x -y $y "zsh"
#exec tmux new  -s "$session_name" -x $x -y $y "zsh" -d
tmux ls


#emulate_human_typing "$(cat input.sh)"
record
emulate_human_typing  "echo 'Hello, world!'"
stop_recording

