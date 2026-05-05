#!/usr/bin/env bash

# Enable strict Bash error handling
set -euo pipefail

REPO_URL="https://github.com/void-wizard/gitshift.git"
BRANCH="main"

# Directory where gitshift stores installed files and user data
CONFIG_DIR="$HOME/.gitshift"

# Directory where the gitshift executable will be installed
INSTALL_DIR="$CONFIG_DIR/bin"

# Temporary directory used to download the repository
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}

download_project() {
  # Directory where the repository will be cloned
  local source_dir="$TMP_DIR/gitshift"

  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$source_dir"

  echo "$source_dir"
}

install_files() {
  # Downloaded project directory
  local source_dir="${1:-}"

  # Make sure the gitshift config directory exists
  mkdir -p "$CONFIG_DIR"

  # Replace the installed bin directory with the project's bin directory
  rm -rf "$INSTALL_DIR"
  cp -R "$source_dir/bin" "$INSTALL_DIR"

  # Make sure gitshift can be executed as a command
  chmod +x "$INSTALL_DIR/gitshift"
}

init_gitshift() {
  # Initialize gitshift runtime data
  "$INSTALL_DIR/gitshift" init
}

detect_shell_rc() {
  # Detect the user's default shell and return the shell config file
  case "${SHELL:-}" in
    */zsh) echo "$HOME/.zshrc" ;;
    */bash) echo "$HOME/.bashrc" ;;
    *) echo "$HOME/.profile" ;;
  esac
}

install_path() {
  # Shell config file to update
  local rc_file="$1"

  # If the gitshift PATH block already exists, do not add it again
  if grep -q "# >>> gitshift path >>>" "$rc_file" 2>/dev/null; then
    return
  fi

  {
    echo ""
    echo "# >>> gitshift path >>>"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    echo "# <<< gitshift path <<<"
  } >> "$rc_file"
}

install_git_hook() {
  # Shell config file to update
  local rc_file="$1"

  # Installed hook file
  local hook_source="$INSTALL_DIR/shell-hook.sh"

  # If the gitshift git hook already exists, do not overwrite it
  if grep -q "# >>> gitshift git hook >>>" "$rc_file" 2>/dev/null; then
    echo "gitshift git hook already exists in: $rc_file"
    echo
    echo "If git status does not work as expected, manually add the contents of:"
    echo "$hook_source"
    echo
    echo "to your shell config file:"
    echo "$rc_file"
    echo
    echo "Hook content:"
    cat "$hook_source"
    return
  fi

  {
    echo ""
    cat "$hook_source"
  } >> "$rc_file"
}

main() {
  trap cleanup EXIT INT TERM

  echo "Temporary directory created: $TMP_DIR"
  echo "Temporary files will be removed automatically."

  local source_dir
  local rc_file

  rc_file="$(detect_shell_rc)"
  source_dir="$(download_project)"

  echo "Project downloaded to: $source_dir"

  install_files "$source_dir"
  init_gitshift
  install_path "$rc_file"
  install_git_hook "$rc_file"

  echo "gitshift files installed."
  echo "Executable: $INSTALL_DIR/gitshift"
  echo "Help file: $INSTALL_DIR/help.txt"
  echo "Shell hook: $INSTALL_DIR/shell-hook.sh"
  echo "Shell config updated: $rc_file"
  echo
  echo "Run this command to activate gitshift:"
  echo "source $rc_file"
}

main