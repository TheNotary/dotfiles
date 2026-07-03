#!/usr/bin/env sh
#
# alog.sh
#
# Function and completion for running KQL queries against a
# Log Analytics workspace via the Azure CLI.
# Compatible with both bash and zsh.
#
# Checks ./monitoring/log_queries and current folder for .kql files
# to run.
#
# Usage:
#   source alog.sh                  # or add to ~/.bashrc / ~/.zshrc
#
#   alog aks_start_stops            # run aks_start_stops.kql
#   alog some_query                 # run some_query.kql
#   alog policy_automation --days_back 7  # pass parameter to query
#
# Parameters:
#   .kql files may contain {{PARAM_NAME:default}} placeholders.
#   Pass --param_name value (or --param-name value) after the query name
#   to override defaults. Keys are matched case-insensitively;
#   hyphens are normalized to underscores.
#
# Tab completion:
#   alog <TAB>                      # lists .kql files in CWD (and fallback dir)
#   alog aks_<TAB>                  # filters to matching queries
#
# Prerequisites:
#   - az CLI (https://learn.microsoft.com/cli/azure/install-azure-cli)
#   - ALOG_WORKSPACE_ID env var set to a Log Analytics workspace ID
#

# ---------------------------------------------------------------------------
# alog – run a .kql query against Log Analytics
# ---------------------------------------------------------------------------
alog() {
  if ! command -v az &>/dev/null; then
    echo "ERROR: az CLI is not installed or not on PATH." >&2
    return 1
  fi

  if [[ -z "$ALOG_WORKSPACE_ID" ]]; then
    echo "ERROR: ALOG_WORKSPACE_ID is not set." >&2
    echo "  export ALOG_WORKSPACE_ID=<your-log-analytics-workspace-id>" >&2
    return 1
  fi

  if [[ $# -lt 1 ]]; then
    echo "Usage: alog <query-name> [--param value ...]" >&2
    echo "  .kql files may use {{PARAM:default}} placeholders." >&2
    return 1
  fi

  local query_name="$1"
  shift
  local kql_file=""
  local fallback_dir="./monitoring/log_queries"
  local query _key _ph _default _lookup _repl
  local -A params

  # --- Parse --key value parameters into associative arrays (bash 4+ / zsh) ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --*)
        _key="${1#--}"
        # Normalize: lowercase→uppercase, hyphens→underscores
        _key=$(echo "$_key" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        if [[ $# -lt 2 ]]; then
          echo "ERROR: Missing value for --${1#--}" >&2
          return 1
        fi
        params[$_key]="$2"
        shift 2
        ;;
      *)
        echo "WARNING: Ignoring unexpected argument: $1" >&2
        shift
        ;;
    esac
  done

  # Resolve .kql file: CWD first, then fallback directory
  if [[ -f "${PWD}/${query_name}.kql" ]]; then
    kql_file="${PWD}/${query_name}.kql"
  elif [[ -f "${fallback_dir}/${query_name}.kql" ]]; then
    kql_file="${fallback_dir}/${query_name}.kql"
  else
    echo "ERROR: ${query_name}.kql not found." >&2
    echo "  Searched: ${PWD}/${query_name}.kql" >&2
    echo "           ${fallback_dir}/${query_name}.kql" >&2
    return 1
  fi

  query=$(cat "$kql_file")

  # --- Substitute {{PARAM_NAME:default}} placeholders ---
  # Uses grep + parameter expansion (portable across bash and zsh).
  while IFS= read -r _ph; do
    [[ -z "$_ph" ]] && continue
    # Extract key and default from {{KEY:default}}
    _key="${_ph#\{\{}"
    _key="${_key%%:*}"
    _default="${_ph#*:}"
    _default="${_default%\}\}}"
    # Normalize key for lookup
    _lookup=$(echo "$_key" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
    if [[ -n "${params[$_lookup]+set}" ]]; then
      _repl="${params[$_lookup]}"
    else
      _repl="$_default"
    fi
    query="${query//$_ph/$_repl}"
  done < <(echo "$query" | grep -oE '\{\{[A-Za-z_][A-Za-z0-9_]*:[^}]*\}\}' | sort -u)

  az rest --method post \
    --url "https://api.loganalytics.io/v1/workspaces/${ALOG_WORKSPACE_ID}/query" \
    --body "$(jq -n --arg q "$query" '{query: $q}')" \
    --resource "https://api.loganalytics.io" \
    -o json 2>&1 \
  | jq -r '.tables[0] //empty |
      (.columns | map(.name) | @tsv),
      (.rows[] | @tsv)' \
  | column -t -s $'\t'
}

# ---------------------------------------------------------------------------
# Completion for alog (bash and zsh)
# ---------------------------------------------------------------------------
_alog_candidates() {
  local fallback_dir="./monitoring/log_queries"
  local candidates=""

  # Gather .kql basenames from CWD
  if ls "${PWD}"/*.kql >/dev/null 2>&1; then
    candidates=$(basename -a "${PWD}"/*.kql 2>/dev/null | sed 's/\.kql$//')
  fi

  # Gather from fallback dir
  if [[ -d "$fallback_dir" ]] && ls "${fallback_dir}"/*.kql >/dev/null 2>&1; then
    local fb
    fb=$(basename -a "${fallback_dir}"/*.kql 2>/dev/null | sed 's/\.kql$//')
    candidates=$(printf '%s\n%s' "$candidates" "$fb")
  fi

  # Deduplicate
  echo "$candidates" | sort -u
}

if [[ -n "$BASH_VERSION" ]]; then
  _alog_completions() {
    if [[ ${COMP_CWORD} -ne 1 ]]; then
      return
    fi
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local candidates
    candidates=$(_alog_candidates | tr '\n' ' ')

    COMPREPLY=()
    while IFS= read -r line; do
      COMPREPLY+=("$line")
    done < <(compgen -W "$candidates" -- "$cur")
  }
  complete -F _alog_completions alog

elif [[ -n "$ZSH_VERSION" ]]; then
  _alog_completions() {
    local -a candidates
    candidates=(${(f)"$(_alog_candidates)"})
    _describe 'query' candidates
  }
  (( $+functions[compdef] )) && compdef _alog_completions alog
fi
