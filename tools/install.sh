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
if brew install $(cat $DOTFILES/brew/packages); then
	success "Brew packages installed"
else
	fail "Failed to install brew packages"
fi

if $DOTFILES/tools/create_symlinks.sh; then
	success "Symlinks created"
else
	fail "Failed to create symlinks."
fi
