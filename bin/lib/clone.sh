normalize_github_repo() {
  # Extract owner/repo.git from repo url

  # repo url
  local repo="${1:-}"

  # git@github.com:owner/repo.git
  if [[ "$repo" =~ ^git@[^:]+:(.+)$ ]]; then
    echo "${BASH_REMATCH[1]%.git}.git"
    return
  fi

  # https://github.com/owner/repo.git
  if [[ "$repo" =~ ^https://github.com/(.+)$ ]]; then
    echo "${BASH_REMATCH[1]%.git}.git"
    return
  fi

  # owner/repo
  if [[ "$repo" =~ ^[^/:]+/[^/]+$ ]]; then
    echo "${repo%.git}.git"
    return
  fi

  echo "Unsupported GitHub repository format: $repo" >&2
  exit 1
}

get_repo_owner() {
  local repo_path="$1"

  echo "$repo_path" | cut -d'/' -f1
}

clone_repo() {
  check_initialized

  local repo="${1:-}"

  if [[ -z "$repo" ]]; then
    echo "Usage: gitshift clone <repo>"
    exit 1
  fi

  local repo_path
  repo_path="$(normalize_github_repo "$repo")"

  local github_owner
  github_owner="$(get_repo_owner "$repo_path")"

  # Find the profile matching the GitHub owner
  local line
  line="$(awk -F'|' -v owner="$github_owner" '$4 == owner { print; exit }' "$PROFILE_FILE")"

  if [[ -z "$line" ]]; then
    echo "Profile not found for GitHub owner: $github_owner"
    echo "Create one with: gitshift add"
    exit 1
  fi

  local profile
  local ssh_host

  profile="$(echo "$line" | cut -d'|' -f1)"
  ssh_host="$(echo "$line" | cut -d'|' -f5)"

  if [[ -z "$ssh_host" ]]; then
    echo "Profile does not have an SSH host: $profile"
    exit 1
  fi

  local clone_url
  clone_url="git@${ssh_host}:${repo_path}"

  echo "Detected profile: $profile"
  echo "GitHub owner: $github_owner"
  echo "Clone URL: $clone_url"

  command git clone "$clone_url"
}