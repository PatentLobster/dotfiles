#!/bin/bash
info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

chez () {
if command -v chezmoi &> /dev/null; then
	chezmoi $@
else
  if [ -f "$HOME/bin/chezmoi" ]; then
	  $HOME/bin/chezmoi $@
	fi
	if [ -f "$HOME/.local/bin/chezmoi" ]; then
	  $HOME/.local/bin/chezmoi $@
	fi
fi
}


lobster () {
	if command -v lolcat &> /dev/null; then
		lobster_printer="lolcat"
	else
		lobster_printer="cat"
	fi
	eval $lobster_printer $(chez source-path)/home/dot_dotfiles/scripts/lobster
    printf "\n"
}

function get_latest_release() {
  curl --silent -L "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

