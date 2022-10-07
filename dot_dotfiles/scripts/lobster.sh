#!/bin/sh

lobster () {
	if command -v lolcat &> /dev/null; then
		lobster_printer="lolcat"
	else
		lobster_printer="cat"
	fi
	eval $lobster_printer << "EOF"
                             ,.---._
                   ,,,,     /       `,
                    \\\\   /    '\_  ;
                     |||| /\/``-.__\;'
                     ::::/\/_
     {{`-.__.-'(`(^^(^^^(^ 9 `.========='
    {{{{{{ { ( ( (  (   (-----:=
     {{.-'~~'-.(,(,,(,,,(__6_.'=========.
                     ::::\/\
                     |||| \/\  ,-'/,
                    ////   \ `` _/ ;
                   ''''     \  `  .'
                             `---'
EOF
}