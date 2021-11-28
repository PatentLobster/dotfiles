#!/usr/bin/env bash
echo ''
set -e

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

DOT_HOME="$HOME/.dotfiles"

info "Installing brew"
if $DOT_HOME/brew/install.sh; then
	success "Brew installed"
else
	fail "Failed to install brew"
fi
info "Installing brew packages"
if brew install $(cat $DOT_HOME/brew/packages); then
	success "Brew packages installed"
else
	fail "Failed to install brew packages"
fi

$DOT_HOME/tools/create_symlinks.sh
