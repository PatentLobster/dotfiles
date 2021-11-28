#!/bin/zsh
# yank
function yank () {
        if [ "$*" != "" ]
	then
		$* | pbcopy
		echo $(pbpaste)
	else
        	echo "Nothing to yank bro."
	fi

}

