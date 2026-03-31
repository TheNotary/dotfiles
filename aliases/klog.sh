#!/usr/bin/env bash
#
# klog.sh
#
# Bash function and completion for streaming kubectl logs from any pod
# across all namespaces, without needing to know or switch namespace context.
#
# Usage:
#   source scripts/klog.sh          # or add to ~/.bashrc
#
#   klog pod/my-app-abc123 -f       # stream logs (namespace auto-detected)
#   klog my-app-abc123 --tail=100   # bare pod name also works
#   klog pod/my-app -c sidecar      # target a specific container
#   klog pod/my-app -n my-ns -f     # explicit namespace (skip auto-detect)
#
# Tab completion:
#   klog pod/<TAB>                  # lists all pods across all namespaces
#   klog pod/dev-<TAB>              # filters to matching pods
#
# Prerequisites:
#   - kubectl (https://kubernetes.io/docs/tasks/tools/)
#   - A valid kubeconfig context
#

# ---------------------------------------------------------------------------
# klog – kubectl logs with automatic namespace resolution
# ---------------------------------------------------------------------------
klog() {
  if ! command -v kubectl &>/dev/null; then
    echo "ERROR: kubectl is not installed or not on PATH." >&2
    return 1
  fi

  if [[ $# -lt 1 ]]; then
    echo "Usage: klog <pod-name|pod/pod-name> [kubectl-logs-flags...]" >&2
    return 1
  fi

  local pod_arg="$1"
  shift

  # Strip "pod/" or "pods/" prefix if present
  local pod_name="${pod_arg#pod/}"
  pod_name="${pod_name#pods/}"

  if [[ -z "$pod_name" ]]; then
    echo "ERROR: No pod name provided." >&2
    return 1
  fi

  # Check if an explicit namespace was passed via -n / --namespace
  local explicit_ns=""
  local pass_args=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--namespace)
        if [[ $# -lt 2 ]]; then
          echo "ERROR: $1 requires a value." >&2
          return 1
        fi
        explicit_ns="$2"
        shift 2
        ;;
      --namespace=*)
        explicit_ns="${1#*=}"
        shift
        ;;
      *)
        pass_args+=("$1")
        shift
        ;;
    esac
  done

  local namespace="$explicit_ns"

  # Auto-detect namespace if not explicitly given
  if [[ -z "$namespace" ]]; then
    local matches
    matches=$(kubectl get pods --all-namespaces \
      --field-selector="metadata.name=${pod_name}" \
      --no-headers -o custom-columns='NS:.metadata.namespace' 2>/dev/null)

    if [[ -z "$matches" ]]; then
      echo "ERROR: Pod '${pod_name}' not found in any namespace." >&2
      return 1
    fi

    local ns_count
    ns_count=$(echo "$matches" | wc -l)

    if [[ "$ns_count" -gt 1 ]]; then
      echo "ERROR: Pod '${pod_name}' found in multiple namespaces:" >&2
      echo "$matches" | sed 's/^/  /' >&2
      echo "Specify one with: klog ${pod_arg} -n <namespace>" >&2
      return 1
    fi

    namespace=$(echo "$matches" | tr -d '[:space:]')
  fi

  kubectl logs -n "$namespace" "$pod_name" "${pass_args[@]}"
}

# ---------------------------------------------------------------------------
# Bash completion for klog
# ---------------------------------------------------------------------------
_klog_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local cache_file="/tmp/klog_pods_cache_$(id -u)"
  local cache_max_age=30  # seconds

  # Refresh cache if missing or stale
  local needs_refresh=1
  if [[ -f "$cache_file" ]]; then
    local file_age
    file_age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0) ))
    if [[ "$file_age" -lt "$cache_max_age" ]]; then
      needs_refresh=0
    fi
  fi

  if [[ "$needs_refresh" -eq 1 ]]; then
    kubectl get pods --all-namespaces --no-headers \
      -o custom-columns=':metadata.name' 2>/dev/null \
      | sort -u \
      | sed 's/^/pod\//' > "$cache_file" 2>/dev/null || true
  fi

  local candidates
  candidates=$(cat "$cache_file" 2>/dev/null || true)

  COMPREPLY=()
  while IFS= read -r line; do
    COMPREPLY+=("$line")
  done < <(compgen -W "$candidates" -- "$cur")
}

complete -F _klog_completions klog
