#!/usr/bin/env bash

export DOTFILES="$HOME/.dotfiles"
source $DOTFILES/tools/pretty_print.sh

lobster

info "Installing brew"
if $DOTFILES/brew/install.sh; then
	success "Brew installed"
else
	fail "Failed to install brew"
fi
info "Installing brew packages"

if $DOTFILES/tools/create_symlinks.sh; then
	success "Symlinks created"
else
	fail "Failed to create symlinks."
fi

if brew bundle --file=$DOTFILES/brew/Brewfile; then
	success "Brew packages installed"
else
	fail "Failed to install brew packages"
fi

if test -f "$HOME/.vprof"; then
	touch "$HOME/.vprof"
fi

if test -f "$HOME/.zprofile"; then
	touch "$HOME/.zprofile"
fi

info "installing git plugins"
vim +PlugInstall +qall > /dev/null

success "Installation complete"

lobster
