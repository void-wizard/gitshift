# Show Git repository and identity information for git status hook
status() {
  local repo
  repo="$(command git rev-parse --show-toplevel 2>/dev/null || true)"

  local name
  name="$(command git config --local --get user.name 2>/dev/null || echo "not configured")"

  local email
  email="$(command git config --local --get user.email 2>/dev/null || echo "not configured")"

  echo "Git repository: ${repo:-not a Git repository}"
  echo "Git user.name: $name"
  echo "Git user.email: $email"
  echo
}