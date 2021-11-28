#!/usr/bin/env bash

for f in $HOME/.dotfiles/symlinks/*.symlink
do
	ln -sf $(echo $(eval "echo \"$(cat $f)\""))
done

