export WINEARCH=win32

[ -e $HOME/.mongodbrc ] && source $HOME/.mongodbrc
source $HOME/.my_aliases

# setup git to use vim and not NANO
export VISUAL=vim
export EDITOR=vim

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
