# Remove one saved Git identity profile, or remove all profiles.
remove_profile() {
  check_initialized

  local key="${1:-}"

  if [[ -z "$key" ]]; then
    echo "Usage: gitshift remove <profile>"
    echo "       gitshift remove --all"
    exit 1
  fi

  if [[ "$key" == "--all" ]]; then
    if ! prompt_yes_no "Remove all profiles?" "n"; then
      echo "Remove canceled."
      return
    fi

    : > "$PROFILE_FILE"
    echo "All profiles removed."
    return
  fi

  local line
  line="$(grep "^${key}|" "$PROFILE_FILE" 2>/dev/null || true)"

  if [[ -z "$line" ]]; then
    echo "Profile not found: $key"
    exit 1
  fi

  if ! prompt_yes_no "Remove profile '$key'?" "y"; then
    echo "Canceled."
    return
  fi

  local tmp_file
  tmp_file="${PROFILE_FILE}.$$"

  trap 'rm -f "$tmp_file"' EXIT INT TERM

  {
    grep -v "^${key}|" "$PROFILE_FILE" || true
  } > "$tmp_file"

  mv "$tmp_file" "$PROFILE_FILE"

  trap - EXIT INT TERM

  echo "Profile removed: $key"
}