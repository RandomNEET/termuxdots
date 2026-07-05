function lg() {
  export LAZYGIT_NEW_DIR_FILE="$HOME/.lazygit/newdir"

  command lazygit "$@"

  if [[ -f "$LAZYGIT_NEW_DIR_FILE" ]]; then
    cd "$(cat "$LAZYGIT_NEW_DIR_FILE")" || return
    rm -f "$LAZYGIT_NEW_DIR_FILE"
  fi
}
