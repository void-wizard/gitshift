# >>> gitshift git hook >>>
git() {
  if [[ "${1:-}" == "status" ]]; then
    gitshift status
    command git "$@"
  else
    command git "$@"
  fi
}
# <<< gitshift git hook <<<