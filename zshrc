# Zsh-specific completions (must run before sourcing aliases that use compdef)
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Source common configuration
source ${HOME}/.commonrc

# If not running interactively, don't do anything
[[ -o interactive ]] || return


######################
# Setup Zsh History  #
######################

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history


##########################
# Custom Terminal Themes #
##########################

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b)'

if [ "$bash_display_style" = "server" ]; then
    PROMPT='%F{magenta}%n [%m]%f %F{blue}%~ %#%f '
elif [ "$bash_display_style" = "work" ]; then
    PROMPT='%F{magenta}%n %F{blue}%~ %F{green} ❥ %f'
elif [ "$bash_display_style" = "prototype" ]; then
    PROMPT='%F{blue}%n[%m]%F{magenta} ♢%F{blue} %~ %f%F{yellow}λ %f'
else
    PROMPT='%B%F{green}%n@%m%f %F{blue}%~ %(#.#.$)%f%b '
fi
