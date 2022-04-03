#!/usr/bin/env bash

source pretty_print.sh

lobster

info "Getting leet packages"

if [ ! -d "$HOME/.fzf" ]; then
	info "Installing fzf"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	if $HOME/.fzf/install --all; then
		success "installed fzf successfully"
	else
		fail "Failed to install fzf"
	fi
else
	success "fzf already installed"
fi

