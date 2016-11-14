# Change this to 'server' to get the bash prompt to look different
# do this in .this_machine if you're clever
bash_display_style=normal

# Source in additional resource files if they exist
[ -e $HOME/.this_machine ] && source $HOME/.this_machine
[ -e $HOME/.mongodbrc ] && source $HOME/.mongodbrc
[ -e $HOME/.rails_secrets ] && source $HOME/.rails_secrets
source $HOME/.my_aliases

#
## setup git to use vim and not NANO
export VISUAL=vim
export EDITOR=vim

# setup colors I hope... this was for a vagrant box that was sucky to work with...


# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


######################
# Setup Bash History #
######################

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Make it so you don't lose bash_history when multiple sessions are spun up
#shopt -s histappend
# Apply history immediately, don't wait till end of session
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
  color_prompt=yes
    else
  color_prompt=
    fi
fi


##########################
# Custom Terminal Themes #
##########################

color_off='\e[0m'
black='\e[0;30m'
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
blue='\e[0;34m'
purple='\e[0;35m'
cyan='\e[0;36m'
white='\e[0;37m'

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '
    if [ "$bash_display_style" = "server" ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;35m\]\u [\h]\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '
    fi
    if [ "$bash_display_style" = "prototype" ]; then
        PS1="\[${blue}\]\u::[\h] \w \[${color_off}\]\[${yellow}\]λ \[${color_off}\]"
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi





###########################################
# Automatically Added Stuff from Packages #
###########################################

## Added by Wine
export WINEARCH=win32

# put java in path
#PATH=$PATH:/usr/lib/jvm/jre1.8.0_45/bin
#export JAVA_HOME=/usr/lib/jvm/jre1.8.0_45/bin
#export netbeans_jdkhome=/usr/lib/jvm/jre1.8.0_45/bin
#
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# set PATH so it includes user's private bin if it exists
#if [ -d "$HOME/bin" ] ; then
#  PATH="$HOME/bin:$PATH"
#fi

# added by travis gem
[ -f /home/john/.travis/travis.sh ] && source /home/john/.travis/travis.sh

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### NodeJS stuff

# makes it so you don't need sudo to install npm packages
export NPM_PACKAGES="$HOME/.npm-packages"
export NODE_PATH="$HOME/.npm-packages/lib/node_modules:$NODE_PATH"

export PATH="$PATH:$HOME/.npm-packages/bin"

export NVM_DIR="/home/john/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm


### Ruby Stuff
if [ -d "$HOME/.rvm/bin" ] ; then
  PATH="$HOME/.rvm/bin:$PATH"
fi
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

