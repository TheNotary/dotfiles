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

# Make it so you don't lose bash_history when multiple sessions are spun up
shopt -s histappend
# Apply history immediately, don't wait till end of session
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# set PATH so it includes user's private bin if it exists
#if [ -d "$HOME/bin" ] ; then
#  PATH="$HOME/bin:$PATH"
#fi
if [ -d "$HOME/.rvm/bin" ] ; then
  PATH="$HOME/.rvm/bin:$PATH"
fi
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
