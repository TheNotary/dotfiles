#the_time=$(echo $(($(date +%s%N)/1000000)) |cut -c 8-); echo ${the_time:0:3}:${the_time:3}
export BASH_SILENCE_DEPRECATION_WARNING=1

# Change this to 'server' to get the bash prompt to look different
# do this in .this_machine if you're clever
[ -z "$bash_display_style" ] && \
  bash_display_style=normal

# Source in additional resource files if they exist
[ -e /etc/bash_completion ] && . /etc/bash_completion  # enable bash completion in interactive shells
[ -e $HOME/.mac_fixes ] && source $HOME/.mac_fixes
[ -e $HOME/.git-completion.bash ] && source $HOME/.git-completion.bash
[ -e $HOME/.kubectl-completion.bash ] && source $HOME/.kubectl-completion.bash
[ -e $HOME/.app_secrets ] && source $HOME/.app_secrets
[ -e $HOME/.this_machine ] && source $HOME/.this_machine
[ -e $HOME/.work_specific ] && source $HOME/.work_specific
source $HOME/.my_aliases

export PATH="/$HOME/bin:$PATH"


## Setup git
# export GIT_AUTHOR_NAME=$MY_FULL_NAME
# export GIT_AUTHOR_EMAIL=$MY_EMAIL
# export GIT_COMMITTER_NAME=$MY_FULL_NAME
# export GIT_COMMITTER_EMAIL=$MY_FULL_NAME

## setup git to use vim and not NANO
export VISUAL=vim
export EDITOR=vim


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
HISTSIZE=10000
HISTFILESIZE=20000

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

# TODO:  if the latter colors don't mess up my screen in any way then delete the former duplicates since they're not needed
color_off='\e[0m'
color_off='\[\e[0m\]'
black='\e[0;30m'
red='\e[0;31m'
green='\e[0;32m'
green='\[\e[0;32m\]'
yellow='\e[0;33m'
blue='\e[0;34m'
blue='\[\e[0;34m\]'
purple='\e[0;35m'
purple='\[\e[0;35m\]'
cyan='\e[0;36m'
white='\e[0;37m'

# ⚡ ♢ ◊ ❰❱ ℵ ∴ ♠ ∫ ❥ h

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '
    if [ "$bash_display_style" = "server" ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;35m\]\u [\h]\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '
    fi
    if [ "$bash_display_style" = "work" ]; then
        PS1="${debian_chroot:+($debian_chroot)}${purple}\u ${blue}\w ${green} ❥ ${color_off}"
    fi
    if [ "$bash_display_style" = "prototype" ]; then
        PS1="${blue}\u[\h]${purple} ♢${blue} \w ${color_off}${yellow}λ ${color_off}"
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

# set PATH so it includes user's private bin if it exists
#if [ -d "$HOME/bin" ] ; then
#  PATH="$HOME/bin:$PATH"
#fi

# added by travis gem
[ -f /home/john/.travis/travis.sh ] && source /home/john/.travis/travis.sh

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Python stuff

# Prevent .pyc files from being generated
export PYTHONDONTWRITEBYTECODE=1


### NodeJS stuff

# makes it so you don't need sudo to install npm packages
export NPM_PACKAGES="$HOME/.npm-packages"
export NODE_PATH="$HOME/.npm-packages/lib/node_modules:$NODE_PATH"

export PATH="$PATH:$HOME/.npm-packages/bin"

# This loads nvm
export NVM_DIR=~/.nvm
function nvm {
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    nvm use system
    nvm $@
  else
    echo "nvm hasn't been installed on this machine I think.  You're reading a bash function"
  fi
}

### Ruby Stuff
if [ -d "$HOME/.rvm/bin" ] ; then
  PATH="$HOME/.rvm/bin:$PATH"
fi


#export ACTUAL_RVM_PATH="$(which rvm)"
#export RVM_IS_SETUP=""
#function rvm {
#  if [ -z "$RVM_IS_SETUP" ]; then
#    echo 'got here'
#    source "$HOME/.rvm/scripts/rvm"
#    export RVM_IS_SETUP="true"
#  fi
#  eval "${ACTUAL_RVM_PATH} $@"
#}

[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm"

#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

complete -C ~/bin/vault vault
