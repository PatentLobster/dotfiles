alias zshconfig="vim ~/.dotfiles/zsh/zshrc"
alias zprofile="vim ~/.zprofile"
alias zprof="zprofile"
alias zconfig="zshconfig"
alias zshconf="zshconfig"
alias zconf="zshconfig"
alias vimconfig="vim ~/.dotfiles/vim/vimrc"
alias vimconf="vimconfig"
alias vconfig="vimconfig"
alias vconf="vimconfig"
alias y="yank"

# reload zsh config
alias reload!='RELOAD=1 source ~/.zshrc'

# Helpers
alias grep='grep --color=auto'
alias df='df -h' # disk free, in Gigabytes, not bytes
alias du='du -h -c' # calculate disk usage for a folder

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Recursively delete `.DS_Store` files
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"
# remove broken symlinks
alias clsym="find -L . -name . -o -type d -prune -o -type l -exec rm {} +"

alias lpath='echo $PATH | tr ":" "\n"' # list the PATH separated by new lines

eval $(thefuck --alias)
alias clr="clear"

# Git
alias gcb='git copy-branch-name'

