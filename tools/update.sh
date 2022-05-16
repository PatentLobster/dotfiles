#!/usr/bin/env bash
source $DOTFILES/tools/pretty_print.sh

lobster

cd $DOTFILES
git  pull --rebase --progress 
git  submodule update --progress --remote --recursive 
brew bundle --file=$DOTFILES/brew/Brewfile
