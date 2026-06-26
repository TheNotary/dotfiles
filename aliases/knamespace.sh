#!/usr/bin/env bash
#
# knamespace.sh
#
# Switch kubectl namespace context with tab completion for bash and zsh.
#
# Usage:
#   knamespace <namespace>
#   kn <namespace>          # alias
#
# Tab completion:
#   knamespace <TAB>        # lists all namespaces in the current cluster
#   kn <TAB>                # same
#

# ---------------------------------------------------------------------------
# knamespace – set the current kubectl namespace context
# ---------------------------------------------------------------------------
function knamespace {
  kubectl config set-context --current --namespace $1
}

alias kn=knamespace

# ---------------------------------------------------------------------------
# Completions
# ---------------------------------------------------------------------------
if [ -n "$BASH_VERSION" ]; then
  __knamespace_complete() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Only complete the 1st argument (namespace)
    if [[ $COMP_CWORD -eq 1 ]]; then
      local ns
      ns="$(kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null)"
      COMPREPLY=( $(compgen -W "$ns" -- "$cur") )
    else
      COMPREPLY=()
    fi
  }

  complete -F __knamespace_complete knamespace
  complete -F __knamespace_complete kn

elif [ -n "$ZSH_VERSION" ]; then
  _knamespace_complete() {
    local -a candidates
    local ns
    ns="$(kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null)"
    candidates=(${(f)ns})
    _describe 'namespace' candidates
  }

  (( $+functions[compdef] )) && compdef _knamespace_complete knamespace
  (( $+functions[compdef] )) && compdef _knamespace_complete kn
fi
