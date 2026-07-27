
# Use this wonderful alias to onboard your replacement laptop to 
# All the ssh servers you currently have access to
ssh-onboard-key() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: migrate_ssh_key PATH_TO_PUBLIC_KEY" >&2
    return 2
  fi

  local key_path="$1"
  local config="$HOME/.ssh/config"
  local new_key
  local failures=0

  [[ -r "$key_path" ]] || {
    echo "Cannot read public key: $key_path" >&2
    return 2
  }

  [[ -r "$config" ]] || {
    echo "Cannot read SSH config: $config" >&2
    return 2
  }

  new_key="$(tr -d '\r\n' < "$key_path")"

  [[ -n "$new_key" ]] || {
    echo "Public key is empty: $key_path" >&2
    return 2
  }

  while IFS= read -r host; do
    echo "Checking $host..."

    if printf '%s\n' "$new_key" |
      ssh -T -o ConnectTimeout=10 "$host" '
        IFS= read -r key
        umask 077
        mkdir -p "$HOME/.ssh"
        touch "$HOME/.ssh/authorized_keys"
        chmod 700 "$HOME/.ssh"
        chmod 600 "$HOME/.ssh/authorized_keys"

        if grep -qxF "$key" "$HOME/.ssh/authorized_keys"; then
          echo "Already installed"
        else
          printf "%s\n" "$key" >> "$HOME/.ssh/authorized_keys"
          echo "Installed"
        fi
      '
    then
      echo "OK: $host"
    else
      echo "FAILED: $host" >&2
      ((failures++))
    fi
  done < <(
    awk '
      tolower($1) == "host" {
        for (i = 2; i <= NF; i++) {
          if ($i ~ /^#/) break
          if ($i !~ /[*?!]/) print $i
        }
      }
    ' "$config" | sort -u
  )

  if ((failures > 0)); then
    echo "$failures host(s) failed." >&2
    return 1
  fi
}

