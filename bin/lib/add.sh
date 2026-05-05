# Add or replace a Git identity profile
add_profile() {
  check_initialized

  local key
  local name
  local email
  local github_owner
  local ssh_host

  key="$(prompt_required "Profile name")"
  name="$(prompt_required "Git user.name")"
  email="$(prompt_required "Git user.email")"

  github_owner="$(prompt_required "GitHub owner/account")"

  ssh_host="$(configure_ssh_for_profile "$key" "$email")"

  # Exit if any required value is missing
  if [[ -z "$key" || -z "$name" || -z "$email" || -z "$github_owner" ]]; then
    echo "Usage: gitshift add"
    exit 1
  fi

  # Write the updated profiles file to a temp file first
  # then replace the original file in one step
  local tmp_file
  tmp_file="${PROFILE_FILE}.$$"

  trap 'rm -f "$tmp_file"' EXIT INT TERM

  {
    grep -v "^${key}|" "$PROFILE_FILE" || true
    echo "${key}|${name}|${email}|${github_owner}|${ssh_host}"
  } > "$tmp_file"

  mv "$tmp_file" "$PROFILE_FILE"

  trap - EXIT INT TERM

  echo "Profile saved: $key"
}