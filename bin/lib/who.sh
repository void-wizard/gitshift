# Show the Git identity configured for the current repository
current_profile() {
  check_git_repo

  local name
  name="$(command git config --local --get user.name 2>/dev/null || echo "not configured")"

  local email
  email="$(command git config --local --get user.email 2>/dev/null || echo "not configured")"

  echo "user.name=$name"
  echo "user.email=$email"
}