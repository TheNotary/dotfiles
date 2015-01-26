export WINEARCH=win32
#
[ -e $HOME/.mongodbrc ] && source $HOME/.mongodbrc
source $HOME/.my_aliases
#
## setup git to use vim and not NANO
export VISUAL=vim
export EDITOR=vim
#
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# set PATH so it includes user's private bin if it exists
#if [ -d "$HOME/bin" ] ; then
#  PATH="$HOME/bin:$PATH"
#fi
if [ -d "$HOME/.rvm/bin" ] ; then
  PATH="$HOME/.rvm/bin:$PATH"
fi
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
