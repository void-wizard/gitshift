CONFIG_DIR="$HOME/.gitshift"

PROFILE_FILE="$CONFIG_DIR/profiles"

HELP_FILE="$CONFIG_DIR/bin/help.txt"

ensure_config() {
  mkdir -p "$CONFIG_DIR"
  touch "$PROFILE_FILE"
}

show_help() {
  if [[ -f "$HELP_FILE" ]]; then
    cat "$HELP_FILE"
    return
  fi

  echo "Help file not found: $HELP_FILE"
  echo "Please run the installer again."
}

check_initialized() {
  if [[ -d "$CONFIG_DIR" && -f "$PROFILE_FILE" ]]; then
    return 0
  fi

  echo "gitshift is not initialized. Please run: gitshift init"
  exit 1
}

check_git_repo() {
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  echo "Current directory is not a Git repository."
  exit 1
}

prompt_required() {
  local label="$1"
  local value=""

  while [[ -z "$value" ]]; do
    printf "%s: " "$label" >&2
    read -r value

    if [[ -z "$value" ]]; then
      echo "$label is required." >&2
    fi
  done

  echo "$value"
}

prompt_with_default() {
  local label="$1"
  local default_value="$2"
  local value=""

  printf "%s [%s]: " "$label" "$default_value" >&2
  read -r value

  if [[ -z "$value" ]]; then
    value="$default_value"
  fi

  echo "$value"
}

prompt_yes_no() {
  local question="$1"
  local default_answer="${2:-n}"
  local answer=""

  while true; do
    if [[ "$default_answer" == "y" ]]; then
      printf "%s [Y/n]: " "$question" >&2
    else
      printf "%s [y/N]: " "$question" >&2
    fi

    read -r answer

    if [[ -z "$answer" ]]; then
      answer="$default_answer"
    fi

    case "$answer" in
      y|Y|yes|YES|Yes) return 0 ;;
      n|N|no|NO|No) return 1 ;;
      *) echo "Please answer yes or no." >&2 ;;
    esac
  done
}