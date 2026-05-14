#!/usr/bin/env bash
#
# alog.sh
#
# Bash function and completion for running KQL queries against a
# Log Analytics workspace via the Azure CLI.
#
# Checks ./monitoring/log_queries and current folder for .kql files
# to run.
#
# Usage:
#   source alog.sh                  # or add to ~/.bashrc / ~/.aliases/
#
#   alog aks_start_stops            # run aks_start_stops.kql
#   alog some_query                 # run some_query.kql
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
    echo "Usage: alog <query-name> (without .kql extension)" >&2
    return 1
  fi

  local query_name="$1"
  local kql_file=""
  local fallback_dir="./monitoring/log_queries"

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

  local query
  query=$(cat "$kql_file")

  local result
  result=$(az monitor log-analytics query \
    --workspace "$ALOG_WORKSPACE_ID" \
    --analytics-query "$query" \
    -o json 2>&1)

  if [[ $? -ne 0 ]]; then
    echo "ERROR: Query failed:" >&2
    echo "$result" >&2
    return 1
  fi

  if [[ "$result" == "[]" ]]; then
    echo "(no results)" >&2
    return 0
  fi

  echo "$result" \
    | jq -r '(.[0] | keys_unsorted | map(select(. != "TableName"))) as $cols
      | ($cols | @tsv), (.[] | [.[$cols[]]] | @tsv)' \
    | column -t -s $'\t'
}

# ---------------------------------------------------------------------------
# Bash completion for alog
# ---------------------------------------------------------------------------
_alog_completions() {
  # Only complete the first argument
  if [[ ${COMP_CWORD} -ne 1 ]]; then
    return
  fi

  local cur="${COMP_WORDS[COMP_CWORD]}"
  local fallback_dir="./monitoring/log_queries"
  local candidates=""

  # Gather .kql basenames from CWD
  if compgen -G "${PWD}/*.kql" >/dev/null 2>&1; then
    candidates=$(basename -a "${PWD}"/*.kql 2>/dev/null | sed 's/\.kql$//')
  fi

  # Gather from fallback dir (deduplicate later)
  if [[ -d "$fallback_dir" ]] && compgen -G "${fallback_dir}/*.kql" >/dev/null 2>&1; then
    local fb
    fb=$(basename -a "${fallback_dir}"/*.kql 2>/dev/null | sed 's/\.kql$//')
    candidates=$(printf '%s\n%s' "$candidates" "$fb")
  fi

  # Deduplicate
  candidates=$(echo "$candidates" | sort -u | tr '\n' ' ')

  COMPREPLY=()
  while IFS= read -r line; do
    COMPREPLY+=("$line")
  done < <(compgen -W "$candidates" -- "$cur")
}

complete -F _alog_completions alog
