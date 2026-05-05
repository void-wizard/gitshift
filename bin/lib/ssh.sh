print_ssh_hosts() {
  local ssh_config="$HOME/.ssh/config"

  if [[ ! -f "$ssh_config" ]]; then
    echo "No ~/.ssh/config file found." >&2
    return 1
  fi

  echo "Existing SSH hosts:" >&2

  grep -E "^[[:space:]]*Host[[:space:]]+" "$ssh_config" \
    | sed -E 's/^[[:space:]]*Host[[:space:]]+//' >&2

}

ssh_host_exists() {
  local host="$1"
  local ssh_config="$HOME/.ssh/config"

  if [[ ! -f "$ssh_config" ]]; then
    return 1
  fi

  while read -r keyword hosts; do
    if [[ "$keyword" != "Host" ]]; then
      continue
    fi

    for candidate in $hosts; do
      if [[ "$candidate" == "$host" ]]; then
        return 0
      fi
    done
  done < "$ssh_config"

  return 1
}

expand_path() {
  local path="$1"

  case "$path" in
    "~") echo "$HOME" ;;
    "~/"*) echo "$HOME/${path#~/}" ;;
    *) echo "$path" ;;
  esac
}

generate_ssh_key() {
  local ssh_key="$1"
  local email="$2"

  if [[ -f "$ssh_key" ]]; then
    echo "SSH key already exists: $ssh_key" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$ssh_key")"

  ssh-keygen -t ed25519 -C "$email" -f "$ssh_key"
}

write_ssh_config_entry() {
  local profile="$1"
  local ssh_host="$2"
  local ssh_key="$3"
  local ssh_config="$HOME/.ssh/config"

  mkdir -p "$HOME/.ssh"
  touch "$ssh_config"

  chmod 700 "$HOME/.ssh"
  chmod 600 "$ssh_config"

  if grep -q "# >>> gitshift $profile >>>" "$ssh_config" 2>/dev/null; then
    echo "SSH config entry already exists for profile: $profile" >&2
    exit 1
  fi

  if ssh_host_exists "$ssh_host"; then
    echo "SSH host already exists in ~/.ssh/config: $ssh_host" >&2
    exit 1
  fi

  {
    echo ""
    echo "# >>> gitshift $profile >>>"
    echo "Host $ssh_host"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $ssh_key"
    echo "  IdentitiesOnly yes"
    echo "# <<< gitshift $profile <<<"
  } >> "$ssh_config"
}

print_public_key() {
  local ssh_key="$1"
  local public_key="${ssh_key}.pub"

  if [[ ! -f "$public_key" ]]; then
    return
  fi

  echo
  echo "Add this public key to GitHub:"
  echo "Settings -> SSH and GPG keys -> New SSH key"
  echo
  cat "$public_key"
  echo
}

configure_ssh_for_profile() {
  local profile="$1"
  local email="$2"
  local ssh_host=""

  if ! prompt_yes_no "Configure SSH for this profile?" "y"; then
    echo ""
    return
  fi

  if prompt_yes_no "Use an existing SSH host from ~/.ssh/config?" "n"; then
    print_ssh_hosts || true

    ssh_host="$(prompt_required "SSH host alias")"

    if ! ssh_host_exists "$ssh_host"; then
      echo "SSH host not found in ~/.ssh/config: $ssh_host" >&2
      exit 1
    fi

    echo "$ssh_host"
    return
  fi

  local default_host
  local default_key
  local ssh_key

  default_host="github-${profile}"
  default_key="$HOME/.ssh/id_ed25519_gitshift_${profile}"

  ssh_host="$(prompt_with_default "SSH host alias" "$default_host")"
  ssh_key="$(prompt_with_default "SSH key path" "$default_key")"
  ssh_key="$(expand_path "$ssh_key")"

  if ! prompt_yes_no "Generate SSH key and write SSH config?" "y"; then
    echo ""
    return
  fi

  generate_ssh_key "$ssh_key" "$email" >&2
  write_ssh_config_entry "$profile" "$ssh_host" "$ssh_key"
  print_public_key "$ssh_key" >&2

  echo "$ssh_host"
  return
}