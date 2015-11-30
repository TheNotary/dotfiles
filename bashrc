export WINEARCH=win32
#
[ -e $HOME/.this_machine ] && source $HOME/.this_machine
[ -e $HOME/.mongodbrc ] && source $HOME/.mongodbrc
[ -e $HOME/.rails_secrets ] && source $HOME/.rails_secrets

export PATH="$PATH:$HOME/.npm-packages/bin"
source $HOME/.my_aliases
#
## setup git to use vim and not NANO
export VISUAL=vim
export EDITOR=vim

# put java in path
#PATH=$PATH:/usr/lib/jvm/jre1.8.0_45/bin
#export JAVA_HOME=/usr/lib/jvm/jre1.8.0_45/bin
#export netbeans_jdkhome=/usr/lib/jvm/jre1.8.0_45/bin
#
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Make it so you don't lose bash_history when multiple sessions are spun up
#shopt -s histappend
# Apply history immediately, don't wait till end of session
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# set PATH so it includes user's private bin if it exists
#if [ -d "$HOME/bin" ] ; then
#  PATH="$HOME/bin:$PATH"
#fi
if [ -d "$HOME/.rvm/bin" ] ; then
  PATH="$HOME/.rvm/bin:$PATH"
fi
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

