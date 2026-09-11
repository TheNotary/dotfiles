# Downloads a GitHub folder into the current directory using gh authentication.
ggrab() (
  set -o pipefail
  local started_at=$SECONDS
  local url="${1:-}"
  local concurrency="${GGRAB_CONCURRENCY:-20}"

  if [[ -z "$url" ]]; then
    echo "Usage: ggrab <github-folder-url>"
    return 1
  fi

  local owner repo view branch folder
  IFS=/ read -r owner repo view branch folder <<< "${url#https://github.com/}"

  if [[ "$url" != https://github.com/* || "$view" != tree ||
        -z "$owner" || -z "$repo" || -z "$branch" || -z "$folder" ]]; then
    echo "Expected https://github.com/OWNER/REPO/tree/BRANCH/FOLDER" >&2
    return 1
  fi

  if [[ "/$folder/" == */../* || "/$folder/" == */./* || "$folder" == /* ]]; then
    echo "Folder must be a repository-relative path without . or .. components" >&2
    return 1
  fi

  if [[ ! "$concurrency" =~ ^[1-9][0-9]*$ ]]; then
    echo "GGRAB_CONCURRENCY must be a positive integer" >&2
    return 1
  fi
  folder="${folder%/}"

  local workspace
  workspace=$(mktemp -d) || return
  trap 'rm -rf -- "$workspace"' EXIT

  _ggrab_queue_files() {
    local entry_type entry_path destination
    local found=0 queued=0

    gh api --hostname github.com --method GET \
      -f recursive=1 "repos/$owner/$repo/git/trees/$branch" \
      --jq 'if .truncated then error("GitHub truncated the recursive tree; refusing an incomplete download")
        else [.tree[] | .type + "\u0000" + .path + "\u0000"] | join("") end' \
      > "$workspace/tree" || return

    while IFS= read -r -d '' entry_type && IFS= read -r -d '' entry_path; do
      if [[ "$entry_type" == tree && "$entry_path" == "$folder" ]]; then
        found=1
        mkdir -p -- "$target" || return
      fi
      [[ "$entry_path" == "$folder/"* ]] || continue
      destination="$target/${entry_path#"$folder/"}"
      case "$entry_type" in
        tree)
          mkdir -p -- "$destination" || return
          ;;
        blob)
          mkdir -p -- "$(dirname -- "$destination")" || return
          printf '%s\0%s\0' "repos/$owner/$repo/contents/$entry_path" \
            "$destination" || return
          queued=$((queued + 1))
          ;;
      esac
    done < "$workspace/tree"

    if [[ "$found" -eq 0 ]]; then
      printf 'Folder not found: %s\n' "$folder" >&2
      return 1
    fi
    printf 'Discovery finished in %ds (%s files queued, 1 tree request)\n' \
      "$((SECONDS - started_at))" "$queued" >&2
  }

  local target result=0
  target="./$(basename -- "$folder")"

  printf 'Discovering %s (concurrency=%s)\n' "$folder" "$concurrency" >&2
  _ggrab_queue_files |
    xargs -0 -n 2 -P "$concurrency" bash -c '
    [[ "$#" -eq 3 ]] || exit 0
    branch="$1"
    remote_path="$2"
    destination="$3"
    started_at=$SECONDS

    echo "Downloading $destination"
    gh api --hostname github.com --method GET \
      -H "Accept: application/vnd.github.raw+json" \
      -f ref="$branch" "$remote_path" > "$destination"
    result=$?
    if [[ "$result" -eq 0 ]]; then
      printf "Downloaded %s in %ds\n" "$destination" "$((SECONDS - started_at))" >&2
    else
      printf "Failed %s after %ds\n" "$destination" "$((SECONDS - started_at))" >&2
    fi
    exit "$result"
  ' ggrab-download "$branch" || result=$?

  printf 'Elapsed time: %ds\n' "$((SECONDS - started_at))" >&2
  return "$result"
)
