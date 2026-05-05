# List all saved Git identity profiles
list_profiles() {
  check_initialized

  if [[ ! -s "$PROFILE_FILE" ]]; then
    echo "No profiles yet. Use: gitshift add"
    return
  fi

  while IFS='|' read -r key name email github_owner ssh_host; do
  if [[ -n "${ssh_host:-}" ]]; then
    echo "$key: $name <$email> [$github_owner] -> [$ssh_host]"
  else
    echo "$key: $name <$email> [$github_owner]"
  fi
done < "$PROFILE_FILE"
}