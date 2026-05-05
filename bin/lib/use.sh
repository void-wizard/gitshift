# Apply a saved profile to the current Git repository
use_profile() {
  check_initialized

  local key="${1:-}"

  if [[ -z "$key" ]]; then
    echo "Usage: gitshift use <profile>"
    exit 1
  fi

  check_git_repo

  local line
  line="$(grep "^${key}|" "$PROFILE_FILE" 2>/dev/null || true)"

  # Exit if the requested profile does not exist
  if [[ -z "$line" ]]; then
    echo "Profile not found: $key"
    exit 1
  fi

  # Extract name & email from the profile record
  local name email
  name="$(echo "$line" | cut -d'|' -f2)"
  email="$(echo "$line" | cut -d'|' -f3)"

  command git config --local user.name "$name"
  command git config --local user.email "$email"

  echo "Git identity switched for this repository:"
  echo "user.name=$name"
  echo "user.email=$email"
}