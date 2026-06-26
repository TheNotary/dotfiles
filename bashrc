#the_time=$(echo $(($(date +%s%N)/1000000)) |cut -c 8-); echo ${the_time:0:3}:${the_time:3}
export BASH_SILENCE_DEPRECATION_WARNING=1

# Source common configuration
source ${HOME}/.commonrc

# Bash-specific completions
[ -e /etc/bash_completion ] && . /etc/bash_completion
[ -e $HOME/.git-completion.bash ] && . $HOME/.git-completion.bash
[ -e $HOME/.kubectl-completion.bash ] && . $HOME/.kubectl-completion.bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


######################
# Setup Bash History #
######################

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
HISTFILESIZE=40000
shopt -s histappend
shopt -s checkwinsize


##########################
# Custom Terminal Themes #
##########################

# ⚡ ♢ ◊ ❰❱ ℵ ∴ ♠ ∫ ❥ h

color_off='\[\e[0m\]'
green='\[\e[0;32m\]'
yellow='\[\e[0;33m\]'
blue='\[\e[0;34m\]'
purple='\[\e[0;35m\]'

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

[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm"

#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

complete -C ~/bin/vault vault

PATH="$HOME/go/bin:$PATH"

# fnm
FNM_PATH="/home/ubuntu/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

alias explorer="explorer.exe"
alias foobar='foobar_templates'
