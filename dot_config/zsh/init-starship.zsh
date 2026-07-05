if command -v starship >/dev/null 2>&1 && [[ "$TERM" != "dumb" ]]; then
  eval "$(starship init zsh)"
fi
