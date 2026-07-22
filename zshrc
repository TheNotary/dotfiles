# Performance monitoring
zmodload zsh/datetime
_zshrc_start=$EPOCHREALTIME

# Zsh-specific completions (must run before sourcing aliases that use compdef)
autoload -Uz compinit && compinit
_t=$EPOCHREALTIME; printf 'compinit: %dms\n' $(( ($_t - $_zshrc_start) * 1000 ))

setopt INTERACTIVE_COMMENTS
setopt AUTO_CD
setopt EXTENDED_GLOB

bindkey '^U' backward-kill-line
zstyle ':completion:*' menu no
_t=$EPOCHREALTIME
source ~/zsh_plugins/fzf-tab/fzf-tab.plugin.zsh
printf 'fzf-tab: %dms\n' $(( ($EPOCHREALTIME - $_t) * 1000 ))
_t=$EPOCHREALTIME
source ~/zsh_plugins/kubectl_complete
printf 'kubectl_complete: %dms\n' $(( ($EPOCHREALTIME - $_t) * 1000 ))

###########################
# Start in last directory #
###########################

ZSH_LAST_DIR="$HOME/.zsh_last_dir"

function save_pwd() {
  pwd >| "$ZSH_LAST_DIR"
}
autoload -U add-zsh-hook
add-zsh-hook chpwd save_pwd

# Restore last directory if it exists
if [[ -z "$ZSHRC_HAS_RUN" && -f "$ZSH_LAST_DIR" ]]; then
  last_dir=$(cat "$ZSH_LAST_DIR")
  [[ -d "$last_dir" ]] && cd "$last_dir"
fi

ZSHRC_HAS_RUN=true



# Source common configuration
_t=$EPOCHREALTIME
source ${HOME}/.commonrc
printf 'commonrc: %dms\n' $(( ($EPOCHREALTIME - $_t) * 1000 ))

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

_t=$EPOCHREALTIME
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b)'

if [ "$bash_display_style" = "server" ]; then
    PROMPT='%B%F{magenta}%n [%m]%f %F{blue}%~ %#%f%b '
elif [ "$bash_display_style" = "work" ]; then
    PROMPT='%B%F{magenta}%n %F{blue}%~ %F{green}❥ %f%b'
elif [ "$bash_display_style" = "prototype" ]; then
    PROMPT='%F{blue}%n[%m]%F{magenta} ♢%F{blue} %~ %f%F{yellow}λ %f'
else
    PROMPT='%B%F{green}%n@%m%f %F{blue}%~ %(#.#.$)%f%b '
fi
printf 'prompt/theme: %dms\n' $(( ($EPOCHREALTIME - $_t) * 1000 ))

printf '\n==> Total zshrc load time: %dms\n' $(( ($EPOCHREALTIME - $_zshrc_start) * 1000 ))
unset _t _zshrc_start

