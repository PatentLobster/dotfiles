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
	$HOME/bin/chezmoi $@
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

install_brew() {
    if test ! $(which brew); then
        info "Installing brew 🍺"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        {{ if ne .chezmoi.os "darwin" }}
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        {{ end }}
    fi

    if [ $(which brew) ]; then
      if [ ! $(which gum) ]; then
          info "Installing gum 🔮"
          brew install gum
      fi
      {{ if eq .chezmoi.os "linux" }}
        {{ if eq .chezmoi.osRelease.id "amzn" }}
          {{      if eq .chezmoi.arch "amd64" }}
            wget "https://github.com/charmbracelet/gum/releases/download/$(get_latest_release "charmbracelet/gum")/gum_$(get_latest_release "charmbracelet/gum" | sed "s/v//g")_linux_amd64.rpm" -O /tmp/gum.rpm
          {{      else }}
            wget "https://github.com/charmbracelet/gum/releases/download/$(get_latest_release "charmbracelet/gum")/gum_$(get_latest_release "charmbracelet/gum" | sed "s/v//g")_linux_arm64.rpm" -O /tmp/gum.rpm
          {{      end }}
          rpm -i /tmp/gum.rpm
        {{ end }}
      {{ end }}
    fi
}

function get_latest_release() {
  curl --silent -L "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

